import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/network/realtime_watch.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../api/team/team_model.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../utils/dummy_deactivated_account.dart';
import '../user/user_service.dart';

final teamServiceProvider = Provider(
  (ref) => TeamService(ref.read(supabaseClientProvider), ref.read(userServiceProvider)),
);

class TeamService {
  final SupabaseClient _supabase;
  final UserService _userService;

  TeamService(this._supabase, this._userService);

  String get generateTeamId => const Uuid().v4().replaceAll('-', '');

  Future<TeamModel> getTeamById(String teamId) async {
    try {
      final row = await _supabase
          .from('teams')
          .select('*, team_players(user_id, role)')
          .eq('id', teamId)
          .maybeSingle();
      if (row == null) return deActiveDummyTeamModel(teamId);
      return fetchDetailsOfTeam(_teamFromRow(row));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<int> getUserOwnedTeamsCount(String userId) async {
    try {
      final teams = await _rawTeamsByMember(userId);
      return teams
          .where(
            (t) =>
                t.created_by == userId ||
                t.players.any((p) => p.id == userId && p.role == TeamPlayerRole.admin),
          )
          .length;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// Watches teams/team_players/team_stats, not just teams: squad changes
  /// (add/edit/remove player) and stat updates never touch the teams row
  /// itself, so a plain `.stream()` on teams alone would miss them - same
  /// gap MatchService.streamMatchById had for match_teams/match_players.
  Stream<TeamModel> streamTeamById(String teamId) {
    return watchTables(_supabase, ['teams', 'team_players', 'team_stats'], () async {
      final row = await _supabase.from('teams').select('*, team_players(user_id, role)').eq('id', teamId).maybeSingle();
      if (row == null) return deActiveDummyTeamModel(teamId);
      return fetchDetailsOfTeam(_teamFromRow(row));
    });
  }

  Future<TeamStat> getTeamStatById(String teamId) async {
    try {
      final row = await _supabase.from('team_stats').select().eq('team_id', teamId).maybeSingle();
      return row == null ? const TeamStat() : _teamStatFromRow(row);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<TeamModel>> streamUserRelatedTeams({
    required String userId,
    int limit = 10,
  }) {
    return watchTables(_supabase, ['team_players', 'teams', 'team_stats'], () async {
      final teams = await _rawTeamsByMember(userId);
      return Future.wait(teams.take(limit).map(fetchDetailsOfTeam));
    });
  }

  Stream<List<TeamModel>> streamUserOwnedTeams(String userId) {
    return watchTables(_supabase, ['team_players', 'teams', 'team_stats'], () async {
      final teams = await _rawTeamsByMember(userId);
      final owned = teams.where(
        (t) =>
            t.created_by == userId ||
            t.players.any((p) => p.id == userId && p.role == TeamPlayerRole.admin),
      );
      return Future.wait(owned.map(fetchDetailsOfTeam));
    });
  }

  Stream<List<TeamModel>> streamUserRelatedTeamsByUserId(String userId) {
    return watchTables(_supabase, ['team_players', 'teams', 'team_stats'], () async {
      final teams = await _rawTeamsByMember(userId);
      return Future.wait(teams.map(fetchDetailsOfTeam));
    });
  }

  /// Create-or-replace: mirrors the app's Firestore-era `.set(merge:true)`
  /// flow - the client pre-generates a team id and always sends the complete
  /// roster, so this fully replaces team_players on every call.
  Future<String> updateTeam(TeamModel team) async {
    try {
      await _supabase.from('teams').upsert({
        'id': team.id,
        'name': team.name,
        'name_lowercase': team.name.toLowerCase(),
        'city': team.city,
        'name_initial': team.name_initial,
        'profile_img_url': team.profile_img_url,
        'created_by': team.created_by,
      });

      await _supabase.from('team_players').delete().eq('team_id', team.id);
      if (team.players.isNotEmpty) {
        await _supabase.from('team_players').insert(
              team.players.map((p) => {'team_id': team.id, 'user_id': p.id, 'role': p.role.name}).toList(),
            );
      }
      if (team.created_by != null) {
        await _supabase.from('team_stats').upsert({'team_id': team.id}, onConflict: 'team_id');
      }

      return team.id;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateProfileImageUrl(String teamId, String? imageUrl) async {
    try {
      await _supabase.from('teams').update({'profile_img_url': imageUrl}).eq('id', teamId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTeamStat(String teamId, TeamStat stat) async {
    try {
      await _supabase.from('team_stats').upsert({
        'team_id': teamId,
        'played': stat.played,
        'win': stat.status.win,
        'tie': stat.status.tie,
        'lost': stat.status.lost,
        'runs': stat.runs,
        'wickets': stat.wickets,
        'batting_average': stat.batting_average,
        'bowling_average': stat.bowling_average,
        'highest_runs': stat.highest_runs,
        'lowest_runs': stat.lowest_runs,
        'run_rate': stat.run_rate,
      }, onConflict: 'team_id');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> addPlayersToTeam(String teamId, List<TeamPlayer> players) async {
    try {
      final existing = await _supabase.from('team_players').select('user_id').eq('team_id', teamId);
      final existingIds = existing.map((r) => r['user_id'] as String).toSet();
      final toInsert = players.where((p) => !existingIds.contains(p.id));
      if (toInsert.isEmpty) return;
      await _supabase.from('team_players').insert(
            toInsert.map((p) => {'team_id': teamId, 'user_id': p.id, 'role': p.role.name}).toList(),
          );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> editPlayersToTeam(
    String teamId,
    String ownerId,
    List<TeamPlayer> players,
  ) async {
    try {
      await _supabase.from('team_players').delete().eq('team_id', teamId);
      if (players.isNotEmpty) {
        await _supabase.from('team_players').insert(
              players.map((p) => {'team_id': teamId, 'user_id': p.id, 'role': p.role.name}).toList(),
            );
      }
      await _supabase.from('teams').update({'created_by': ownerId}).eq('id', teamId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> removePlayersFromTeam(
    String teamId,
    List<TeamPlayer> players,
  ) async {
    try {
      await _supabase
          .from('team_players')
          .delete()
          .eq('team_id', teamId)
          .inFilter('user_id', players.map((p) => p.id).toList());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<bool> isTeamNameAvailable(String teamName) async {
    try {
      final rows = await _supabase.from('teams').select('id').eq('name_lowercase', teamName.toLowerCase());
      return rows.isEmpty;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<TeamModel>> searchTeam(
    String searchKey, {
    int limit = 20,
    String? lastTeamId,
  }) async {
    try {
      final rows = await _supabase
          .from('teams')
          .select('*, team_players(user_id, role)')
          .ilike('name_lowercase', '${searchKey.toLowerCase()}%')
          .order('id')
          .limit(limit);
      final teams = rows.map((row) => _teamFromRow(row)).toList();
      return Future.wait(teams.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await _supabase.from('teams').delete().eq('id', teamId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<TeamModel>> getTeamsByIds(List<String> teamIds) async {
    if (teamIds.isEmpty) return [];
    try {
      final rows =
          await _supabase.from('teams').select('*, team_players(user_id, role)').inFilter('id', teamIds);
      final teams = rows.map((row) => _teamFromRow(row)).toList();
      return Future.wait(teams.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  // ---- helpers ------------------------------------------------------------

  TeamModel _teamFromRow(Map<String, dynamic> row) {
    final playerRows = (row['team_players'] as List?) ?? const [];
    return TeamModel(
      id: row['id'] as String,
      name: row['name'] as String,
      name_lowercase: row['name_lowercase'] as String,
      city: row['city'] as String?,
      name_initial: row['name_initial'] as String?,
      profile_img_url: row['profile_img_url'] as String?,
      created_by: row['created_by'] as String?,
      created_at: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : null,
      players: playerRows
          .map((p) => TeamPlayer(
                id: p['user_id'] as String,
                role: (p['role'] as String) == 'admin' ? TeamPlayerRole.admin : TeamPlayerRole.player,
              ))
          .toList(),
    );
  }

  TeamStat _teamStatFromRow(Map<String, dynamic> row) {
    return TeamStat(
      played: row['played'] as int,
      status: TeamMatchStatus(
        win: row['win'] as int,
        tie: row['tie'] as int,
        lost: row['lost'] as int,
      ),
      runs: row['runs'] as int,
      wickets: row['wickets'] as int,
      batting_average: (row['batting_average'] as num).toDouble(),
      bowling_average: (row['bowling_average'] as num).toDouble(),
      highest_runs: row['highest_runs'] as int,
      lowest_runs: row['lowest_runs'] as int,
      run_rate: (row['run_rate'] as num).toDouble(),
    );
  }

  Future<List<TeamModel>> _rawTeamsByMember(String userId) async {
    final rows = await _supabase
        .from('team_players')
        .select('team_id, teams!inner(*, team_players(user_id, role))')
        .eq('user_id', userId);
    return rows.map((row) => _teamFromRow(row['teams'] as Map<String, dynamic>)).toList();
  }

  Future<TeamModel> fetchDetailsOfTeam(TeamModel team) async {
    final stat = await getTeamStatById(team.id);
    team = team.copyWith(stat: stat);

    final users = await getMemberListFromUserIds(
      team.players.map((e) => e.id).toList(),
    );

    final players = team.players.map((player) {
      final user = users.firstWhere((element) => element.id == player.id);
      return player.copyWith(user: user);
    }).toList();

    UserModel? createdBy;
    if (team.created_by != null) {
      createdBy = users.firstWhereOrNull((e) => e.id == team.created_by) ??
          await getUserFromUserId(team.created_by!);
    }

    return team.copyWith(
      players: players,
      created_by_user: createdBy ?? team.created_by_user,
    );
  }

  Future<List<UserModel>> getMemberListFromUserIds(List<String> users) async {
    try {
      return await _userService.getUsersByIds(users);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<UserModel> getUserFromUserId(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      return user ?? deActiveDummyUserAccount(userId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
