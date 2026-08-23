import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/network/api_client.dart';
import '../../api/team/team_model.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../utils/dummy_deactivated_account.dart';
import '../user/user_service.dart';

final teamServiceProvider = Provider(
  (ref) => TeamService(ref.read(apiClientProvider), ref.read(userServiceProvider)),
);

class TeamService {
  final ApiClient _api;
  final UserService _userService;

  TeamService(this._api, this._userService);

  String get generateTeamId => const Uuid().v4().replaceAll('-', '');

  Future<TeamModel> getTeamById(String teamId) async {
    try {
      final json = await _api.get('/teams/$teamId') as Map<String, dynamic>?;
      if (json == null) return deActiveDummyTeamModel(teamId);
      return fetchDetailsOfTeam(TeamModel.fromJson(json));
    } on AppError catch (error) {
      if (error.statusCode == '404') return deActiveDummyTeamModel(teamId);
      rethrow;
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

  /// No realtime channel for team documents yet (Stage 2 adds websockets for
  /// the live-scoring domains first). This emits a single snapshot rather
  /// than live updates - callers still get a Stream so the UI doesn't change.
  Stream<TeamModel> streamTeamById(String teamId) async* {
    yield await getTeamById(teamId);
  }

  Future<TeamStat> getTeamStatById(String teamId) async {
    try {
      final json = await _api.get('/teams/$teamId/stat') as Map<String, dynamic>;
      return TeamStat.fromJson(json);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<TeamModel>> streamUserRelatedTeams({
    required String userId,
    int limit = 10,
  }) async* {
    try {
      final teams = await _rawTeamsByMember(userId);
      yield await Future.wait(teams.take(limit).map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<TeamModel>> streamUserOwnedTeams(String userId) async* {
    try {
      final teams = await _rawTeamsByMember(userId);
      final owned = teams.where(
        (t) =>
            t.created_by == userId ||
            t.players.any((p) => p.id == userId && p.role == TeamPlayerRole.admin),
      );
      yield await Future.wait(owned.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<TeamModel>> streamUserRelatedTeamsByUserId(String userId) async* {
    try {
      final teams = await _rawTeamsByMember(userId);
      yield await Future.wait(teams.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<String> updateTeam(TeamModel team) async {
    try {
      final response = await _api.put(
        '/teams/${team.id}',
        data: {
          'name': team.name,
          'city': team.city,
          'name_initial': team.name_initial,
          'profile_img_url': team.profile_img_url,
          'created_by': team.created_by,
          'team_players':
              team.players.map((p) => {'id': p.id, 'role': p.role.name}).toList(),
        },
      );
      return (response as Map<String, dynamic>)['id'] as String;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateProfileImageUrl(String teamId, String? imageUrl) async {
    try {
      await _api.patch('/teams/$teamId', data: {'profile_img_url': imageUrl});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateTeamStat(String teamId, TeamStat stat) async {
    try {
      await _api.put(
        '/teams/$teamId/stat',
        data: {
          'played': stat.played,
          'status': {
            'win': stat.status.win,
            'tie': stat.status.tie,
            'lost': stat.status.lost,
          },
          'runs': stat.runs,
          'wickets': stat.wickets,
          'batting_average': stat.batting_average,
          'bowling_average': stat.bowling_average,
          'highest_runs': stat.highest_runs,
          'lowest_runs': stat.lowest_runs,
          'run_rate': stat.run_rate,
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> addPlayersToTeam(String teamId, List<TeamPlayer> players) async {
    try {
      await _api.post(
        '/teams/$teamId/players',
        data: {'players': players.map((e) => {'id': e.id, 'role': e.role.name}).toList()},
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
      await _api.put(
        '/teams/$teamId/players',
        data: {
          'owner_id': ownerId,
          'players': players.map((e) => {'id': e.id, 'role': e.role.name}).toList(),
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> removePlayersFromTeam(
    String teamId,
    List<TeamPlayer> players,
  ) async {
    try {
      await _api.delete(
        '/teams/$teamId/players',
        data: {'players': players.map((e) => {'id': e.id, 'role': e.role.name}).toList()},
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<bool> isTeamNameAvailable(String teamName) async {
    try {
      final response = await _api.get('/teams/name-available', query: {'name': teamName});
      return response as bool;
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
      final response = await _api.get(
        '/teams/search',
        query: {'q': searchKey, 'limit': limit.toString()},
      );
      final teams = (response as List)
          .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Future.wait(teams.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await _api.delete('/teams/$teamId');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<TeamModel>> getTeamsByIds(List<String> teamIds) async {
    try {
      if (teamIds.isEmpty) return [];
      final response = await _api.get('/teams', query: {'ids': teamIds});
      final teams = (response as List)
          .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Future.wait(teams.map(fetchDetailsOfTeam));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  // Helper methods

  Future<List<TeamModel>> _rawTeamsByMember(String userId) async {
    final response = await _api.get('/teams/by-member/$userId');
    return (response as List)
        .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
        .toList();
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
