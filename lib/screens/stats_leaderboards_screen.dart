import 'package:flutter/material.dart';

class StatsLeaderboardsScreen extends StatefulWidget {
  const StatsLeaderboardsScreen({super.key});

  @override
  State<StatsLeaderboardsScreen> createState() =>
      _StatsLeaderboardsScreenState();
}

class _StatsLeaderboardsScreenState extends State<StatsLeaderboardsScreen> {
  String battingFilter = 'Most Runs';
  String bowlingFilter = 'Most Wickets';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(text: 'Batting'),
              Tab(text: 'Bowling'),
              Tab(text: 'All-Rounder'),
              Tab(text: 'Teams'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBattingStats(context),
            _buildBowlingStats(context),
            _buildAllRounderStats(context),
            _buildTeamStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBattingStats(BuildContext context) {
    final battingStats = [
      {
        'name': 'Virat Kohli',
        'team': 'RCB',
        'avatar': 'VK',
        'runs': '756',
        'innings': '16',
        'notOuts': '3',
        'average': '58.2',
        'strikeRate': '138.5',
        'fifties': '6',
        'hundreds': '3',
        'fours': '78',
        'sixes': '24',
      },
      {
        'name': 'Rohit Sharma',
        'team': 'MI',
        'avatar': 'RS',
        'runs': '689',
        'innings': '15',
        'notOuts': '2',
        'average': '53.0',
        'strikeRate': '142.3',
        'fifties': '5',
        'hundreds': '2',
        'fours': '72',
        'sixes': '28',
      },
      {
        'name': 'KL Rahul',
        'team': 'LSG',
        'avatar': 'KLR',
        'runs': '645',
        'innings': '14',
        'notOuts': '4',
        'average': '64.5',
        'strikeRate': '135.8',
        'fifties': '7',
        'hundreds': '1',
        'fours': '68',
        'sixes': '18',
      },
      {
        'name': 'Suryakumar Yadav',
        'team': 'MI',
        'avatar': 'SY',
        'runs': '612',
        'innings': '14',
        'notOuts': '1',
        'average': '47.1',
        'strikeRate': '165.3',
        'fifties': '5',
        'hundreds': '2',
        'fours': '54',
        'sixes': '38',
      },
      {
        'name': 'Shubman Gill',
        'team': 'GT',
        'avatar': 'SG',
        'runs': '598',
        'innings': '15',
        'notOuts': '2',
        'average': '46.0',
        'strikeRate': '132.4',
        'fifties': '6',
        'hundreds': '1',
        'fours': '65',
        'sixes': '16',
      },
    ];

    return Column(
      children: [
        _buildSearchBar(context),
        _buildBattingFilterChips(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: battingStats.length,
            itemBuilder: (context, index) {
              final player = battingStats[index];
              return _buildBattingStatCard(context, index + 1, player);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search players...',
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

  Widget _buildBattingFilterChips(BuildContext context) {
    final filters = [
      'Most Runs',
      'Best Average',
      'Best Strike Rate',
      'Most Fours',
      'Most Sixes'
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = battingFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  battingFilter = filter;
                });
              },
              selectedColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBattingStatCard(
    BuildContext context,
    int position,
    Map<String, String> player,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getPositionColor(position).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getPositionColor(position),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    player['avatar']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                      const SizedBox(height: 2),
                      Text(
                        player['team']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      player['runs']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      'runs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Inn', player['innings']!),
                _buildStatItem(context, 'NO', player['notOuts']!),
                _buildStatItem(context, 'Avg', player['average']!),
                _buildStatItem(context, 'SR', player['strikeRate']!),
                _buildStatItem(context, '50s', player['fifties']!),
                _buildStatItem(context, '100s', player['hundreds']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlingStats(BuildContext context) {
    final bowlingStats = [
      {
        'name': 'Jasprit Bumrah',
        'team': 'MI',
        'avatar': 'JB',
        'wickets': '28',
        'overs': '58.4',
        'maidens': '3',
        'runs': '412',
        'economy': '7.02',
        'strikeRate': '12.6',
        'best': '5/24',
        'fiveWickets': '2',
      },
      {
        'name': 'Yuzvendra Chahal',
        'team': 'RR',
        'avatar': 'YC',
        'wickets': '25',
        'overs': '56.0',
        'maidens': '1',
        'runs': '438',
        'economy': '7.82',
        'strikeRate': '13.4',
        'best': '4/28',
        'fiveWickets': '0',
      },
      {
        'name': 'Mohammed Siraj',
        'team': 'RCB',
        'avatar': 'MS',
        'wickets': '23',
        'overs': '52.3',
        'maidens': '2',
        'runs': '398',
        'economy': '7.58',
        'strikeRate': '13.7',
        'best': '4/21',
        'fiveWickets': '0',
      },
      {
        'name': 'Rashid Khan',
        'team': 'GT',
        'avatar': 'RK',
        'wickets': '22',
        'overs': '60.0',
        'maidens': '4',
        'runs': '372',
        'economy': '6.20',
        'strikeRate': '16.4',
        'best': '3/18',
        'fiveWickets': '0',
      },
      {
        'name': 'Kagiso Rabada',
        'team': 'PBKS',
        'avatar': 'KR',
        'wickets': '21',
        'overs': '54.0',
        'maidens': '2',
        'runs': '425',
        'economy': '7.87',
        'strikeRate': '15.4',
        'best': '4/32',
        'fiveWickets': '0',
      },
    ];

    return Column(
      children: [
        _buildSearchBar(context),
        _buildBowlingFilterChips(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: bowlingStats.length,
            itemBuilder: (context, index) {
              final player = bowlingStats[index];
              return _buildBowlingStatCard(context, index + 1, player);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBowlingFilterChips(BuildContext context) {
    final filters = [
      'Most Wickets',
      'Best Economy',
      'Best Strike Rate',
      '5-Wicket Hauls'
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = bowlingFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  bowlingFilter = filter;
                });
              },
              selectedColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey.shade700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBowlingStatCard(
    BuildContext context,
    int position,
    Map<String, String> player,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getPositionColor(position).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getPositionColor(position),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    player['avatar']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                      const SizedBox(height: 2),
                      Text(
                        player['team']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      player['wickets']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    Text(
                      'wickets',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Ovs', player['overs']!),
                _buildStatItem(context, 'M', player['maidens']!),
                _buildStatItem(context, 'Runs', player['runs']!),
                _buildStatItem(context, 'Econ', player['economy']!),
                _buildStatItem(context, 'Best', player['best']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRounderStats(BuildContext context) {
    final allRounderStats = [
      {
        'name': 'Hardik Pandya',
        'team': 'MI',
        'avatar': 'HP',
        'runs': '487',
        'wickets': '18',
        'impact': '92.5',
      },
      {
        'name': 'Ravindra Jadeja',
        'team': 'CSK',
        'avatar': 'RJ',
        'runs': '412',
        'wickets': '16',
        'impact': '88.3',
      },
      {
        'name': 'Andre Russell',
        'team': 'KKR',
        'avatar': 'AR',
        'runs': '398',
        'wickets': '12',
        'impact': '85.7',
      },
      {
        'name': 'Axar Patel',
        'team': 'DC',
        'avatar': 'AP',
        'runs': '345',
        'wickets': '15',
        'impact': '82.4',
      },
      {
        'name': 'Washington Sundar',
        'team': 'SRH',
        'avatar': 'WS',
        'runs': '312',
        'wickets': '14',
        'impact': '79.8',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allRounderStats.length,
      itemBuilder: (context, index) {
        final player = allRounderStats[index];
        return _buildAllRounderCard(context, index + 1, player);
      },
    );
  }

  Widget _buildAllRounderCard(
    BuildContext context,
    int position,
    Map<String, String> player,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getPositionColor(position).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _getPositionColor(position),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange,
              child: Text(
                player['avatar']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
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
                  const SizedBox(height: 2),
                  Text(
                    player['team']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_score, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      player['runs']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.sports_baseball, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      player['wickets']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Impact: ${player['impact']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStats(BuildContext context) {
    final teamStats = [
      {
        'name': 'Mumbai Indians',
        'logo': 'MI',
        'color': const Color(0xFF004BA0),
        'matches': '14',
        'wins': '10',
        'losses': '4',
        'winPercent': '71.4',
        'highestScore': '245/4',
        'bestBowling': '6/12',
      },
      {
        'name': 'Chennai Super Kings',
        'logo': 'CSK',
        'color': const Color(0xFFFDB913),
        'matches': '14',
        'wins': '9',
        'losses': '5',
        'winPercent': '64.3',
        'highestScore': '238/5',
        'bestBowling': '5/18',
      },
      {
        'name': 'Royal Challengers',
        'logo': 'RCB',
        'color': const Color(0xFFEC1C24),
        'matches': '14',
        'wins': '8',
        'losses': '6',
        'winPercent': '57.1',
        'highestScore': '232/3',
        'bestBowling': '5/24',
      },
      {
        'name': 'Kolkata Knight Riders',
        'logo': 'KKR',
        'color': const Color(0xFF3A225D),
        'matches': '14',
        'wins': '7',
        'losses': '7',
        'winPercent': '50.0',
        'highestScore': '228/6',
        'bestBowling': '4/19',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: teamStats.length,
      itemBuilder: (context, index) {
        final team = teamStats[index];
        return _buildTeamStatCard(context, index + 1, team);
      },
    );
  }

  Widget _buildTeamStatCard(
    BuildContext context,
    int position,
    Map<String, dynamic> team,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getPositionColor(position).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getPositionColor(position),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: team['color'] as Color,
                  child: Text(
                    team['logo'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    team['name'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${team['winPercent']}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'M', team['matches'] as String),
                _buildStatItem(context, 'W', team['wins'] as String),
                _buildStatItem(context, 'L', team['losses'] as String),
                _buildStatItem(context, 'High', team['highestScore'] as String),
                _buildStatItem(context, 'Best', team['bestBowling'] as String),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey;
    if (position == 3) return Colors.brown;
    return Theme.of(context).colorScheme.primary;
  }
}
