import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/models/innings_model.dart';
import 'package:cric_scoring/providers/scoring_provider.dart';
import 'package:cric_scoring/providers/match_provider.dart';
import 'package:cric_scoring/screens/scoring/start_match_dialog.dart';
import 'package:cric_scoring/screens/scoring/player_selection_widget.dart';

class LiveScoringScreen extends ConsumerStatefulWidget {
  final Match match;

  const LiveScoringScreen({super.key, required this.match});

  @override
  ConsumerState<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends ConsumerState<LiveScoringScreen> {
  String? strikerBatsmanId;
  String? nonStrikerBatsmanId;
  String? selectedBowlerId;
  bool showExtrasMenu = false;
  int? _lastInningsNumber;

  @override
  Widget build(BuildContext context) {
    // Watch match for real-time updates
    final matchAsync = ref.watch(matchProvider(widget.match.matchId));
    final currentMatch = matchAsync.value ?? widget.match;

    final inningsAsync =
        ref.watch(currentInningsProvider(widget.match.matchId));
    final currentOverBalls =
        ref.watch(currentOverBallsProvider(widget.match.matchId));

    // Listen for innings changes
    ref.listen<AsyncValue<Innings?>>(
      currentInningsProvider(widget.match.matchId),
      (previous, next) {
        final innings = next.value;
        if (innings != null) {
          if (_lastInningsNumber != null &&
              innings.inningsNumber != _lastInningsNumber) {
            // Innings changed!
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Innings ${innings.inningsNumber} Started!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            // Reset player selections
            setState(() {
              strikerBatsmanId = null;
              nonStrikerBatsmanId = null;
              selectedBowlerId = null;
            });
          }
          _lastInningsNumber = innings.inningsNumber;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scoring'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => _undoLastBall(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show match options
            },
          ),
        ],
      ),
      body: inningsAsync.when(
        data: (innings) {
          if (innings == null) {
            // Check if match is completed
            if (currentMatch.status == 'completed') {
              return _buildMatchCompletedView(currentMatch);
            }
            return _buildStartMatchView();
          }

          return Column(
            children: [
              _buildScoreHeader(innings, currentMatch),
              _buildPlayerSelection(innings),
              _buildCurrentOver(currentOverBalls.value ?? []),
              const Divider(height: 1),
              Expanded(
                child: _buildScoringButtons(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMatchCompletedView(Match match) {
    return MatchCompletedTabView(match: match);
  }

  Widget _buildStartMatchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_cricket, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Match not started',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => StartMatchDialog(match: widget.match),
              );
              if (result == true && mounted) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Match'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelection(innings) {
    final battingTeamId = innings.battingTeamId;
    final bowlingTeamId = innings.bowlingTeamId;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PlayerSelectionWidget(
                  teamId: battingTeamId,
                  selectedPlayerId: strikerBatsmanId,
                  label: 'Striker',
                  matchId: widget.match.matchId,
                  inningsNumber: innings.inningsNumber,
                  onPlayerSelected: (player) {
                    setState(() => strikerBatsmanId = player.playerId);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = strikerBatsmanId;
                    strikerBatsmanId = nonStrikerBatsmanId;
                    nonStrikerBatsmanId = temp;
                  });
                },
                tooltip: 'Swap Batsmen',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlayerSelectionWidget(
                  teamId: battingTeamId,
                  selectedPlayerId: nonStrikerBatsmanId,
                  label: 'Non-Striker',
                  matchId: widget.match.matchId,
                  inningsNumber: innings.inningsNumber,
                  onPlayerSelected: (player) {
                    setState(() => nonStrikerBatsmanId = player.playerId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PlayerSelectionWidget(
            teamId: bowlingTeamId,
            selectedPlayerId: selectedBowlerId,
            label: 'Bowler',
            matchId: widget.match.matchId,
            inningsNumber: innings.inningsNumber,
            onPlayerSelected: (player) {
              setState(() => selectedBowlerId = player.playerId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(innings, Match match) {
    final battingTeam =
        innings.battingTeamId == match.teamA.teamId ? match.teamA : match.teamB;

    // Get innings 1 score for target
    final innings1Async = ref.watch(innings1Provider(match.matchId));
    final innings1 = innings1Async.value;
    final target = innings1 != null && innings.inningsNumber == 2
        ? innings1.runs + 1
        : null;
    final required = target != null ? target - innings.runs : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Match status banner
          if (match.status == 'completed')
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.result ?? 'Match Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                battingTeam.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${innings.runs}/${innings.wickets}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overs: ${innings.oversDisplay}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                target != null
                    ? 'Need $required in ${_remainingBalls(innings, match.overs)} balls'
                    : 'Innings ${innings.inningsNumber}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                'CRR: ${_calculateRunRate(innings.runs, innings.overs)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOver(List balls) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Over',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: balls.isEmpty
                ? const Center(
                    child: Text(
                      'No balls bowled yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: balls.length,
                    itemBuilder: (context, index) {
                      final ball = balls[index];
                      return Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: ball.isWicket
                              ? Colors.red
                              : ball.runs == 6
                                  ? Colors.purple
                                  : ball.runs == 4
                                      ? Colors.green
                                      : ball.isExtra
                                          ? Colors.orange
                                          : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ball.displayText,
                            style: TextStyle(
                              color: ball.isWicket ||
                                      ball.runs >= 4 ||
                                      ball.isExtra
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringButtons() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Run buttons
          const Text(
            'Runs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRunButton(0)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(1)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(2)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(3)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildRunButton(4)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(5)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(6)),
              const SizedBox(width: 8),
              Expanded(child: _buildRunButton(7)),
            ],
          ),

          const SizedBox(height: 24),

          // Wicket button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _recordWicket(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'WICKET',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Extras buttons
          const Text(
            'Extras',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildExtraButton('Wide', Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildExtraButton('No Ball', Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildExtraButton('Bye', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildExtraButton('Leg Bye', Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunButton(int runs) {
    return ElevatedButton(
      onPressed: () => _recordRuns(runs),
      style: ElevatedButton.styleFrom(
        backgroundColor: runs == 6
            ? Colors.purple
            : runs == 4
                ? Colors.green
                : Colors.grey.shade200,
        foregroundColor: runs >= 4 ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        runs.toString(),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExtraButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () => _recordExtra(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _recordRuns(int runs) async {
    final innings =
        ref.read(currentInningsProvider(widget.match.matchId)).value;
    if (innings == null) return;

    if (strikerBatsmanId == null || selectedBowlerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select striker and bowler')),
      );
      return;
    }

    final currentOver = innings.overs.floor();
    final ballsInOver = ((innings.overs - currentOver) * 10).round();

    await ref.read(scoringNotifierProvider.notifier).recordBall(
          matchId: widget.match.matchId,
          inningsNumber: innings.inningsNumber,
          batsmanId: strikerBatsmanId!,
          bowlerId: selectedBowlerId!,
          runs: runs,
        );

    // Swap batsmen on odd runs OR at end of over
    final willCompleteOver = ballsInOver >= 5;
    final shouldSwap = (runs % 2 == 1) || willCompleteOver;

    if (shouldSwap) {
      setState(() {
        final temp = strikerBatsmanId;
        strikerBatsmanId = nonStrikerBatsmanId;
        nonStrikerBatsmanId = temp;
      });
    }
  }

  void _recordWicket() async {
    final innings =
        ref.read(currentInningsProvider(widget.match.matchId)).value;
    if (innings == null) return;

    if (strikerBatsmanId == null || selectedBowlerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select striker and bowler')),
      );
      return;
    }

    // TODO: Show wicket type dialog
    await ref.read(scoringNotifierProvider.notifier).recordBall(
          matchId: widget.match.matchId,
          inningsNumber: innings.inningsNumber,
          batsmanId: strikerBatsmanId!,
          bowlerId: selectedBowlerId!,
          runs: 0,
          isWicket: true,
          wicketType: 'bowled',
        );

    // Clear striker to select new batsman
    setState(() => strikerBatsmanId = null);
  }

  void _recordExtra(String extraType) async {
    final innings =
        ref.read(currentInningsProvider(widget.match.matchId)).value;
    if (innings == null) return;

    if (strikerBatsmanId == null || selectedBowlerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select striker and bowler')),
      );
      return;
    }

    // TODO: Show runs dialog for extras
    await ref.read(scoringNotifierProvider.notifier).recordBall(
          matchId: widget.match.matchId,
          inningsNumber: innings.inningsNumber,
          batsmanId: strikerBatsmanId!,
          bowlerId: selectedBowlerId!,
          runs: 0,
          isWide: extraType == 'Wide',
          isNoBall: extraType == 'No Ball',
          isBye: extraType == 'Bye',
          isLegBye: extraType == 'Leg Bye',
        );
  }

  void _undoLastBall() async {
    final innings =
        ref.read(currentInningsProvider(widget.match.matchId)).value;
    if (innings == null) return;

    await ref.read(scoringNotifierProvider.notifier).undoLastBall(
          widget.match.matchId,
          innings.inningsNumber,
        );
  }

  String _calculateRunRate(int runs, double overs) {
    if (overs == 0) return '0.00';
    return (runs / overs).toStringAsFixed(2);
  }

  int _remainingBalls(Innings innings, int maxOvers) {
    final currentOver = innings.overs.floor();
    final ballsInOver = ((innings.overs - currentOver) * 10).round();
    final ballsBowled = (currentOver * 6) + ballsInOver;
    final totalBalls = maxOvers * 6;
    return totalBalls - ballsBowled;
  }
}

// Match Completed Tab View
class MatchCompletedTabView extends ConsumerStatefulWidget {
  final Match match;

  const MatchCompletedTabView({super.key, required this.match});

  @override
  ConsumerState<MatchCompletedTabView> createState() =>
      _MatchCompletedTabViewState();
}

class _MatchCompletedTabViewState extends ConsumerState<MatchCompletedTabView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final innings1Async = ref.watch(innings1Provider(widget.match.matchId));
    final innings2Async = ref.watch(innings2Provider(widget.match.matchId));
    final innings1 = innings1Async.value;
    final innings2 = innings2Async.value;

    return Column(
      children: [
        // Match Result Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
              const SizedBox(height: 12),
              const Text(
                'Match Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.match.result != null)
                Text(
                  widget.match.result!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              // Scores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTeamScore(
                    widget.match.teamA.name,
                    innings1 != null
                        ? '${innings1.runs}/${innings1.wickets}'
                        : '-',
                    innings1?.oversDisplay ?? '-',
                  ),
                  const Text(
                    'vs',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildTeamScore(
                    widget.match.teamB.name,
                    innings2 != null
                        ? '${innings2.runs}/${innings2.wickets}'
                        : '-',
                    innings2?.oversDisplay ?? '-',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              _buildTab('Overview', 0),
              _buildTab('Scorecard', 1),
              _buildTab('Commentary', 2),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _buildOverviewTab(innings1, innings2),
              _buildScorecardTab(innings1, innings2),
              _buildCommentaryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScore(String teamName, String score, String overs) {
    return Column(
      children: [
        Text(
          teamName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '($overs ov)',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Innings? innings1, Innings? innings2) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Match Summary'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Venue', widget.match.ground),
                const Divider(),
                _buildInfoRow('Date',
                    '${widget.match.date.day}/${widget.match.date.month}/${widget.match.date.year}'),
                const Divider(),
                _buildInfoRow('Overs', '${widget.match.overs} overs per side'),
                const Divider(),
                _buildInfoRow('Toss',
                    '${widget.match.tossWinner ?? 'N/A'} - ${widget.match.tossDecision ?? 'N/A'}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Innings Summary'),
        const SizedBox(height: 12),
        if (innings1 != null)
          Card(
            child: ListTile(
              title: Text('${widget.match.teamA.name} - Innings 1'),
              subtitle: Text('${innings1.oversDisplay} overs'),
              trailing: Text(
                '${innings1.runs}/${innings1.wickets}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (innings2 != null)
          Card(
            child: ListTile(
              title: Text('${widget.match.teamB.name} - Innings 2'),
              subtitle: Text('${innings2.oversDisplay} overs'),
              trailing: Text(
                '${innings2.runs}/${innings2.wickets}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScorecardTab(Innings? innings1, Innings? innings2) {
    final battingStatsAsync =
        ref.watch(battingStatsProvider(widget.match.matchId));
    final bowlingStatsAsync =
        ref.watch(bowlingStatsProvider(widget.match.matchId));

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
                _buildBattingHeaders(),
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
                _buildBowlingHeaders(),
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

  Widget _buildBattingHeaders() {
    return Padding(
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
    );
  }

  Widget _buildBowlingHeaders() {
    return Padding(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
