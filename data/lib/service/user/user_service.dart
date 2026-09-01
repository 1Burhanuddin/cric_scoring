import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../api/network/supabase_client_provider.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../utils/dummy_deactivated_account.dart';

final userServiceProvider = Provider((ref) {
  return UserService(ref.read(supabaseClientProvider));
});

class UserService {
  final SupabaseClient _supabase;

  UserService(this._supabase);

  Future<UserModel?> getUser(String id) async {
    try {
      final row = await _supabase.from('users').select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return UserModel.fromJson(row);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// The `public.users` row for a freshly-signed-up account is created by
  /// the on_auth_user_created trigger (supabase/migrations), which runs
  /// server-side as part of the auth signup itself - this just reads it
  /// back, with one short retry in case that hasn't committed yet.
  Future<UserModel> getOrCreateProfile(String userId, {String? phone}) async {
    var user = await getUser(userId);
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      user = await getUser(userId);
    }
    return user ?? UserModel(id: userId, phone: phone);
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final rows = await _supabase.from('users').select().inFilter('id', ids);
      final users = rows.map((row) => UserModel.fromJson(row)).toList();

      final foundIds = users.map((u) => u.id).toSet();
      final missingIds = ids.where((id) => !foundIds.contains(id));
      users.addAll(missingIds.map((id) => deActiveDummyUserAccount(id)));

      return users;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<UserModel> streamUserById(String id) {
    try {
      return _supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((rows) => rows.isEmpty ? deActiveDummyUserAccount(id) : UserModel.fromJson(rows.first));
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<UserStat>?> streamUserStats(String userId) {
    try {
      return _supabase
          .from('user_stats')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((rows) => rows.isEmpty ? null : rows.map((r) => UserStat.fromJson(r)).toList());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<UserStat?> getUserStats(String userId, UserStatType type) async {
    try {
      final row = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .eq('type', type.name)
          .maybeSingle();
      return row == null ? null : UserStat.fromJson(row);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const SomethingWentWrongError();

      await _supabase.from('users').update({
        if (user.name != null) 'name': user.name,
        if (user.name != null) 'name_lowercase': user.name!.toLowerCase(),
        if (user.location != null) 'location': user.location,
        if (user.dob != null) 'dob': user.dob!.toIso8601String().split('T').first,
        if (user.email != null) 'email': user.email,
        if (user.profile_img_url != null) 'profile_img_url': user.profile_img_url,
        if (user.gender != null) 'gender': user.gender!.value,
        if (user.player_role != null) 'player_role': user.player_role!.value,
        if (user.batting_style != null) 'batting_style': user.batting_style!.value,
        if (user.bowling_style != null) 'bowling_style': user.bowling_style!.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateUserStats(String userId, UserStat stats) async {
    try {
      await _supabase.from('user_stats').upsert({
        'user_id': userId,
        'type': (stats.type ?? UserStatType.other).name,
        'matches': stats.matches,
        'batting': stats.batting.toJson(),
        'bowling': stats.bowling.toJson(),
        'fielding': stats.fielding.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,type');
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
      final rows = await _supabase
          .from('users')
          .select()
          .ilike('name_lowercase', '${searchKey.toLowerCase()}%')
          .order('id')
          .limit(limit);
      return rows.map((row) => UserModel.fromJson(row)).toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateUserNotificationSettings(
    String id,
    bool notifications,
  ) async {
    try {
      await _supabase.from('users').update({'notifications': notifications}).eq('id', id);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  // ---- devices (FCM tokens) ----------------------------------------------

  Future<void> registerDeviceRow(ApiSession session) async {
    try {
      await _supabase.from('user_devices').upsert({
        'user_id': session.user_id,
        'device_type': session.device_type,
        'device_id': session.device_id,
        'device_name': session.device_name,
        'app_version': session.app_version,
        'os_version': session.os_version,
      }, onConflict: 'user_id,device_id');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateDeviceFcmToken(String deviceId, String fcmToken) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('user_devices')
        .update({'device_fcm_token': fcmToken})
        .eq('user_id', userId)
        .eq('device_id', deviceId);
  }
}
