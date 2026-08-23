import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/network/api_client.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../utils/dummy_deactivated_account.dart';

final userServiceProvider = Provider((ref) {
  return UserService(ref.read(apiClientProvider));
});

class UserService {
  final ApiClient _api;

  UserService(this._api);

  Future<UserModel?> getUser(String id) async {
    try {
      final response = await _api.get('/users/$id');
      if (response == null) return null;
      return UserModel.fromJson(response as Map<String, dynamic>);
    } on AppError catch (error) {
      if (error.statusCode == '404') return null;
      rethrow;
    }
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await _api.get('/users', query: {'ids': ids});
      final users = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final foundIds = users.map((u) => u.id).toSet();
      final missingIds = ids.where((id) => !foundIds.contains(id));
      users.addAll(missingIds.map((id) => deActiveDummyUserAccount(id)));

      return users;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel for user profiles yet (Stage 2 adds websockets for
  /// the live-scoring domains first). This emits a single snapshot rather
  /// than live updates - callers still get a Stream so the UI doesn't change.
  Stream<UserModel> streamUserById(String id) async* {
    try {
      final user = await getUser(id);
      yield user ?? deActiveDummyUserAccount(id);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// See streamUserById - single snapshot, not live, until Stage 2.
  Stream<List<UserStat>?> streamUserStats(String userId) async* {
    try {
      final stats = await _fetchUserStats(userId);
      yield stats.isEmpty ? null : stats;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<UserStat?> getUserStats(String userId, UserStatType type) async {
    try {
      final stats = await _fetchUserStats(userId);
      for (final stat in stats) {
        if (stat.type == type) return stat;
      }
      return null;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<UserStat>> _fetchUserStats(String userId) async {
    final response = await _api.get('/users/$userId/stats');
    return (response as List)
        .map((json) => UserStat.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _api.patch(
        '/users/me',
        data: {
          if (user.name != null) 'name': user.name,
          if (user.location != null) 'location': user.location,
          if (user.dob != null) 'dob': user.dob!.toIso8601String().split('T').first,
          if (user.email != null) 'email': user.email,
          if (user.profile_img_url != null) 'profile_img_url': user.profile_img_url,
          if (user.gender != null) 'gender': user.gender!.value,
          if (user.player_role != null) 'player_role': user.player_role!.value,
          if (user.batting_style != null) 'batting_style': user.batting_style!.value,
          if (user.bowling_style != null) 'bowling_style': user.bowling_style!.value,
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateUserStats(String userId, UserStat stats) async {
    try {
      await _api.put(
        '/users/$userId/stats',
        data: {
          'matches': stats.matches,
          'type': (stats.type ?? UserStatType.other).name,
          'batting': stats.batting.toJson(),
          'bowling': stats.bowling.toJson(),
          'fielding': stats.fielding.toJson(),
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<UserModel>> searchUser(
    String searchKey, {
    int limit = 20,
    String? lastUserId,
  }) async {
    try {
      final response = await _api.get(
        '/users/search/by-name',
        query: {'q': searchKey, 'limit': limit.toString()},
      );
      return (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateUserNotificationSettings(
    String id,
    bool notifications,
  ) async {
    try {
      await _api.patch('/users/me/notifications', data: {'notifications': notifications});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
