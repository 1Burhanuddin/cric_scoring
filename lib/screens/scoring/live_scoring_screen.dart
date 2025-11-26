import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/providers/scoring_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final inningsAsync =
        ref.watch(currentInningsProvider(widget.match.matchId));
    final currentOverBalls =
        ref.watch(currentOverBallsProvider(widget.match.matchId));

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
            return _buildStartMatchView();
          }

          return Column(
            children: [
              _buildScoreHeader(innings),
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
            onPlayerSelected: (player) {
              setState(() => selectedBowlerId = player.playerId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(innings) {
    final battingTeam = innings.battingTeamId == widget.match.teamA.teamId
        ? widget.match.teamA
        : widget.match.teamB;

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
                'Target: -',
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

    await ref.read(scoringNotifierProvider.notifier).recordBall(
          matchId: widget.match.matchId,
          inningsNumber: innings.inningsNumber,
          batsmanId: strikerBatsmanId!,
          bowlerId: selectedBowlerId!,
          runs: runs,
        );

    // Swap batsmen on odd runs
    if (runs % 2 == 1) {
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
}
