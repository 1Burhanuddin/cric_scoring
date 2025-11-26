import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/home_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/players_screen.dart';
import '../screens/teams_screen.dart';
import '../screens/tournaments_screen.dart';

import '../screens/stats_leaderboards_screen.dart';
import '../screens/firebase_test_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/profile_screen.dart';
import '../controllers/auth_controller.dart';

// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null;

      final isOnSplash = state.matchedLocation == '/splash';
      final isOnOnboarding = state.matchedLocation == '/onboarding';
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // If on splash, let it load
      if (isOnSplash) {
        return null;
      }

      // If on onboarding, let it show
      if (isOnOnboarding) {
        return null;
      }

      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isOnAuth) {
        return '/login';
      }

      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && isOnAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Navigation with Bottom Nav Bar
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/matches',
            name: 'matches',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MatchesScreen(),
            ),
          ),
          GoRoute(
            path: '/players',
            name: 'players',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PlayersScreen(),
            ),
          ),
          GoRoute(
            path: '/teams',
            name: 'teams',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TeamsScreen(),
            ),
          ),
          GoRoute(
            path: '/tournaments',
            name: 'tournaments',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TournamentsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // Stats Screen
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsLeaderboardsScreen(),
      ),

      // Firebase Test Screen
      GoRoute(
        path: '/firebase-test',
        name: 'firebase-test',
        builder: (context, state) => const FirebaseTestScreen(),
      ),
    ],
  );
});
