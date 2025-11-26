import 'package:flutter/material.dart';

class MatchDetailsScreen extends StatelessWidget {
  final String teamA;
  final String teamALogo;
  final Color teamAColor;
  final String teamB;
  final String teamBLogo;
  final Color teamBColor;
  final String status;

  const MatchDetailsScreen({
    super.key,
    required this.teamA,
    required this.teamALogo,
    required this.teamAColor,
    required this.teamB,
    required this.teamBLogo,
    required this.teamBColor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Details'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Squads'),
              Tab(text: 'Overs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(context),
            _buildScorecardTab(context),
            _buildSquadsTab(context),
            _buildOversTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMatchHeader(context),
          const SizedBox(height: 12),
          _buildMatchInfo(context),
          const SizedBox(height: 12),
          if (status == 'LIVE' || status == 'COMPLETED') ...[
            _buildCurrentScore(context),
            const SizedBox(height: 12),
            _buildPartnership(context),
            const SizedBox(height: 12),
            _buildFallOfWickets(context),
            const SizedBox(height: 12),
          ],
          if (status == 'COMPLETED') ...[
            _buildPlayerOfMatch(context),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: teamAColor,
                child: Text(
                  teamALogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                teamA,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Text(
            'vs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: teamBColor,
                child: Text(
                  teamBLogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                teamB,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, Icons.emoji_events, 'IPL 2025'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  context, Icons.calendar_today, 'Dec 25, 2024 • 7:30 PM'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  context, Icons.location_on, 'Wankhede Stadium, Mumbai'),
              if (status != 'UPCOMING') ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.sports_cricket,
                  'Toss: $teamA won and elected to bat',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentScore(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Score',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        teamA,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '145/3 (16.4)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Run Rate',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '8.70',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnership(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Partnership',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R. Sharma',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '52* (34)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'S. Yadav',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '38* (28)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Partnership',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '90 runs (62 balls)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallOfWickets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fall of Wickets',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildWicketRow(context, '1-12', 'V. Kohli', '12 (8)'),
                  const Divider(height: 12),
                  _buildWicketRow(context, '2-45', 'I. Kishan', '23 (15)'),
                  const Divider(height: 12),
                  _buildWicketRow(context, '3-55', 'H. Pandya', '8 (6)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWicketRow(
    BuildContext context,
    String wicket,
    String player,
    String score,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          wicket,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          player,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          score,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPlayerOfMatch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player of the Match',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Text(
                      'RS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rohit Sharma',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '89 runs (56 balls)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.emoji_events,
                    color: Colors.orange,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$teamA Innings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          _buildBattingTable(context),
          const SizedBox(height: 16),
          _buildBowlingTable(context),
          const SizedBox(height: 16),
          Text(
            '$teamB Innings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Yet to bat',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingTable(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          headingRowHeight: 36,
          dataRowHeight: 32,
          columns: [
            DataColumn(
              label: Text(
                'Batsman',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'R',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'B',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                '4s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                '6s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'SR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
          rows: [
            _buildBattingRow(
                context, 'R. Sharma*', '52', '34', '6', '2', '152.9'),
            _buildBattingRow(context, 'V. Kohli', '12', '8', '2', '0', '150.0'),
            _buildBattingRow(
                context, 'I. Kishan', '23', '15', '3', '1', '153.3'),
            _buildBattingRow(
                context, 'S. Yadav*', '38', '28', '4', '2', '135.7'),
            _buildBattingRow(context, 'H. Pandya', '8', '6', '1', '0', '133.3'),
          ],
        ),
      ),
    );
  }

  DataRow _buildBattingRow(
    BuildContext context,
    String name,
    String runs,
    String balls,
    String fours,
    String sixes,
    String sr,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(runs, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(balls, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(fours, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(sixes, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(sr, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }

  Widget _buildBowlingTable(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          headingRowHeight: 36,
          dataRowHeight: 32,
          columns: [
            DataColumn(
              label: Text(
                'Bowler',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'O',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'M',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'R',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'W',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
            DataColumn(
              label: Text(
                'Econ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
          rows: [
            _buildBowlingRow(
                context, 'J. Bumrah', '3.4', '0', '24', '1', '6.5'),
            _buildBowlingRow(context, 'M. Siraj', '4', '0', '32', '1', '8.0'),
            _buildBowlingRow(context, 'Y. Chahal', '5', '0', '38', '1', '7.6'),
            _buildBowlingRow(context, 'H. Pandya', '4', '0', '28', '0', '7.0'),
          ],
        ),
      ),
    );
  }

  DataRow _buildBowlingRow(
    BuildContext context,
    String name,
    String overs,
    String maidens,
    String runs,
    String wickets,
    String econ,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(overs, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(maidens, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(runs, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(wickets, style: Theme.of(context).textTheme.bodySmall)),
        DataCell(Text(econ, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }

  Widget _buildSquadsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          teamA,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildSquadList(context, [
          {'name': 'Rohit Sharma', 'role': 'Batsman'},
          {'name': 'Virat Kohli', 'role': 'Batsman'},
          {'name': 'Ishan Kishan', 'role': 'Wicket-keeper'},
          {'name': 'Suryakumar Yadav', 'role': 'Batsman'},
          {'name': 'Hardik Pandya', 'role': 'All-rounder'},
          {'name': 'Ravindra Jadeja', 'role': 'All-rounder'},
          {'name': 'Jasprit Bumrah', 'role': 'Bowler'},
          {'name': 'Mohammed Siraj', 'role': 'Bowler'},
          {'name': 'Yuzvendra Chahal', 'role': 'Bowler'},
          {'name': 'Kuldeep Yadav', 'role': 'Bowler'},
          {'name': 'Shubman Gill', 'role': 'Batsman'},
        ]),
        const SizedBox(height: 16),
        Text(
          teamB,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildSquadList(context, [
          {'name': 'MS Dhoni', 'role': 'Wicket-keeper'},
          {'name': 'Ruturaj Gaikwad', 'role': 'Batsman'},
          {'name': 'Devon Conway', 'role': 'Batsman'},
          {'name': 'Ajinkya Rahane', 'role': 'Batsman'},
          {'name': 'Shivam Dube', 'role': 'All-rounder'},
          {'name': 'Ravindra Jadeja', 'role': 'All-rounder'},
          {'name': 'Deepak Chahar', 'role': 'Bowler'},
          {'name': 'Tushar Deshpande', 'role': 'Bowler'},
          {'name': 'Maheesh Theekshana', 'role': 'Bowler'},
          {'name': 'Matheesha Pathirana', 'role': 'Bowler'},
          {'name': 'Moeen Ali', 'role': 'All-rounder'},
        ]),
      ],
    );
  }

  Widget _buildSquadList(
      BuildContext context, List<Map<String, String>> players) {
    return Column(
      children: players.map((player) {
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    player['name']!.split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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
                      const SizedBox(height: 2),
                      Text(
                        player['role']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOversTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Ball by Ball',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildOverCard(context, '16.4', 'J. Bumrah', [
          {'ball': '1', 'color': Colors.grey},
          {'ball': '4', 'color': Colors.green},
          {'ball': '0', 'color': Colors.grey},
          {'ball': '6', 'color': Colors.purple},
          {'ball': '2', 'color': Colors.grey},
        ]),
        const SizedBox(height: 8),
        _buildOverCard(context, '16', 'M. Siraj', [
          {'ball': '1', 'color': Colors.grey},
          {'ball': '0', 'color': Colors.grey},
          {'ball': 'W', 'color': Colors.red},
          {'ball': '4', 'color': Colors.green},
          {'ball': '1', 'color': Colors.grey},
          {'ball': '2', 'color': Colors.grey},
        ]),
        const SizedBox(height: 8),
        _buildOverCard(context, '15', 'Y. Chahal', [
          {'ball': '1', 'color': Colors.grey},
          {'ball': '1', 'color': Colors.grey},
          {'ball': '4', 'color': Colors.green},
          {'ball': '0', 'color': Colors.grey},
          {'ball': '1', 'color': Colors.grey},
          {'ball': '6', 'color': Colors.purple},
        ]),
      ],
    );
  }

  Widget _buildOverCard(
    BuildContext context,
    String over,
    String bowler,
    List<Map<String, dynamic>> balls,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Over $over',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  bowler,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: balls.map((ball) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (ball['color'] as Color).withOpacity(0.1),
                    border: Border.all(
                      color: ball['color'] as Color,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      ball['ball'] as String,
                      style: TextStyle(
                        color: ball['color'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
