import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/providers/player_provider.dart';
import 'package:cric_scoring/screens/scoring/live_scoring_screen.dart';

class OpeningPlayersScreen extends ConsumerStatefulWidget {
  final Match match;
  final List<String> teamAPlayingXI;
  final List<String> teamBPlayingXI;

  const OpeningPlayersScreen({
    super.key,
    required this.match,
    required this.teamAPlayingXI,
    required this.teamBPlayingXI,
  });

  @override
  ConsumerState<OpeningPlayersScreen> createState() =>
      _OpeningPlayersScreenState();
}

class _OpeningPlayersScreenState extends ConsumerState<OpeningPlayersScreen> {
  String? striker;
  String? nonStriker;
  String? openingBowler;
  bool isLoading = false;

  String get battingTeamId => widget.match.battingFirst!;
  String get bowlingTeamId => battingTeamId == widget.match.teamA.teamId
      ? widget.match.teamB.teamId
      : widget.match.teamA.teamId;

  List<String> get battingPlayingXI =>
      battingTeamId == widget.match.teamA.teamId
          ? widget.teamAPlayingXI
          : widget.teamBPlayingXI;

  List<String> get bowlingPlayingXI =>
      bowlingTeamId == widget.match.teamA.teamId
          ? widget.teamAPlayingXI
          : widget.teamBPlayingXI;

  @override
  Widget build(BuildContext context) {
    final battingPlayersAsync = ref.watch(teamPlayersProvider(battingTeamId));
    final bowlingPlayersAsync = ref.watch(teamPlayersProvider(bowlingTeamId));

    final battingTeamName = battingTeamId == widget.match.teamA.teamId
        ? widget.match.teamA.name
        : widget.match.teamB.name;
    final bowlingTeamName = bowlingTeamId == widget.match.teamA.teamId
        ? widget.match.teamA.name
        : widget.match.teamB.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Opening Players'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$battingTeamName - Opening Batsmen',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            battingPlayersAsync.when(
              data: (allPlayers) {
                final players = allPlayers
                    .where((p) => battingPlayingXI.contains(p.playerId))
                    .toList();
                return Column(
                  children: [
                    _buildPlayerSelector(
                      'Striker',
                      striker,
                      players,
                      (playerId) => setState(() => striker = playerId),
                    ),
                    const SizedBox(height: 12),
                    _buildPlayerSelector(
                      'Non-Striker',
                      nonStriker,
                      players,
                      (playerId) => setState(() => nonStriker = playerId),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            Text(
              '$bowlingTeamName - Opening Bowler',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            bowlingPlayersAsync.when(
              data: (allPlayers) {
                final players = allPlayers
                    .where((p) => bowlingPlayingXI.contains(p.playerId))
                    .toList();
                return _buildPlayerSelector(
                  'Opening Bowler',
                  openingBowler,
                  players,
                  (playerId) => setState(() => openingBowler = playerId),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: striker != null &&
                    nonStriker != null &&
                    openingBowler != null &&
                    striker != nonStriker
                ? _startMatch
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Start Match',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSelector(
    String label,
    String? selectedPlayerId,
    List players,
    Function(String) onSelect,
  ) {
    final selectedPlayer =
        players.where((p) => p.playerId == selectedPlayerId).firstOrNull;

    return Card(
      child: InkWell(
        onTap: () => _showPlayerPicker(label, players, onSelect),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedPlayer?.name ?? 'Select Player',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedPlayer != null
                            ? Colors.black
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (selectedPlayer != null)
                      Text(
                        selectedPlayer.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerPicker(
      String label, List players, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select $label',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...players.map((player) => ListTile(
                  leading: CircleAvatar(
                    child: Text(player.jerseyNumber.toString()),
                  ),
                  title: Row(
                    children: [
                      Text(player.name),
                      if (player.isCaptain) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'C',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(player.role.toUpperCase()),
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(player.playerId);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _startMatch() async {
    setState(() => isLoading = true);

    try {
      // Create first innings
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.match.matchId)
          .collection('innings')
          .doc('1')
          .set({
        'inningsNumber': 1,
        'battingTeamId': battingTeamId,
        'bowlingTeamId': bowlingTeamId,
        'runs': 0,
        'wickets': 0,
        'overs': 0.0,
        'extras': {
          'wides': 0,
          'noBalls': 0,
          'byes': 0,
          'legByes': 0,
        },
        'isDeclared': false,
        'isCompleted': false,
      });

      // Update match status
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.match.matchId)
          .update({
        'status': 'live',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Navigate to live scoring
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => LiveScoringScreen(match: widget.match),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
