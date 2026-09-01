import 'package:cricheros_data/storage/provider/preferences_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cricheros/ui/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

// CricHeros backend: Supabase (Postgres + Auth + Realtime). The anon key is
// meant to be public/embedded in the client - it's useless without the RLS
// policies in supabase/migrations, which are what actually gate access.
const _supabaseUrl = 'https://dyzujyzcnnujzkdkxufe.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR5enVqeXpjbm51anprZGt4dWZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyMzI4OTgsImV4cCI6MjEwMzgwODg5OH0.MqNkAW0agF7OwAnzaj2ldsTO4WHH_zHtBH7RJBszqvQ';

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

  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey);

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
