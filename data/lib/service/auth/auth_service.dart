import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/network/api_client.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../extensions/string_extensions.dart';
import '../../storage/app_preferences.dart';
import '../../storage/provider/preferences_provider.dart';
import '../device/device_service.dart';

final authServiceProvider = Provider((ref) {
  return AuthService(
    ref.read(apiClientProvider),
    ref.read(deviceServiceProvider),
    ref.read(currentUserJsonPod.notifier),
    ref.read(currentUserSessionJsonPod.notifier),
    ref.read(accessTokenPod.notifier),
  );
});

class _AuthTokenResponse {
  final String accessToken;
  final UserModel user;
  final ApiSession session;

  _AuthTokenResponse({
    required this.accessToken,
    required this.user,
    required this.session,
  });

  factory _AuthTokenResponse.fromJson(Map<String, dynamic> json) =>
      _AuthTokenResponse(
        accessToken: json['access_token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        session: ApiSession.fromJson(json['session'] as Map<String, dynamic>),
      );
}

class AuthService {
  final ApiClient _api;
  final DeviceService _deviceService;

  final PreferenceNotifier<String?> _currentUserNotifier;
  final PreferenceNotifier<String?> _userSessionNotifier;
  final PreferenceNotifier<String?> _accessTokenNotifier;

  AuthService(
    this._api,
    this._deviceService,
    this._currentUserNotifier,
    this._userSessionNotifier,
    this._accessTokenNotifier,
  );

  bool get isSignedIn => _accessTokenNotifier.state != null;

  /// Sends the OTP via the backend (MSG91). There's no Firebase-style
  /// "auto verification completed" path with MSG91, so [onVerificationCompleted]
  /// is never invoked here - it's kept only so the sign-in screen's callback
  /// wiring doesn't need to change.
  Future<void> verifyPhoneNumber({
    required String countryCode,
    required String phoneNumber,
    Function(String, int?)? onCodeSent,
    Function()? onVerificationCompleted,
    Function(AppError)? onVerificationFailed,
    Function(String)? onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _api.post(
        '/auth/otp/send',
        data: {
          'country_code': countryCode,
          'phone_number': phoneNumber.caseAndSpaceInsensitive,
        },
      );
      // No real verification-id concept with MSG91; pass a non-null placeholder
      // so the OTP-entry screen's `verificationId != null` gate is satisfied.
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
      final deviceName = await _deviceService.deviceName;
      final appVersion = await _deviceService.appVersion;
      final osVersion = await _deviceService.osVersion;

      final response = await _api.post(
        '/auth/otp/verify',
        data: {
          'country_code': countryCode,
          'phone_number': phoneNumber.caseAndSpaceInsensitive,
          'otp': otp,
          'device_id': _deviceService.deviceId,
          'device_name': deviceName,
          'device_type': _deviceService.currentPlatformType(),
          'app_version': appVersion,
          'os_version': osVersion,
        },
      );

      final token =
          _AuthTokenResponse.fromJson(response as Map<String, dynamic>);

      _accessTokenNotifier.state = token.accessToken;
      _currentUserNotifier.state = token.user.toJsonString();
      _userSessionNotifier.state = token.session.toJsonString();
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
    // JWT sessions don't have Firebase's "requires recent login" re-auth
    // requirement, so this is now equivalent to a direct delete.
    await deleteAccount();
  }

  Future<void> clearSession() async {
    if (!isSignedIn) return;
    try {
      await _api.post('/auth/logout');
    } finally {
      _userSessionNotifier.state = null;
      _accessTokenNotifier.state = null;
    }
  }

  Future<void> registerDevice(String fcmToken) async {
    if (!isSignedIn) return;

    try {
      await _api.post('/auth/device', data: {'device_fcm_token': fcmToken});
      debugPrint('AuthService: registerDevice succeed with token $fcmToken');
    } catch (error) {
      debugPrint('AuthService: registerDevice error $error');
    }
  }

  Future<void> signOut() async {
    try {
      await clearSession();
      _currentUserNotifier.state = null;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _api.delete('/auth/account');
      _currentUserNotifier.state = null;
      _userSessionNotifier.state = null;
      _accessTokenNotifier.state = null;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
