import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/providers/player_provider.dart';
import 'package:cric_scoring/screens/match/opening_players_screen.dart';

class SquadSelectionScreen extends ConsumerStatefulWidget {
  final Match match;

  const SquadSelectionScreen({super.key, required this.match});

  @override
  ConsumerState<SquadSelectionScreen> createState() =>
      _SquadSelectionScreenState();
}

class _SquadSelectionScreenState extends ConsumerState<SquadSelectionScreen> {
  final Set<String> teamAPlaying = {};
  final Set<String> teamBPlaying = {};
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final teamAPlayersAsync =
        ref.watch(teamPlayersProvider(widget.match.teamA.teamId));
    final teamBPlayersAsync =
        ref.watch(teamPlayersProvider(widget.match.teamB.teamId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Playing XI'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.match.teamA.name} (${teamAPlaying.length}/11)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            teamAPlayersAsync.when(
              data: (players) => _buildPlayerList(
                  players, teamAPlaying, widget.match.teamA.colorValue),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            Text(
              '${widget.match.teamB.name} (${teamBPlaying.length}/11)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            teamBPlayersAsync.when(
              data: (players) => _buildPlayerList(
                  players, teamBPlaying, widget.match.teamB.colorValue),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: teamAPlaying.length == 11 && teamBPlaying.length == 11
                ? _proceedToOpeningPlayers
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
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerList(
      List players, Set<String> selectedPlayers, Color teamColor) {
    return Column(
      children: players.map<Widget>((player) {
        final isSelected = selectedPlayers.contains(player.playerId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? teamColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  if (selectedPlayers.length < 11) {
                    selectedPlayers.add(player.playerId);
                  }
                } else {
                  selectedPlayers.remove(player.playerId);
                }
              });
            },
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: teamColor,
                  child: Text(
                    player.jerseyNumber.toString(),
                    style: const TextStyle(
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
                      Row(
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                          if (player.isWicketKeeper) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'WK',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        player.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            activeColor: teamColor,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _proceedToOpeningPlayers() async {
    setState(() => isLoading = true);

    try {
      // Save playing XI to Firestore
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.match.matchId)
          .update({
        'teamAPlayingXI': teamAPlaying.toList(),
        'teamBPlayingXI': teamBPlaying.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OpeningPlayersScreen(
              match: widget.match,
              teamAPlayingXI: teamAPlaying.toList(),
              teamBPlayingXI: teamBPlaying.toList(),
            ),
          ),
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
