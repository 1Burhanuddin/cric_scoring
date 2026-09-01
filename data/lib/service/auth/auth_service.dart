import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../api/network/supabase_client_provider.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../device/device_service.dart';
import '../user/user_service.dart';
import '../../storage/app_preferences.dart';
import '../../storage/provider/preferences_provider.dart';

final authServiceProvider = Provider((ref) {
  return AuthService(
    ref.read(supabaseClientProvider),
    ref.read(userServiceProvider),
    ref.read(deviceServiceProvider),
    ref.read(currentUserJsonPod.notifier),
    ref.read(currentUserSessionJsonPod.notifier),
  );
});

class AuthService {
  final SupabaseClient _supabase;
  final UserService _userService;
  final DeviceService _deviceService;

  final PreferenceNotifier<String?> _currentUserNotifier;
  final PreferenceNotifier<String?> _userSessionNotifier;

  AuthService(
    this._supabase,
    this._userService,
    this._deviceService,
    this._currentUserNotifier,
    this._userSessionNotifier,
  );

  /// Supabase's own session (JWT + refresh token) is persisted and refreshed
  /// by the SDK itself - this is the authoritative check, not a locally
  /// managed token the way the old custom-backend version needed.
  bool get isSignedIn => _supabase.auth.currentSession != null;

  static String _e164(String countryCode, String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return countryCode.startsWith('+') ? '$countryCode$digits' : '+$countryCode$digits';
  }

  /// Sends the OTP via Supabase Auth (SMS provider configured in the
  /// Supabase dashboard - see Authentication > Providers > Phone). There's
  /// no Firebase-style "auto verification completed" path, so
  /// [onVerificationCompleted] is never invoked here - kept only so the
  /// sign-in screen's callback wiring doesn't need to change.
  Future<void> verifyPhoneNumber({
    required String countryCode,
    required String phoneNumber,
    Function(String, int?)? onCodeSent,
    Function()? onVerificationCompleted,
    Function(AppError)? onVerificationFailed,
    Function(String)? onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(phone: _e164(countryCode, phoneNumber));
      // No real verification-id concept with Supabase phone auth; pass a
      // non-null placeholder so the OTP-entry screen's
      // `verificationId != null` gate is satisfied.
      onCodeSent?.call('$countryCode-$phoneNumber', null);
    } catch (error, stack) {
      onVerificationFailed?.call(AppError.fromError(error, stack));
    }
  }

  Future<void> verifyOTP(
    String countryCode,
    String phoneNumber,
    String verificationId,
    String otp,
  ) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: _e164(countryCode, phoneNumber),
        token: otp,
      );

      final authUser = response.user;
      if (authUser == null) {
        throw const SomethingWentWrongError();
      }

      final user = await _userService.getOrCreateProfile(authUser.id, phone: authUser.phone);
      _currentUserNotifier.state = user.toJsonString();

      final deviceName = await _deviceService.deviceName;
      final appVersion = await _deviceService.appVersion;
      final osVersion = await _deviceService.osVersion;
      final session = ApiSession(
        id: _deviceService.deviceId,
        user_id: authUser.id,
        device_type: _deviceService.currentPlatformType(),
        device_id: _deviceService.deviceId,
        device_name: deviceName,
        app_version: appVersion,
        os_version: osVersion,
        created_at: DateTime.now(),
      );
      await _userService.registerDeviceRow(session);
      _userSessionNotifier.state = session.toJsonString();
    } on AppError {
      rethrow;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }

    // FCM registration is best-effort and must never fail sign-in: on some
    // devices FirebaseMessaging.getToken() throws FirebaseInstallationsException
    // (Google Play Services availability/network issues) rather than just
    // returning null, which would otherwise surface as a false "sign-in failed"
    // even though the account/session above was already created successfully.
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken == null) {
        debugPrint("AuthService: FCMToken is null");
        return;
      }
      await registerDevice(deviceToken);
    } catch (error) {
      debugPrint("AuthService: FCM registration failed (non-fatal) -> $error");
    }
  }

  Future<void> reAuthenticateAndDeleteAccount() async {
    // Supabase sessions don't have Firebase's "requires recent login"
    // re-auth requirement, so this is equivalent to a direct delete.
    await deleteAccount();
  }

  Future<void> clearSession() async {
    _userSessionNotifier.state = null;
  }

  Future<void> registerDevice(String fcmToken) async {
    if (!isSignedIn) return;
    try {
      await _userService.updateDeviceFcmToken(_deviceService.deviceId, fcmToken);
      debugPrint('AuthService: registerDevice succeed with token $fcmToken');
    } catch (error) {
      debugPrint('AuthService: registerDevice error $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await clearSession();
      _currentUserNotifier.state = null;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Row deletion + auth.users deletion both require elevated (service-
      // role) privileges beyond what the client's anon/authenticated key
      // can do directly - routed through a Postgres function invoked via
      // rpc(), which runs as security definer. See
      // supabase/migrations/20260901120100_rls_policies.sql's sibling
      // delete_own_account() function.
      await _supabase.rpc('delete_own_account');
      await _supabase.auth.signOut();
      _currentUserNotifier.state = null;
      _userSessionNotifier.state = null;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
