import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/match/match_model.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../utils/dummy_deactivated_account.dart';
import '../team/team_service.dart';
import '../user/user_service.dart';

final matchServiceProvider = Provider(
  (ref) => MatchService(
    ref.read(supabaseClientProvider),
    ref.read(teamServiceProvider),
    ref.read(userServiceProvider),
  ),
);

const _matchSelect = '*, match_teams(*, match_players(user_id, status, performance))';

class MatchService {
  final SupabaseClient _supabase;
  final TeamService _teamService;
  final UserService _userService;

  MatchService(this._supabase, this._teamService, this._userService);

  String get generateMatchId => const Uuid().v4().replaceAll('-', '');

  Future<MatchModel> getMatchById(String id) async {
    try {
      final row = await _supabase.from('matches').select(_matchSelect).eq('id', id).maybeSingle();
      if (row == null) return _emptyMatch();
      return _hydrate(_matchFromRow(row));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchModel>> getMatchByTeamIds({
    required List<String> teamIds,
    int limit = 20,
    String? lastMatchId,
  }) async {
    try {
      final rows = await _supabase
          .from('match_teams')
          .select('match_id, matches!inner($_matchSelect)')
          .inFilter('team_id', teamIds)
          .order('match_id')
          .limit(limit);
      final matches = rows.map((r) => _matchFromRow(r['matches'] as Map<String, dynamic>)).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<int> getUserOwnedMatchesCount(String userId) async {
    try {
      final rows = await _supabase.from('matches').select('id').eq('created_by', userId);
      return rows.length;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<MatchSetting?> streamMatchSetting(String matchId) {
    try {
      return _supabase
          .from('match_settings')
          .stream(primaryKey: ['match_id'])
          .eq('match_id', matchId)
          .map((rows) => rows.isEmpty ? null : _matchSettingFromRow(rows.first));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateMatchSetting(String matchId, MatchSetting settings) async {
    try {
      await _supabase.from('match_settings').upsert({
        'match_id': matchId,
        'continue_with_injured_player': settings.continue_with_injured_player,
        'show_wagon_wheel_for_less_run': settings.show_wagon_wheel_for_less_run,
        'show_wagon_wheel_for_dot_ball': settings.show_wagon_wheel_for_dot_ball,
      }, onConflict: 'match_id');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamUserRelatedMatches({
    required String userId,
    int limit = 10,
  }) {
    return _pollMatches(() async {
      final createdRows = await _supabase.from('matches').select(_matchSelect).eq('created_by', userId);
      final playedRows = await _supabase
          .from('match_players')
          .select('match_teams!inner(match_id, matches!inner($_matchSelect))')
          .eq('user_id', userId);

      final byId = <String, Map<String, dynamic>>{};
      for (final row in createdRows) {
        byId[row['id'] as String] = row;
      }
      for (final row in playedRows) {
        final match = (row['match_teams'] as Map<String, dynamic>)['matches'] as Map<String, dynamic>;
        byId[match['id'] as String] = match;
      }
      final matches = byId.values.map(_matchFromRow).take(limit).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Stream<List<MatchModel>> streamUserMatches(String userId) {
    return _pollMatches(() async {
      final rows = await _supabase
          .from('match_players')
          .select('match_teams!inner(matches!inner($_matchSelect))')
          .eq('user_id', userId);
      final matches = rows
          .map((r) => _matchFromRow(
              ((r['match_teams'] as Map<String, dynamic>)['matches']) as Map<String, dynamic>))
          .toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Stream<List<MatchModel>> streamMatchesByTeamId({
    required String teamId,
    int limit = 10,
  }) {
    return _pollMatches(() async {
      final rows = await _supabase
          .from('match_teams')
          .select('matches!inner($_matchSelect)')
          .eq('team_id', teamId)
          .order('match_id')
          .limit(limit);
      final matches = rows.map((r) => _matchFromRow(r['matches'] as Map<String, dynamic>)).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Stream<List<MatchModel>> streamActiveRunningMatches({int limit = 10}) {
    return _pollMatches(() async {
      final cutoff = DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toUtc();
      final rows = await _supabase
          .from('matches')
          .select(_matchSelect)
          .eq('match_status', MatchStatus.running.value)
          .gt('updated_at', cutoff.toIso8601String())
          .limit(limit);
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Stream<List<MatchModel>> streamUpcomingMatches({int limit = 10}) {
    return _pollMatches(() async {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
      final aMonthAfter = DateTime(now.year, now.month + 1, now.day).toUtc();
      final rows = await _supabase
          .from('matches')
          .select(_matchSelect)
          .eq('match_status', MatchStatus.yetToStart.value)
          .gte('start_at', startOfDay.toIso8601String())
          .lte('start_at', aMonthAfter.toIso8601String())
          .limit(limit);
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Stream<List<MatchModel>> streamFinishedMatches() {
    return _pollMatches(() async {
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 15)).toUtc();
      final rows = await _supabase
          .from('matches')
          .select(_matchSelect)
          .eq('match_status', MatchStatus.finish.value)
          .gt('updated_at', cutoff.toIso8601String());
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  Future<List<MatchModel>> getMatchesByStatus({
    required List<MatchStatus> status,
    String? lastMatchId,
    int limit = 10,
  }) async {
    if (status.isEmpty) return [];
    try {
      final rows = await _supabase
          .from('matches')
          .select(_matchSelect)
          .inFilter('match_status', status.map((e) => e.value).toList())
          .order('id')
          .limit(limit);
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<MatchModel> streamMatchById(String id) {
    try {
      return _supabase.from('matches').stream(primaryKey: ['id']).eq('id', id).asyncMap((rows) async {
        if (rows.isEmpty) return _emptyMatch();
        final full = await _supabase.from('matches').select(_matchSelect).eq('id', id).single();
        return _hydrate(_matchFromRow(full));
      });
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<String> updateMatch(MatchModel match) async {
    try {
      final id = match.id.isNotEmpty ? match.id : generateMatchId;
      await _supabase.from('matches').upsert({
        'id': id,
        'tournament_id': match.tournament_id,
        'match_group': match.match_group?.value,
        'match_group_number': match.match_group_number,
        'match_type': match.match_type.value,
        'number_of_over': match.number_of_over,
        'over_per_bowler': match.over_per_bowler,
        'team_creator_ids': match.team_creator_ids,
        'power_play_overs1': match.power_play_overs1,
        'power_play_overs2': match.power_play_overs2,
        'power_play_overs3': match.power_play_overs3,
        'city': match.city,
        'ground': match.ground,
        'start_time': match.start_time?.toUtc().toIso8601String(),
        'start_at': match.start_at?.toUtc().toIso8601String(),
        'ball_type': match.ball_type.value,
        'pitch_type': match.pitch_type.value,
        'created_by': match.created_by,
        'umpire_ids': match.umpire_ids ?? [],
        'scorer_ids': match.scorer_ids ?? [],
        'commentator_ids': match.commentator_ids ?? [],
        'referee_id': match.referee_id,
        'match_status': match.match_status.value,
      });

      await _supabase.from('match_teams').delete().eq('match_id', id);
      for (final team in match.teams) {
        final matchTeam = await _supabase
            .from('match_teams')
            .insert({
              'match_id': id,
              'team_id': team.team_id,
              'captain_id': team.captain_id,
              'admin_id': team.admin_id,
              'over': team.over,
              'run': team.run,
              'wicket': team.wicket,
            })
            .select('id')
            .single();
        if (team.squad.isNotEmpty) {
          await _supabase.from('match_players').insert(
                team.squad
                    .map((p) => {
                          'match_team_id': matchTeam['id'],
                          'user_id': p.id,
                          'status': p.status.value,
                          'performance': p.performance.map((e) => e.toJson()).toList(),
                        })
                    .toList(),
              );
        }
      }

      return id;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTossDetails(
    String matchId,
    String tossWinnerId,
    TossDecision tossDecision,
    String currentPlayingTeam,
  ) async {
    try {
      await _supabase.from('matches').update({
        'toss_winner_id': tossWinnerId,
        'toss_decision': tossDecision.value,
        'current_playing_team_id': currentPlayingTeam,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    try {
      await _supabase.from('matches').update({
        'match_status': status.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateCurrentPlayingTeam({
    required String matchId,
    required String teamId,
  }) async {
    try {
      await _supabase.from('matches').update({
        'current_playing_team_id': teamId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTeamsSquad(
    String matchId,
    MatchTeamModel teamRequest,
  ) async {
    try {
      final matchTeam = await _supabase
          .from('match_teams')
          .select('id')
          .eq('match_id', matchId)
          .eq('team_id', teamRequest.team_id)
          .maybeSingle();
      if (matchTeam == null) return;

      final existing = await _supabase
          .from('match_players')
          .select('user_id')
          .eq('match_team_id', matchTeam['id']);
      final existingIds = existing.map((r) => r['user_id'] as String).toSet();

      for (final player in teamRequest.squad) {
        if (existingIds.contains(player.id)) {
          await _supabase
              .from('match_players')
              .update({'status': player.status.value, 'performance': player.performance.map((e) => e.toJson()).toList()})
              .eq('match_team_id', matchTeam['id'])
              .eq('user_id', player.id);
        } else {
          await _supabase.from('match_players').insert({
            'match_team_id': matchTeam['id'],
            'user_id': player.id,
            'status': player.status.value,
            'performance': player.performance.map((e) => e.toJson()).toList(),
          });
        }
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> setRevisedTarget({
    required String matchId,
    required RevisedTarget revisedTarget,
  }) async {
    try {
      await _supabase.from('matches').update({
        'revised_target': {
          'runs': revisedTarget.runs,
          'overs': revisedTarget.overs,
          'time': revisedTarget.time?.toUtc().toIso8601String(),
          'revised_time': revisedTarget.revised_time?.toUtc().toIso8601String(),
        },
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> changeMatchOwner({
    required String matchId,
    required String ownerId,
  }) async {
    try {
      await _supabase.from('matches').update({'created_by': ownerId}).eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      await _supabase.from('matches').delete().eq('id', matchId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchModel>> getMatchesByIds(List<String> matchIds) async {
    if (matchIds.isEmpty) return [];
    try {
      final rows = await _supabase.from('matches').select(_matchSelect).inFilter('id', matchIds);
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamMatchesByIds(List<String> matchIds) {
    if (matchIds.isEmpty) return Stream.value([]);
    return _pollMatches(() async {
      final rows = await _supabase.from('matches').select(_matchSelect).inFilter('id', matchIds);
      final matches = rows.map(_matchFromRow).toList();
      return Future.wait(matches.map(_hydrateTeamsOnly));
    });
  }

  // ---- helpers --------------------------------------------------------

  /// No realtime channel for the hydrated (team/user-joined) match list
  /// queries yet - Supabase Realtime can watch a raw table but the app needs
  /// the joined+hydrated shape, so this emits once immediately. Single-row
  /// reads (streamMatchById/streamMatchSetting) do use a real Supabase
  /// Realtime channel via .stream().
  Stream<List<MatchModel>> _pollMatches(Future<List<MatchModel>> Function() fetch) async* {
    try {
      yield await fetch();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  MatchModel _emptyMatch() => MatchModel(
        id: '',
        teams: [],
        match_type: MatchType.limitedOvers,
        number_of_over: 0,
        over_per_bowler: 0,
        city: '',
        ground: '',
        start_time: DateTime.now(),
        start_at: DateTime.now(),
        ball_type: BallType.leather,
        pitch_type: PitchType.turf,
        created_by: '',
        match_status: MatchStatus.running,
        updated_at: DateTime.now(),
      );

  MatchSetting _matchSettingFromRow(Map<String, dynamic> row) => MatchSetting(
        continue_with_injured_player: row['continue_with_injured_player'] as bool,
        show_wagon_wheel_for_less_run: row['show_wagon_wheel_for_less_run'] as bool,
        show_wagon_wheel_for_dot_ball: row['show_wagon_wheel_for_dot_ball'] as bool,
      );

  MatchModel _matchFromRow(Map<String, dynamic> row) {
    final teamRows = (row['match_teams'] as List?) ?? const [];
    return MatchModel(
      id: row['id'] as String,
      teams: teamRows.map((t) => _matchTeamFromRow(t as Map<String, dynamic>)).toList(),
      tournament_id: row['tournament_id'] as String?,
      match_group: row['match_group'] != null
          ? MatchGroup.values.firstWhere((e) => e.value == row['match_group'])
          : null,
      match_group_number: row['match_group_number'] as int?,
      match_type: MatchType.values.firstWhere((e) => e.value == row['match_type']),
      number_of_over: row['number_of_over'] as int,
      over_per_bowler: row['over_per_bowler'] as int,
      team_ids: teamRows.map((t) => (t as Map<String, dynamic>)['team_id'] as String).toList(),
      team_creator_ids: ((row['team_creator_ids'] as List?) ?? const []).cast<String>(),
      power_play_overs1: ((row['power_play_overs1'] as List?) ?? const []).cast<int>(),
      power_play_overs2: ((row['power_play_overs2'] as List?) ?? const []).cast<int>(),
      power_play_overs3: ((row['power_play_overs3'] as List?) ?? const []).cast<int>(),
      city: row['city'] as String,
      ground: row['ground'] as String,
      start_time: row['start_time'] != null ? DateTime.parse(row['start_time'] as String) : null,
      start_at: row['start_at'] != null ? DateTime.parse(row['start_at'] as String) : null,
      ball_type: BallType.values.firstWhere((e) => e.value == row['ball_type']),
      pitch_type: PitchType.values.firstWhere((e) => e.value == row['pitch_type']),
      created_by: row['created_by'] as String,
      umpire_ids: ((row['umpire_ids'] as List?) ?? const []).cast<String>(),
      scorer_ids: ((row['scorer_ids'] as List?) ?? const []).cast<String>(),
      commentator_ids: ((row['commentator_ids'] as List?) ?? const []).cast<String>(),
      referee_id: row['referee_id'] as String?,
      match_status: MatchStatus.values.firstWhere((e) => e.value == row['match_status']),
      toss_decision: row['toss_decision'] != null
          ? TossDecision.values.firstWhere((e) => e.value == row['toss_decision'])
          : null,
      toss_winner_id: row['toss_winner_id'] as String?,
      current_playing_team_id: row['current_playing_team_id'] as String?,
      revised_target: row['revised_target'] != null
          ? RevisedTarget(
              runs: (row['revised_target']['runs'] as num?)?.toInt() ?? 0,
              overs: (row['revised_target']['overs'] as num?)?.toDouble() ?? 0,
              time: row['revised_target']['time'] != null
                  ? DateTime.parse(row['revised_target']['time'] as String)
                  : null,
              revised_time: row['revised_target']['revised_time'] != null
                  ? DateTime.parse(row['revised_target']['revised_time'] as String)
                  : null,
            )
          : null,
      updated_at: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : null,
    );
  }

  MatchTeamModel _matchTeamFromRow(Map<String, dynamic> row) {
    final squadRows = (row['match_players'] as List?) ?? const [];
    return MatchTeamModel(
      team_id: row['team_id'] as String,
      captain_id: row['captain_id'] as String?,
      admin_id: row['admin_id'] as String?,
      over: (row['over'] as num).toDouble(),
      run: row['run'] as int,
      wicket: row['wicket'] as int,
      squad: squadRows
          .map((p) => MatchPlayer(
                id: (p as Map<String, dynamic>)['user_id'] as String,
                status: PlayerStatus.values.firstWhere((e) => e.value == p['status'], orElse: () => PlayerStatus.played),
                performance: ((p['performance'] as List?) ?? const [])
                    .map((e) => PlayerPerformance.fromJson(e as Map<String, dynamic>))
                    .toList(),
              ))
          .toList(),
    );
  }

  Future<MatchModel> _hydrate(MatchModel match) async {
    final teams = await getTeamsList(match.teams);
    final umpires = await getUserListFromUserIds(match.umpire_ids);
    final commentators = await getUserListFromUserIds(match.commentator_ids);
    final scorers = await getUserListFromUserIds(match.scorer_ids);
    UserModel? referee;
    if (match.referee_id != null) {
      referee = await _userService.getUser(match.referee_id!);
    }
    return match.copyWith(
      teams: teams,
      commentators: commentators,
      referee: referee,
      scorers: scorers,
      umpires: umpires,
    );
  }

  Future<MatchModel> _hydrateTeamsOnly(MatchModel match) async {
    final teams = await getTeamsList(match.teams);
    return match.copyWith(teams: teams);
  }

  Future<List<UserModel>?> getUserListFromUserIds(List<String>? userIds) async {
    if (userIds == null) return null;
    try {
      return await _userService.getUsersByIds(userIds);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchTeamModel>> getTeamsList(
    List<MatchTeamModel> teamList,
  ) async {
    try {
      final teamIds = teamList.map((e) => e.team_id).toList();
      final teams = await _teamService.getTeamsByIds(teamIds);

      return await Future.wait(
        teamList.map((matchPlayer) async {
          final team = teams.firstWhere(
            (element) => element.id == matchPlayer.team_id,
            orElse: () => deActiveDummyTeamModel(matchPlayer.team_id),
          );
          final squad = await getPlayerListFromPlayerIds(matchPlayer.squad);
          return matchPlayer.copyWith(team: team, squad: squad);
        }),
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchPlayer>> getPlayerListFromPlayerIds(
    List<MatchPlayer> players,
  ) async {
    try {
      final playerIds = players.map((player) => player.id).toSet().toList();
      final users = await _userService.getUsersByIds(playerIds);
      return players.map((matchPlayer) {
        final user = users.firstWhere(
          (user) => user.id == matchPlayer.id,
          orElse: () => deActiveDummyUserAccount(matchPlayer.id),
        );
        return matchPlayer.copyWith(player: user);
      }).toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
