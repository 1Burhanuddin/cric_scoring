import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cric Scoring'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildUpcomingMatches(context),
              const SizedBox(height: 16),
              _buildRecentMatches(context),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard(
                context,
                icon: Icons.add_circle,
                label: 'Create Match',
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              _buildActionCard(
                context,
                icon: Icons.groups,
                label: 'Create Team',
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 10),
              _buildActionCard(
                context,
                icon: Icons.emoji_events,
                label: 'Create Tournament',
                color: const Color(0xFFFF6F00),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 115,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMatches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Matches',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildUpcomingMatchCard(
          context,
          teamA: 'Mumbai Indians',
          teamB: 'Chennai Super Kings',
          date: 'Dec 25, 2024',
          time: '7:30 PM',
          venue: 'Wankhede Stadium',
        ),
        const SizedBox(height: 8),
        _buildUpcomingMatchCard(
          context,
          teamA: 'Royal Challengers',
          teamB: 'Kolkata Knight Riders',
          date: 'Dec 26, 2024',
          time: '3:30 PM',
          venue: 'M. Chinnaswamy Stadium',
        ),
        const SizedBox(height: 8),
        _buildUpcomingMatchCard(
          context,
          teamA: 'Delhi Capitals',
          teamB: 'Punjab Kings',
          date: 'Dec 27, 2024',
          time: '7:30 PM',
          venue: 'Arun Jaitley Stadium',
        ),
      ],
    );
  }

  Widget _buildUpcomingMatchCard(
    BuildContext context, {
    required String teamA,
    required String teamB,
    required String date,
    required String time,
    required String venue,
  }) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      teamA,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'vs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      teamB,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$date • $time',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      venue,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMatches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Matches',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildRecentMatchCard(
          context,
          teamA: 'Mumbai Indians',
          teamAScore: '185/6',
          teamB: 'Chennai Super Kings',
          teamBScore: '178/8',
          winner: 'Mumbai Indians',
          result: 'won by 7 runs',
        ),
        const SizedBox(height: 8),
        _buildRecentMatchCard(
          context,
          teamA: 'Royal Challengers',
          teamAScore: '156/9',
          teamB: 'Kolkata Knight Riders',
          teamBScore: '160/4',
          winner: 'Kolkata Knight Riders',
          result: 'won by 6 wickets',
        ),
      ],
    );
  }

  Widget _buildRecentMatchCard(
    BuildContext context, {
    required String teamA,
    required String teamAScore,
    required String teamB,
    required String teamBScore,
    required String winner,
    required String result,
  }) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      teamA,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: teamA == winner
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                    ),
                  ),
                  Text(
                    teamAScore,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: teamA == winner
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      teamB,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: teamB == winner
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                    ),
                  ),
                  Text(
                    teamBScore,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: teamB == winner
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '$winner $result',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
