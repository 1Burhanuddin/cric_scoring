import 'package:cricheros_data/storage/provider/preferences_provider.dart';
import 'package:cricheros_data/utils/constant/firestore_constant.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cricheros/ui/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

const _baseUrl = 'https://apiv1-g7mqemn2ga-el.a.run.app/';
const appBaseUrl = 'https://khelo.canopas.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Edge-to-edge, transparent status/nav bars — the native theme used to
  // paint a solid brand-red strip here (khelo/android/.../styles.xml)
  // which read as a separate gray-ish system bar sitting above the app
  // instead of the app's own content simply extending under it, unlike a
  // web app with no native chrome at all.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final container = await _initContainer();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

Future<ProviderContainer> _initContainer() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DataConfig.init(
    DataConfig(
      apiBaseUrl: _baseUrl,
    ),
  );

  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  return container;
}
