import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';
import 'package:cric_scoring/screens/scoring/live_scoring_screen.dart';
import 'package:cric_scoring/screens/match_scorecard_screen.dart';
import 'package:cric_scoring/screens/match/toss_screen.dart';

class MatchDetailsScreen extends ConsumerStatefulWidget {
  final String teamA;
  final String teamALogo;
  final Color teamAColor;
  final String teamB;
  final String teamBLogo;
  final Color teamBColor;
  final String status;
  final Match match;

  const MatchDetailsScreen({
    super.key,
    required this.teamA,
    required this.teamALogo,
    required this.teamAColor,
    required this.teamB,
    required this.teamBLogo,
    required this.teamBColor,
    required this.status,
    required this.match,
  });

  @override
  ConsumerState<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends ConsumerState<MatchDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    final canScore =
        currentUser != null && widget.match.canUserScore(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchScorecardScreen(match: widget.match),
                ),
              );
            },
            icon: const Icon(Icons.scoreboard),
            tooltip: 'View Scorecard',
          ),
          if (canScore && widget.match.status != 'completed')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveScoringScreen(match: widget.match),
                  ),
                );
              },
              icon: const Icon(Icons.sports_cricket),
              tooltip: 'Start Scoring',
            ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal scrollable tab chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabChip('Summary', 0),
                const SizedBox(width: 12),
                _buildTabChip('Scorecard', 1),
                const SizedBox(width: 12),
                _buildTabChip('Commentary', 2),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildSummaryTab(context),
                _buildScorecardTab(context),
                _buildCommentaryTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    final canScore =
        currentUser != null && widget.match.canUserScore(currentUser.uid);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMatchHeader(context),
          const SizedBox(height: 12),
          // Start Scoring Button for authorized users
          if (canScore && widget.match.status != 'completed')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.match.status == 'live') {
                      // Continue scoring
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LiveScoringScreen(match: widget.match),
                        ),
                      );
                    } else {
                      // Start match flow with toss
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TossScreen(match: widget.match),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.sports_cricket),
                  label: Text(
                    widget.match.status == 'live'
                        ? 'Continue Scoring'
                        : 'Start Match',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (canScore && widget.match.status != 'completed')
            const SizedBox(height: 12),
          _buildMatchInfo(context),
          const SizedBox(height: 12),
          if (widget.status == 'LIVE' || widget.status == 'COMPLETED') ...[
            _buildCurrentScore(context),
            const SizedBox(height: 12),
            _buildPartnership(context),
            const SizedBox(height: 12),
            _buildFallOfWickets(context),
            const SizedBox(height: 12),
          ],
          if (widget.status == 'COMPLETED') ...[
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
                backgroundColor: widget.teamAColor,
                child: Text(
                  widget.teamALogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.teamA,
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
                backgroundColor: widget.teamBColor,
                child: Text(
                  widget.teamBLogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.teamB,
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
              if (widget.status != 'UPCOMING') ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.sports_cricket,
                  'Toss: ${widget.teamA} won and elected to bat',
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
                        widget.teamA,
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
                  const Icon(
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
            '${widget.teamA} Innings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          _buildBattingTable(context),
          const SizedBox(height: 16),
          _buildBowlingTable(context),
          const SizedBox(height: 16),
          Text(
            '${widget.teamB} Innings',
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
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
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
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
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

  Widget _buildCommentaryTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildCommentaryCard(
          context,
          '16.4',
          'J. Bumrah to R. Sharma',
          'FOUR! What a shot! Sharma drives it through the covers for a boundary.',
          '4',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '16.3',
          'J. Bumrah to R. Sharma',
          'Good length delivery, defended back to the bowler.',
          '0',
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '16.2',
          'J. Bumrah to R. Sharma',
          'SIX! Massive hit! Sharma pulls it over mid-wicket for a maximum!',
          '6',
          Colors.purple,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '16.1',
          'J. Bumrah to S. Yadav',
          'Single taken to mid-on. Good running between the wickets.',
          '1',
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.6',
          'M. Siraj to R. Sharma',
          'Two runs taken. Sharma pushes it to deep cover.',
          '2',
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.5',
          'M. Siraj to R. Sharma',
          'FOUR! Beautiful cover drive! Races away to the boundary.',
          '4',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.4',
          'M. Siraj to H. Pandya',
          'OUT! Caught behind! Pandya edges it to the keeper. Big wicket!',
          'W',
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.3',
          'M. Siraj to H. Pandya',
          'Dot ball. Good length, defended to point.',
          '0',
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.2',
          'M. Siraj to H. Pandya',
          'Single to third man. Pandya opens the face of the bat.',
          '1',
          Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildCommentaryCard(
          context,
          '15.1',
          'M. Siraj to R. Sharma',
          'One run. Sharma taps it to cover and takes a quick single.',
          '1',
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildCommentaryCard(
    BuildContext context,
    String over,
    String bowlerToBatsman,
    String commentary,
    String runs,
    Color runsColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Runs indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: runsColor.withOpacity(0.1),
                border: Border.all(
                  color: runsColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  runs,
                  style: TextStyle(
                    color: runsColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Commentary text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        over,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bowlerToBatsman,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    commentary,
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
}
