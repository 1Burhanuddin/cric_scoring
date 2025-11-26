import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/controllers/auth_controller.dart';
import 'package:cric_scoring/providers/user_provider.dart' as user_provider;
import 'package:cric_scoring/screens/profile/update_player_profile_screen.dart';
import 'package:cric_scoring/screens/admin/cleanup_firestore_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).value;
    final userAsync = ref.watch(user_provider.currentUserProvider);
    final theme = Theme.of(context);

    // Redirect to login if not authenticated
    if (authUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: userAsync.when(
        data: (user) {
          // If user document doesn't exist, create a basic profile view
          if (user == null) {
            return _buildBasicProfile(context, ref, authUser, theme);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (user.hasPlayerProfile) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Player Profile Complete',
                              style: TextStyle(
                                  color: Colors.green.shade900, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Player Profile Card
              if (user.hasPlayerProfile)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Player Profile',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoChip(
                                  'Jersey #${user.jerseyNumber}'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInfoChip(
                                  user.playerRole!.toUpperCase()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoChip('Batting: ${user.battingStyle}'),
                        if (user.bowlingStyle != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoChip('Bowling: ${user.bowlingStyle}'),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Profile options
              _buildProfileOption(
                context,
                icon: Icons.sports_cricket,
                title: user.hasPlayerProfile
                    ? 'Update Player Profile'
                    : 'Complete Player Profile',
                subtitle:
                    user.hasPlayerProfile ? null : 'Required to join teams',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdatePlayerProfileScreen(),
                    ),
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Navigate to notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  // TODO: Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to help
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: Show about dialog
                  showAboutDialog(
                    context: context,
                    applicationName: 'Cric Scoring',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.sports_cricket),
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.delete_sweep,
                title: 'Cleanup Firestore',
                subtitle: 'Delete old test data',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CleanupFirestoreScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Logout button
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBasicProfile(
      BuildContext context, WidgetRef ref, authUser, ThemeData theme) {
    // Try to create user document if it doesn't exist
    _createUserDocumentIfNeeded(authUser, ref);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _getInitial(authUser),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                authUser.displayName ?? 'User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authUser.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Setting up your profile...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Creating your user profile. This should only take a moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Force refresh
            ref.invalidate(user_provider.currentUserProvider);
          },
          child: const Text('Refresh'),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ),
      ],
    );
  }

  String _getInitial(authUser) {
    if (authUser.displayName != null && authUser.displayName!.isNotEmpty) {
      return authUser.displayName!.substring(0, 1).toUpperCase();
    }
    if (authUser.email != null && authUser.email!.isNotEmpty) {
      return authUser.email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Future<void> _createUserDocumentIfNeeded(authUser, WidgetRef ref) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc =
          await firestore.collection('users').doc(authUser.uid).get();

      if (!userDoc.exists) {
        // Create the user document
        await firestore.collection('users').doc(authUser.uid).set({
          'uid': authUser.uid,
          'email': authUser.email ?? '',
          'name': authUser.displayName ?? 'User',
          'role': 'viewer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Wait a moment for Firestore to propagate
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh the provider to fetch the newly created user
        ref.invalidate(user_provider.currentUserProvider);
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
