import 'package:flutter/material.dart';

class PlayerProfileOverviewScreen extends StatelessWidget {
  final String playerName;
  final String playerRole;

  const PlayerProfileOverviewScreen({
    super.key,
    required this.playerName,
    required this.playerRole,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Batting'),
              Tab(text: 'Bowling'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildBattingTab(context),
            _buildBowlingTab(context),
            _buildActivityTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPlayerHeader(context),
          const SizedBox(height: 12),
          _buildQuickStats(context),
          const SizedBox(height: 12),
          _buildCareerHighlights(context),
          const SizedBox(height: 12),
          _buildRecentForm(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Text(
              playerName.split(' ').map((e) => e[0]).join(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            playerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              playerRole,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(context, Icons.sports_cricket, 'Right-hand Bat'),
              const SizedBox(width: 8),
              _buildInfoChip(context, Icons.sports_baseball, 'Right-arm Fast'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(context, Icons.cake, '28 years'),
              const SizedBox(width: 8),
              _buildInfoChip(context, Icons.location_on, 'Mumbai'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(context, 'Runs', '12,344', Icons.sports_score),
              _buildStatCard(context, 'Wickets', '165', Icons.sports_baseball),
              _buildStatCard(context, 'Matches', '254', Icons.sports_cricket),
              _buildStatCard(context, 'Strike Rate', '138.5', Icons.speed),
              _buildStatCard(context, 'Economy', '7.2', Icons.trending_down),
              _buildStatCard(context, 'Best', '5/24', Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerHighlights(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Career Highlights',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          _buildHighlightCard(
            context,
            icon: Icons.star,
            title: 'Highest Score',
            value: '183*',
            subtitle: 'vs Australia, 2023',
          ),
          const SizedBox(height: 8),
          _buildHighlightCard(
            context,
            icon: Icons.sports_baseball,
            title: 'Best Bowling',
            value: '5/24',
            subtitle: 'vs England, 2022',
          ),
          const SizedBox(height: 8),
          _buildHighlightCard(
            context,
            icon: Icons.emoji_events,
            title: 'Player of the Match',
            value: '28 times',
            subtitle: 'Across all formats',
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Form',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFormBadge(context, '52', true),
              const SizedBox(width: 6),
              _buildFormBadge(context, '89', true),
              const SizedBox(width: 6),
              _buildFormBadge(context, '12', false),
              const SizedBox(width: 6),
              _buildFormBadge(context, '45', true),
              const SizedBox(width: 6),
              _buildFormBadge(context, '103', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormBadge(BuildContext context, String score, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isGood
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGood
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
              : Colors.red.shade200,
        ),
      ),
      child: Text(
        score,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isGood
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.red.shade700,
            ),
      ),
    );
  }

  Widget _buildBattingTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batting Statistics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(context, 'Total Runs', '12,344'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Batting Average', '48.2'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Strike Rate', '138.5'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Highest Score', '183*'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Centuries', '28'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Half Centuries', '45'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Fours', '1,234'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Sixes', '456'),
          const SizedBox(height: 16),
          Text(
            'Batting Against Teams',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          _buildTeamStatCard(context, 'vs Australia', '1,234 runs @ 52.3'),
          const SizedBox(height: 8),
          _buildTeamStatCard(context, 'vs England', '987 runs @ 45.8'),
          const SizedBox(height: 8),
          _buildTeamStatCard(context, 'vs South Africa', '876 runs @ 48.7'),
        ],
      ),
    );
  }

  Widget _buildBowlingTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bowling Statistics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          _buildDetailedStatCard(context, 'Total Wickets', '165'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Bowling Average', '28.4'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Economy Rate', '7.2'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Strike Rate', '23.6'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Best Bowling', '5/24'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, '5 Wicket Hauls', '3'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, '4 Wicket Hauls', '8'),
          const SizedBox(height: 8),
          _buildDetailedStatCard(context, 'Maidens', '12'),
          const SizedBox(height: 16),
          Text(
            'Bowling Against Teams',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          _buildTeamStatCard(context, 'vs Australia', '45 wickets @ 26.8'),
          const SizedBox(height: 8),
          _buildTeamStatCard(context, 'vs England', '38 wickets @ 29.2'),
          const SizedBox(height: 8),
          _buildTeamStatCard(context, 'vs South Africa', '32 wickets @ 27.5'),
        ],
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          icon: Icons.sports_cricket,
          title: 'Match Performance',
          subtitle: 'Scored 89 runs vs Chennai Super Kings',
          time: '2 days ago',
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.emoji_events,
          title: 'Achievement Unlocked',
          subtitle: 'Player of the Match Award',
          time: '2 days ago',
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.sports_baseball,
          title: 'Bowling Performance',
          subtitle: 'Took 3 wickets vs Royal Challengers',
          time: '5 days ago',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.trending_up,
          title: 'Career Milestone',
          subtitle: 'Reached 12,000 career runs',
          time: '1 week ago',
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.star,
          title: 'Century',
          subtitle: 'Scored 103* vs Kolkata Knight Riders',
          time: '2 weeks ago',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDetailedStatCard(
      BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStatCard(BuildContext context, String team, String stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.flag,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
