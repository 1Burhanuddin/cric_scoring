import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/controllers/auth_controller.dart';
import 'package:cric_scoring/providers/user_provider.dart' as user_provider;
import 'package:cric_scoring/providers/player_stats_provider.dart';
import 'package:cric_scoring/screens/profile/update_player_profile_screen.dart';

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
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sports_cricket,
                                color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Player Profile',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Jersey and Role in a row
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                theme,
                                icon: Icons.tag,
                                label: 'Jersey',
                                value: '#${user.jerseyNumber}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoItem(
                                theme,
                                icon: Icons.person,
                                label: 'Role',
                                value: user.playerRole!.toUpperCase(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Batting Style
                        _buildInfoItem(
                          theme,
                          icon: Icons.sports_cricket,
                          label: 'Batting',
                          value: user.battingStyle ?? 'Not specified',
                        ),
                        if (user.bowlingStyle != null) ...[
                          const SizedBox(height: 12),
                          // Bowling Style
                          _buildInfoItem(
                            theme,
                            icon: Icons.sports_baseball,
                            label: 'Bowling',
                            value: user.bowlingStyle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Player Statistics Section
              if (user.hasPlayerProfile) ...[
                Text(
                  'STATISTICS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatsCard(context, theme, ref),
                const SizedBox(height: 24),
              ],

              // Account Section
              Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              _buildProfileOption(
                context,
                theme,
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
                theme,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your name and email',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // App Section
              Text(
                'APP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              _buildProfileOption(
                context,
                theme,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              _buildProfileOption(
                context,
                theme,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Cric Scoring',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(Icons.sports_cricket,
                        size: 48, color: theme.colorScheme.primary),
                    children: [
                      const Text(
                          'A comprehensive cricket scoring application for managing matches, teams, and players.'),
                    ],
                  );
                },
              ),

              _buildProfileOption(
                context,
                theme,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Logout button
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade400),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatsCard(BuildContext context, ThemeData theme, WidgetRef ref) {
    final statsAsync = ref.watch(currentUserStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No statistics available yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Career Stats',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${stats.matchesPlayed} Matches',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Batting Stats
                Text(
                  'BATTING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Runs',
                        value: stats.totalRuns.toString(),
                        icon: Icons.sports_score,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Average',
                        value: stats.battingAverage.toStringAsFixed(1),
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Strike Rate',
                        value: stats.strikeRate.toStringAsFixed(1),
                        icon: Icons.speed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'High Score',
                        value: stats.highestScore.toString(),
                        icon: Icons.star,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: '50s / 100s',
                        value: '${stats.fifties} / ${stats.hundreds}',
                        icon: Icons.emoji_events,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: '4s / 6s',
                        value: '${stats.fours} / ${stats.sixes}',
                        icon: Icons.sports_cricket,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bowling Stats
                Text(
                  'BOWLING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Wickets',
                        value: stats.totalWickets.toString(),
                        icon: Icons.sports_baseball,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Average',
                        value: stats.bowlingAverage.toStringAsFixed(1),
                        icon: Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Economy',
                        value: stats.economy.toStringAsFixed(2),
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Best',
                        value: stats.bestBowling ?? '-',
                        icon: Icons.military_tech,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: '4W / 5W',
                        value: '${stats.fourWickets} / ${stats.fiveWickets}',
                        icon: Icons.workspace_premium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Maidens',
                        value: stats.maidens.toString(),
                        icon: Icons.block,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Fielding Stats
                Text(
                  'FIELDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Catches',
                        value: stats.catches.toString(),
                        icon: Icons.pan_tool,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Run Outs',
                        value: stats.runOuts.toString(),
                        icon: Icons.directions_run,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        theme,
                        label: 'Stumpings',
                        value: stats.stumpings.toString(),
                        icon: Icons.sports_kabaddi,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading stats: $error'),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
