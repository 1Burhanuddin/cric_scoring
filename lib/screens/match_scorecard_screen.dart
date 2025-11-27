import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/models/innings_model.dart';
import 'package:cric_scoring/providers/match_provider.dart';
import 'package:cric_scoring/providers/scoring_provider.dart';
import 'package:cric_scoring/screens/scoring/live_scoring_screen.dart';

class MatchScorecardScreen extends ConsumerStatefulWidget {
  final Match match;

  const MatchScorecardScreen({
    super.key,
    required this.match,
  });

  @override
  ConsumerState<MatchScorecardScreen> createState() =>
      _MatchScorecardScreenState();
}

class _MatchScorecardScreenState extends ConsumerState<MatchScorecardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Watch match for real-time updates
    final matchAsync = ref.watch(matchProvider(widget.match.matchId));
    final currentMatch = matchAsync.value ?? widget.match;

    // Watch innings for scores
    final innings1Async = ref.watch(innings1Provider(widget.match.matchId));
    final innings1 = innings1Async.value;

    final innings2Async = ref.watch(innings2Provider(widget.match.matchId));
    final innings2 = innings2Async.value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.match.status == 'upcoming' ||
              widget.match.status == 'live')
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveScoringScreen(match: widget.match),
                  ),
                );
              },
              icon: Icon(Icons.sports_cricket,
                  color: Theme.of(context).colorScheme.primary),
              label: Text(
                widget.match.status == 'live' ? 'Score' : 'Start Scoring',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScoreHeader(currentMatch, innings1, innings2),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildOverviewTab(currentMatch),
                _buildScorecardTab(),
                _buildCommentaryTab(),
                _buildStatsTab(),
                _buildMoreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(Match match, Innings? innings1, Innings? innings2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Team A Score
          Row(
            children: [
              _buildTeamFlag(match.teamA.colorValue, 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          innings1 != null
                              ? '${innings1.runs}/${innings1.wickets}'
                              : '-',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '1st',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      innings1 != null
                          ? '(${innings1.oversDisplay} ov)'
                          : 'Yet to bat',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Team Names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.match.teamA.initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.match.teamB.initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Team B Score
          Row(
            children: [
              _buildTeamFlag(match.teamB.colorValue, 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          innings2 != null
                              ? '${innings2.runs}/${innings2.wickets}'
                              : '-',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '2nd',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      innings2 != null
                          ? '(${innings2.oversDisplay} ov)'
                          : 'Yet to bat',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Target
          if (innings1 != null && innings2 != null)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Target ${innings1.runs + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Match Result
          if (match.result != null)
            Text(
              match.result!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          // Match Details
          Text(
            'Test 2 of 2 (${widget.match.teamA.initials} wins 2-0) · Day 5 · Session 2',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '22-26 Nov',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamFlag(Color color, double size) {
    return Container(
      width: size,
      height: size * 0.67,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Scorecard', 'Commentary', 'Stats', 'More'];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? primaryColor : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(Match match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Match Info'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.emoji_events, 'Tournament',
              match.tournamentId ?? 'Friendly Match'),
          _buildInfoRow(Icons.location_on, 'Venue', match.ground),
          _buildInfoRow(Icons.calendar_today, 'Date',
              '${match.date.day}/${match.date.month}/${match.date.year}'),
          _buildInfoRow(
              Icons.sports_cricket, 'Match Type', '${match.overs} Overs'),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle('Toss'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.info_outline, 'Toss Winner',
              match.tossWinner ?? 'Not decided'),
          _buildInfoRow(Icons.sports, 'Decision', match.tossDecision ?? '-'),
        ]),
      ],
    );
  }

  Widget _buildScorecardTab() {
    final innings1Async = ref.watch(innings1Provider(widget.match.matchId));
    final innings2Async = ref.watch(innings2Provider(widget.match.matchId));
    final battingStatsAsync =
        ref.watch(battingStatsProvider(widget.match.matchId));
    final bowlingStatsAsync =
        ref.watch(bowlingStatsProvider(widget.match.matchId));

    final innings1 = innings1Async.value;
    final innings2 = innings2Async.value;
    final battingStats = battingStatsAsync.value ?? [];
    final bowlingStats = bowlingStatsAsync.value ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Team A Innings
        _buildInningsCard(
          teamName: widget.match.teamA.name,
          innings: innings1,
          inningsNumber: 1,
          battingStats: battingStats,
          bowlingStats: bowlingStats,
        ),
        const SizedBox(height: 16),
        // Team B Innings
        _buildInningsCard(
          teamName: widget.match.teamB.name,
          innings: innings2,
          inningsNumber: 2,
          battingStats: battingStats,
          bowlingStats: bowlingStats,
        ),
      ],
    );
  }

  Widget _buildInningsCard({
    required String teamName,
    required Innings? innings,
    required int inningsNumber,
    required List<Map<String, dynamic>> battingStats,
    required List<Map<String, dynamic>> bowlingStats,
  }) {
    if (innings == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$teamName - Innings $inningsNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Yet to bat',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final inningsBatting = battingStats
        .where((stat) => stat['inningsNumber'] == inningsNumber)
        .toList();
    final inningsBowling = bowlingStats
        .where((stat) => stat['inningsNumber'] == inningsNumber)
        .toList();

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          '$teamName - Innings $inningsNumber',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${innings.runs}/${innings.wickets} (${innings.oversDisplay} ov)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batting Section
                const Text(
                  'BATTING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                // Batting Headers
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Batsman',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'R',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'B',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '4s',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '6s',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'SR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                if (inningsBatting.isNotEmpty)
                  ...inningsBatting.map((stat) => _buildBatsmanRow(stat))
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No batting data',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                // Extras
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Extras',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${innings.totalExtras}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${innings.runs}/${innings.wickets} (${innings.oversDisplay} ov)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bowling Section
                const Text(
                  'BOWLING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                // Bowling Headers
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Bowler',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'O',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'R',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Econ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                if (inningsBowling.isNotEmpty)
                  ...inningsBowling.map((stat) => _buildBowlerRow(stat))
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No bowling data',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatsmanRow(Map<String, dynamic> stat) {
    final runs = stat['runs'] ?? 0;
    final balls = stat['balls'] ?? 0;
    final fours = stat['fours'] ?? 0;
    final sixes = stat['sixes'] ?? 0;
    final isOut = stat['isOut'] ?? false;
    final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              stat['playerId'] ?? 'Unknown',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              isOut ? '$runs' : '$runs*',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$balls',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$fours',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$sixes',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              sr,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlerRow(Map<String, dynamic> stat) {
    final overs = (stat['overs'] ?? 0.0).toDouble();
    final runs = stat['runs'] ?? 0;
    final wickets = stat['wickets'] ?? 0;
    final economy = overs > 0 ? (runs / overs).toStringAsFixed(2) : '0.00';

    // Format overs display
    final completeOvers = overs.floor();
    final balls = ((overs - completeOvers) * 10).round();
    final oversDisplay = '$completeOvers.$balls';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              stat['playerId'] ?? 'Unknown',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              oversDisplay,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$runs',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$wickets',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              economy,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Commentary',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ball-by-ball commentary coming soon',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Match Statistics'),
        const SizedBox(height: 12),
        _buildStatCard('Highest Score', 'R. Sharma - 89 (56)'),
        const SizedBox(height: 8),
        _buildStatCard('Best Bowling', 'J. Bumrah - 2/28 (4)'),
        const SizedBox(height: 8),
        _buildStatCard('Most Fours', 'R. Sharma - 10'),
        const SizedBox(height: 8),
        _buildStatCard('Most Sixes', 'R. Sharma - 3'),
      ],
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Additional Information'),
        const SizedBox(height: 12),
        _buildInfoCard([
          _buildInfoRow(Icons.people, 'Umpires', 'Umpire 1, Umpire 2'),
          _buildInfoRow(Icons.person, 'Match Referee', 'Referee Name'),
          _buildInfoRow(Icons.wb_sunny, 'Weather', 'Sunny'),
          _buildInfoRow(Icons.grass, 'Pitch', 'Good for batting'),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
