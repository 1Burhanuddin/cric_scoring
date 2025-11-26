import 'package:flutter/material.dart';
import 'player_profile_screen.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: _buildPlayersList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search players',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(BuildContext context) {
    final players = [
      {
        'name': 'Virat Kohli',
        'role': 'Batsman',
        'matches': '254',
        'runs': '12,344',
        'wickets': '4',
        'avatar': 'VK',
      },
      {
        'name': 'Rohit Sharma',
        'role': 'Batsman',
        'matches': '243',
        'runs': '10,865',
        'wickets': '15',
        'avatar': 'RS',
      },
      {
        'name': 'Jasprit Bumrah',
        'role': 'Bowler',
        'matches': '133',
        'runs': '56',
        'wickets': '165',
        'avatar': 'JB',
      },
      {
        'name': 'Ravindra Jadeja',
        'role': 'All-rounder',
        'matches': '210',
        'runs': '2,756',
        'wickets': '132',
        'avatar': 'RJ',
      },
      {
        'name': 'MS Dhoni',
        'role': 'Wicket-keeper',
        'matches': '234',
        'runs': '5,082',
        'wickets': '0',
        'avatar': 'MSD',
      },
      {
        'name': 'Hardik Pandya',
        'role': 'All-rounder',
        'matches': '119',
        'runs': '2,223',
        'wickets': '67',
        'avatar': 'HP',
      },
      {
        'name': 'KL Rahul',
        'role': 'Wicket-keeper',
        'matches': '132',
        'runs': '4,163',
        'wickets': '0',
        'avatar': 'KLR',
      },
      {
        'name': 'Yuzvendra Chahal',
        'role': 'Bowler',
        'matches': '139',
        'runs': '89',
        'wickets': '176',
        'avatar': 'YC',
      },
      {
        'name': 'Shikhar Dhawan',
        'role': 'Batsman',
        'matches': '217',
        'runs': '6,617',
        'wickets': '3',
        'avatar': 'SD',
      },
      {
        'name': 'Rishabh Pant',
        'role': 'Wicket-keeper',
        'matches': '98',
        'runs': '3,284',
        'wickets': '0',
        'avatar': 'RP',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return _buildPlayerCard(context, player);
      },
    );
  }

  Widget _buildPlayerCard(BuildContext context, Map<String, String> player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerProfileScreen(
                playerName: player['name']!,
                playerRole: player['role']!,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  player['avatar']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player['name']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      player['role']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatChip(
                          context,
                          'M: ${player['matches']}',
                        ),
                        const SizedBox(width: 6),
                        _buildStatChip(
                          context,
                          'R: ${player['runs']}',
                        ),
                        const SizedBox(width: 6),
                        _buildStatChip(
                          context,
                          'W: ${player['wickets']}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
