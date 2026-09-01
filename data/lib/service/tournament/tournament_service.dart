import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/ball_score/ball_score_model.dart';
import '../../api/match/match_model.dart';
import '../../api/network/realtime_watch.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../api/team/team_model.dart';
import '../../api/tournament/tournament_model.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../match/match_service.dart';
import '../team/team_service.dart';
import '../user/user_service.dart';

final tournamentServiceProvider = Provider(
  (ref) => TournamentService(
    ref.read(supabaseClientProvider),
    ref.read(teamServiceProvider),
    ref.read(matchServiceProvider),
    ref.read(userServiceProvider),
  ),
);

const _tournamentSelect = '*, tournament_teams(team_id), tournament_members(user_id, role)';

class TournamentService {
  final SupabaseClient _supabase;
  final TeamService _teamService;
  final MatchService _matchService;
  final UserService _userService;

  TournamentService(
    this._supabase,
    this._teamService,
    this._matchService,
    this._userService,
  );

  String get generateTournamentId => const Uuid().v4().replaceAll('-', '');

  /// Create-or-replace: mirrors the app's Firestore-era `.set(merge:true)`
  /// flow - the client pre-generates a tournament id and sends the full
  /// member/team list, so this fully replaces tournament_members and
  /// tournament_teams on every call (same pattern as TeamService.updateTeam).
  Future<void> createTournament(TournamentModel tournament) async {
    try {
      await _supabase.from('tournaments').upsert({
        'id': tournament.id,
        'name': tournament.name,
        'profile_img_url': tournament.profile_img_url,
        'banner_img_url': tournament.banner_img_url,
        'type': tournament.type.value,
        'created_by': tournament.created_by,
        'start_date': tournament.start_date.toUtc().toIso8601String(),
        'end_date': tournament.end_date.toUtc().toIso8601String(),
      });

      await _supabase.from('tournament_members').delete().eq('tournament_id', tournament.id);
      if (tournament.members.isNotEmpty) {
        await _supabase.from('tournament_members').insert(
              tournament.members
                  .map((m) => {'tournament_id': tournament.id, 'user_id': m.id, 'role': m.role.name})
                  .toList(),
            );
      }

      if (tournament.team_ids.isNotEmpty) {
        await _supabase.from('tournament_teams').delete().eq('tournament_id', tournament.id);
        await _supabase.from('tournament_teams').insert(
              tournament.team_ids.map((teamId) => {'tournament_id': tournament.id, 'team_id': teamId}).toList(),
            );
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<TournamentModel> getTournamentById(String id) async {
    try {
      final row = await _supabase.from('tournaments').select(_tournamentSelect).eq('id', id).maybeSingle();
      if (row == null) {
        return TournamentModel(
          id: '',
          name: '',
          type: TournamentType.knockOut,
          created_by: '',
          start_date: DateTime.now(),
          end_date: DateTime.now(),
        );
      }
      return _tournamentFromRow(row);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<TournamentModel>> getTournaments({
    String? lastMatchId,
    int limit = 10,
  }) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toUtc();
      final rows = await _supabase
          .from('tournaments')
          .select(_tournamentSelect)
          .gt('start_date', thirtyDaysAgo.toIso8601String())
          .order('start_date')
          .limit(limit);
      final tournaments = rows.map(_tournamentFromRow).toList();
      return Future.wait(tournaments.map(_withComputedStatus));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<TournamentTeamStat>> streamTeamStats(String tournamentId) {
    return watchTables(_supabase, ['tournament_team_stats'], () async {
      final rows = await _supabase.from('tournament_team_stats').select().eq('tournament_id', tournamentId);
      return Future.wait(rows.map((row) async {
        final team = await _teamService.getTeamById(row['team_id'] as String);
        return _teamStatFromRow(row).copyWith(team: team);
      }));
    });
  }

  Future<TournamentTeamStat> getTeamStatByTeamId(
    String tournamentId,
    TeamModel team,
  ) async {
    try {
      final row = await _supabase
          .from('tournament_team_stats')
          .select()
          .eq('tournament_id', tournamentId)
          .eq('team_id', team.id)
          .maybeSingle();
      return row == null
          ? TournamentTeamStat(team_id: team.id, team: team)
          : _teamStatFromRow(row).copyWith(team: team);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<PlayerKeyStat>> streamPlayerKeyStats(String tournamentId) {
    return watchTables(_supabase, ['tournament_player_key_stats'], () async {
      final rows = await _supabase.from('tournament_player_key_stats').select().eq('tournament_id', tournamentId);
      return Future.wait(rows.map((row) async {
        final player = await _userService.getUser(row['player_id'] as String);
        final stat = _playerKeyStatFromRow(row);
        return player == null ? stat : stat.copyWith(player: player);
      }));
    });
  }

  Future<PlayerKeyStat> getPlayerKeyStatByPlayerId(
    String tournamentId,
    UserModel player,
  ) async {
    try {
      final row = await _supabase
          .from('tournament_player_key_stats')
          .select()
          .eq('tournament_id', tournamentId)
          .eq('player_id', player.id)
          .maybeSingle();
      return row == null
          ? PlayerKeyStat(player_id: player.id, teamName: '', player: player)
          : _playerKeyStatFromRow(row).copyWith(player: player);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<int> getUserOwnedTournamentsCount(String userId) async {
    try {
      final ownedRows = await _supabase.from('tournaments').select('id').eq('created_by', userId);
      final organizerRows = await _supabase
          .from('tournament_members')
          .select('tournament_id')
          .eq('user_id', userId)
          .eq('role', TournamentMemberRole.organizer.name);
      final ids = <String>{
        ...ownedRows.map((r) => r['id'] as String),
        ...organizerRows.map((r) => r['tournament_id'] as String),
      };
      return ids.length;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// "Active" = currently running or still to come (end_date hasn't passed
  /// yet) - matches MatchService's streamActiveRunningMatches/
  /// streamUpcomingMatches pattern for the home feed. No hydrated teams here
  /// (same as the original Firestore getTournaments/searchTournament, which
  /// only hydrate `.teams` in the single-tournament detail view).
  Stream<List<TournamentModel>> streamActiveTournaments({int limit = 10}) {
    return watchTables(_supabase, ['tournaments', 'tournament_teams'], () async {
      final now = DateTime.now().toUtc();
      final rows = await _supabase
          .from('tournaments')
          .select(_tournamentSelect)
          .gte('end_date', now.toIso8601String())
          .order('start_date')
          .limit(limit);
      final tournaments = rows.map(_tournamentFromRow).toList();
      return Future.wait(tournaments.map(_withComputedStatus));
    });
  }

  Stream<List<TournamentModel>> streamCurrentUserRelatedMatches(String userId) {
    return watchTables(_supabase, ['tournaments', 'tournament_members'], () async {
      final ownedRows = await _supabase.from('tournaments').select(_tournamentSelect).eq('created_by', userId);
      final memberRows = await _supabase
          .from('tournament_members')
          .select('tournament_id, tournaments!inner($_tournamentSelect)')
          .eq('user_id', userId)
          .inFilter('role', [TournamentMemberRole.organizer.name, TournamentMemberRole.admin.name]);

      final byId = <String, Map<String, dynamic>>{};
      for (final row in ownedRows) {
        byId[row['id'] as String] = row;
      }
      for (final row in memberRows) {
        final t = row['tournaments'] as Map<String, dynamic>;
        byId[t['id'] as String] = t;
      }
      return byId.values.map(_tournamentFromRow).toList();
    });
  }

  Stream<TournamentModel> streamTournamentById(String tournamentId) {
    return watchTables(_supabase, ['tournaments', 'tournament_teams', 'tournament_members'], () async {
      final row = await _supabase.from('tournaments').select(_tournamentSelect).eq('id', tournamentId).maybeSingle();
      if (row == null) {
        return TournamentModel(
          id: tournamentId,
          name: '',
          created_by: '',
          type: TournamentType.knockOut,
          start_date: DateTime.now(),
          end_date: DateTime.now().add(const Duration(days: 1)),
        );
      }

      var tournament = _tournamentFromRow(row);
      if (tournament.team_ids.isNotEmpty) {
        final teams = await _teamService.getTeamsByIds(tournament.team_ids);
        tournament = tournament.copyWith(teams: teams);
      }
      if (tournament.members.isNotEmpty) {
        final memberIds = tournament.members.map((e) => e.id).toList();
        final users = await _userService.getUsersByIds(memberIds);
        final members = tournament.members.map((member) {
          final user = users.firstWhere((element) => element.id == member.id);
          return member.copyWith(user: user);
        }).toList();
        tournament = tournament.copyWith(members: members);
      }
      return tournament;
    });
  }

  Future<void> _updateTeamStats(
    String tournamentId,
    TournamentTeamStat teamStat,
  ) async {
    try {
      await _supabase.from('tournament_team_stats').upsert({
        'tournament_id': tournamentId,
        'team_id': teamStat.team_id,
        'points': teamStat.points,
        'wins': teamStat.wins,
        'losses': teamStat.losses,
        'nrr': teamStat.nrr,
        'played_matches': teamStat.played_matches,
      }, onConflict: 'tournament_id,team_id');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> _updatePlayerKeyStats(
    String tournamentId,
    PlayerKeyStat keyStat,
  ) async {
    try {
      await _supabase.from('tournament_player_key_stats').upsert({
        'tournament_id': tournamentId,
        'player_id': keyStat.player_id,
        'team_name': keyStat.teamName,
        'stats': keyStat.stats.toJson(),
      }, onConflict: 'tournament_id,player_id');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTournamentStats({
    required String tournamentId,
    required MatchModel match,
    required List<BallScoreModel> ballScores,
  }) async {
    if (match.teams.isEmpty || ballScores.isEmpty) {
      return;
    }

    try {
      final userStatType = match.match_type == MatchType.testMatch
          ? UserStatType.test
          : UserStatType.other;

      for (final team in match.teams) {
        // Update team stats
        final currentTeamStat =
            await getTeamStatByTeamId(tournamentId, team.team);

        final newTeamStat = match.getTeamStat(
          team.team_id,
          currentTeamStat: currentTeamStat,
        );

        await _updateTeamStats(tournamentId, newTeamStat);

        // Update player stats
        for (final player in team.squad) {
          final currentKeyStat =
              await getPlayerKeyStatByPlayerId(tournamentId, player.player);

          final newStats = ballScores
              .where(
                (score) =>
                    score.batsman_id == player.id ||
                    score.bowler_id == player.id ||
                    score.wicket_taker_id == player.id,
              )
              .toList()
              .calculateUserStats(
                player.id,
                oldUserStats: currentKeyStat.stats,
                type: userStatType,
              );

          final updatedKeyStat = PlayerKeyStat(
            player_id: player.id,
            teamName: team.team.name,
            stats: newStats,
          );

          await _updatePlayerKeyStats(tournamentId, updatedKeyStat);
        }
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTeamIds(
    String tournamentId,
    List<String> teamIds,
  ) async {
    try {
      await _supabase.from('tournament_teams').delete().eq('tournament_id', tournamentId);
      if (teamIds.isNotEmpty) {
        await _supabase.from('tournament_teams').insert(
              teamIds.map((teamId) => {'tournament_id': tournamentId, 'team_id': teamId}).toList(),
            );
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> removeMatchFromTournament(
    String tournamentId,
    String matchId,
  ) async {
    try {
      await _supabase.from('matches').update({'tournament_id': null}).eq('id', matchId).eq('tournament_id', tournamentId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> addMatchInTournament(String tournamentId, String matchId) async {
    try {
      await _supabase.from('matches').update({'tournament_id': tournamentId}).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTournamentMembers(
    String tournamentId,
    List<TournamentMember> members,
  ) async {
    try {
      await _supabase.from('tournament_members').delete().eq('tournament_id', tournamentId);
      if (members.isNotEmpty) {
        await _supabase.from('tournament_members').insert(
              members.map((m) => {'tournament_id': tournamentId, 'user_id': m.id, 'role': m.role.name}).toList(),
            );
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> removeTournamentMember(
    String tournamentId,
    TournamentMember member,
  ) async {
    try {
      await _supabase.from('tournament_members').delete().eq('tournament_id', tournamentId).eq('user_id', member.id);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> changeTournamentOwner(
    String tournamentId,
    String? newOwnerId,
    List<TournamentMember> members,
  ) async {
    try {
      await _supabase.from('tournaments').update({'created_by': newOwnerId}).eq('id', tournamentId);
      await updateTournamentMembers(tournamentId, members);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<TournamentModel>> searchTournament(
    String searchKey, {
    int limit = 20,
    String? lastTournamentId,
  }) async {
    try {
      final rows = await _supabase
          .from('tournaments')
          .select(_tournamentSelect)
          .ilike('name', '$searchKey%')
          .order('id')
          .limit(limit);
      final tournaments = rows.map(_tournamentFromRow).toList();
      return Future.wait(tournaments.map(_withComputedStatus));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteTournament(String tournamentId) async {
    try {
      await _supabase.from('tournaments').delete().eq('id', tournamentId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  // ---- helpers --------------------------------------------------------

  Future<TournamentModel> _withComputedStatus(TournamentModel tournament) async {
    final matches = await _matchService.getMatchesByTournamentId(tournament.id);
    return tournament.copyWith(status: tournament.getTournamentStatus(matches));
  }

  TournamentModel _tournamentFromRow(Map<String, dynamic> row) {
    final teamRows = (row['tournament_teams'] as List?) ?? const [];
    final memberRows = (row['tournament_members'] as List?) ?? const [];
    return TournamentModel(
      id: row['id'] as String,
      name: row['name'] as String,
      profile_img_url: row['profile_img_url'] as String?,
      banner_img_url: row['banner_img_url'] as String?,
      type: TournamentType.values.firstWhere((e) => e.value == row['type']),
      created_by: row['created_by'] as String,
      created_at: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : null,
      start_date: DateTime.parse(row['start_date'] as String),
      end_date: DateTime.parse(row['end_date'] as String),
      team_ids: teamRows.map((t) => (t as Map<String, dynamic>)['team_id'] as String).toList(),
      members: memberRows
          .map((m) => TournamentMember(
                id: (m as Map<String, dynamic>)['user_id'] as String,
                role: (m['role'] as String) == TournamentMemberRole.organizer.name
                    ? TournamentMemberRole.organizer
                    : TournamentMemberRole.admin,
              ))
          .toList(),
    );
  }

  TournamentTeamStat _teamStatFromRow(Map<String, dynamic> row) => TournamentTeamStat(
        team_id: row['team_id'] as String,
        points: row['points'] as int,
        wins: row['wins'] as int,
        losses: row['losses'] as int,
        nrr: (row['nrr'] as num).toDouble(),
        played_matches: row['played_matches'] as int,
      );

  PlayerKeyStat _playerKeyStatFromRow(Map<String, dynamic> row) => PlayerKeyStat(
        player_id: row['player_id'] as String,
        teamName: row['team_name'] as String,
        stats: UserStat.fromJson(row['stats'] as Map<String, dynamic>),
      );
}
