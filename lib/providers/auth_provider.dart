import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth State Model
class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? userName;
  final String? userRole;

  const AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.userName,
    this.userRole,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? userName,
    String? userRole,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Login method (to be implemented with Firebase in Phase 3)
  Future<void> login(String email, String password) async {
    // Simulate login - will be replaced with Firebase Auth
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isLoggedIn: true,
      userId: 'demo-user-id',
      userName: 'Demo User',
      userRole: 'admin',
    );
  }

  // Logout method
  Future<void> logout() async {
    state = const AuthState();
  }

  // Check if user is logged in (for demo, always return true)
  void checkAuthStatus() {
    // For Phase 1 demo, auto-login
    state = state.copyWith(
      isLoggedIn: true,
      userId: 'demo-user-id',
      userName: 'Demo User',
      userRole: 'admin',
    );
  }
}

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
