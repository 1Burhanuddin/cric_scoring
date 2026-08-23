import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/match/match_model.dart';
import '../../api/network/api_client.dart';
import '../../api/team/team_model.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../extensions/list_extensions.dart';
import '../../utils/dummy_deactivated_account.dart';
import '../team/team_service.dart';
import '../user/user_service.dart';

final matchServiceProvider = Provider(
  (ref) => MatchService(
    ref.read(apiClientProvider),
    ref.read(teamServiceProvider),
    ref.read(userServiceProvider),
  ),
);

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

class MatchService {
  final ApiClient _api;
  final TeamService _teamService;
  final UserService _userService;

  MatchService(this._api, this._teamService, this._userService);

  String get generateMatchId => const Uuid().v4().replaceAll('-', '');

  Future<MatchModel> getMatchById(String id) async {
    try {
      final json = await _api.get('/matches/$id') as Map<String, dynamic>?;
      if (json == null) return _emptyMatch();
      return _hydrate(MatchModel.fromJson(json));
    } on AppError catch (error) {
      if (error.statusCode == '404') return _emptyMatch();
      rethrow;
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
      final Map<String, MatchModel> byId = {};
      for (final teamId in teamIds) {
        final response = await _api.get('/matches/by-team/$teamId', query: {'limit': limit.toString()});
        for (final json in response as List) {
          final match = MatchModel.fromJson(json as Map<String, dynamic>);
          byId[match.id] = match;
        }
      }
      return Future.wait(byId.values.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<int> getUserOwnedMatchesCount(String userId) async {
    try {
      final response = await _api.get('/matches/owned-count', query: {'user_id': userId});
      return response as int;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel for matches yet (ball-by-ball scoring itself still
  /// runs on Firestore pending its own migration - see innings/ball_score/
  /// match_event/partnership services). This emits a single snapshot rather
  /// than live updates - callers still get a Stream so the UI doesn't change.
  Stream<MatchSetting?> streamMatchSetting(String matchId) async* {
    try {
      final json = await _api.get('/matches/$matchId/setting') as Map<String, dynamic>;
      yield MatchSetting.fromJson(json);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateMatchSetting(String matchId, MatchSetting settings) async {
    try {
      await _api.put('/matches/$matchId/setting', data: settings.toJson());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamUserRelatedMatches({
    required String userId,
    int limit = 10,
  }) async* {
    yield await _fetchByUser(userId, limit);
  }

  Stream<List<MatchModel>> streamUserMatches(String userId) async* {
    yield await _fetchByUser(userId, 100);
  }

  Future<List<MatchModel>> _fetchByUser(String userId, int limit) async {
    try {
      final response = await _api.get('/matches/by-user/$userId', query: {'limit': limit.toString()});
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      return Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamMatchesByTeamId({
    required String teamId,
    int limit = 10,
  }) async* {
    try {
      final response = await _api.get('/matches/by-team/$teamId', query: {'limit': limit.toString()});
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      yield await Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamActiveRunningMatches({int limit = 10}) async* {
    try {
      final response = await _api.get('/matches/active', query: {'limit': limit.toString()});
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      yield await Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamUpcomingMatches({int limit = 10}) async* {
    try {
      final response = await _api.get('/matches/upcoming', query: {'limit': limit.toString()});
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      yield await Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamFinishedMatches() async* {
    try {
      final response = await _api.get('/matches/finished');
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      yield await Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchModel>> getMatchesByStatus({
    required List<MatchStatus> status,
    String? lastMatchId,
    int limit = 10,
  }) async {
    if (status.isEmpty) return [];
    try {
      final response = await _api.get(
        '/matches/by-status',
        query: {
          'status': status.map((s) => s.value.toString()).toList(),
          'limit': limit.toString(),
        },
      );
      final matches = (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>));
      return Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<MatchModel> streamMatchById(String id) async* {
    yield await getMatchById(id);
  }

  Future<String> updateMatch(MatchModel match) async {
    try {
      final id = match.id.isNotEmpty ? match.id : generateMatchId;
      final response = await _api.put(
        '/matches/$id',
        data: {
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
          'start_time': match.start_time?.toIso8601String(),
          'start_at': match.start_at?.toIso8601String(),
          'ball_type': match.ball_type.value,
          'pitch_type': match.pitch_type.value,
          'created_by': match.created_by,
          'umpire_ids': match.umpire_ids ?? [],
          'scorer_ids': match.scorer_ids ?? [],
          'commentator_ids': match.commentator_ids ?? [],
          'referee_id': match.referee_id,
          'match_status': match.match_status.value,
          'teams': match.teams
              .map((t) => {
                    'team_id': t.team_id,
                    'captain_id': t.captain_id,
                    'admin_id': t.admin_id,
                    'over': t.over,
                    'run': t.run,
                    'wicket': t.wicket,
                    'squad': t.squad
                        .map((p) => {'id': p.id, 'status': p.status.value})
                        .toList(),
                  })
              .toList(),
        },
      );
      return (response as Map<String, dynamic>)['id'] as String;
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
      await _api.patch(
        '/matches/$matchId/toss',
        data: {
          'toss_winner_id': tossWinnerId,
          'toss_decision': tossDecision.value,
          'current_playing_team_id': currentPlayingTeam,
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    try {
      await _api.patch('/matches/$matchId/status', data: {'match_status': status.value});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateCurrentPlayingTeam({
    required String matchId,
    required String teamId,
  }) async {
    try {
      await _api.patch('/matches/$matchId/current-team', data: {'team_id': teamId});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTeamsSquad(
    String matchId,
    MatchTeamModel teamRequest,
  ) async {
    try {
      await _api.put(
        '/matches/$matchId/teams/${teamRequest.team_id}/squad',
        data: {
          'squad': teamRequest.squad.map((p) => {'id': p.id, 'status': p.status.value}).toList(),
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> setRevisedTarget({
    required String matchId,
    required RevisedTarget revisedTarget,
  }) async {
    try {
      await _api.patch(
        '/matches/$matchId/revised-target',
        data: {'runs': revisedTarget.runs, 'overs': revisedTarget.overs},
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> changeMatchOwner({
    required String matchId,
    required String ownerId,
  }) async {
    try {
      await _api.patch('/matches/$matchId/owner', data: {'owner_id': ownerId});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      await _api.delete('/matches/$matchId');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<MatchModel>> getMatchesByIds(List<String> matchIds) async {
    if (matchIds.isEmpty) return [];
    try {
      final matches = <MatchModel>[];
      for (final tenIds in matchIds.chunked(10)) {
        final response = await _api.get('/matches', query: {'ids': tenIds});
        matches.addAll(
          (response as List).map((json) => MatchModel.fromJson(json as Map<String, dynamic>)),
        );
      }
      return Future.wait(matches.map(_hydrate));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<MatchModel>> streamMatchesByIds(List<String> matchIds) async* {
    if (matchIds.isEmpty) {
      yield [];
      return;
    }
    yield await getMatchesByIds(matchIds);
  }

  // Helper Methods

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

  Future<List<UserModel>?> getUserListFromUserIds(List<String>? userIds) async {
    if (userIds == null) {
      return null;
    }
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
      final List<TeamModel> teams = await _teamService.getTeamsByIds(teamIds);

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
      final List<String> playerIds = players.map((player) => player.id).toSet().toList();
      final List<UserModel> users = await _userService.getUsersByIds(playerIds);

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
