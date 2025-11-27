import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/player_model.dart';
import 'package:cric_scoring/providers/player_provider.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

class PlayerSelectionWidget extends ConsumerWidget {
  final String teamId;
  final String? selectedPlayerId;
  final String label;
  final String? matchId;
  final int? inningsNumber;
  final Function(TeamPlayer) onPlayerSelected;

  const PlayerSelectionWidget({
    super.key,
    required this.teamId,
    this.selectedPlayerId,
    required this.label,
    this.matchId,
    this.inningsNumber,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(teamPlayersProvider(teamId));

    return playersAsync.when(
      data: (players) {
        final selectedPlayer =
            players.where((p) => p.playerId == selectedPlayerId).firstOrNull;

        return InkWell(
          onTap: () => _showPlayerSelection(context, ref, players),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade600),
                      ),
                      Text(
                        selectedPlayer?.name ?? 'Select Player',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedPlayer != null
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading players'),
    );
  }

  Future<void> _showPlayerSelection(
      BuildContext context, WidgetRef ref, List<TeamPlayer> players) async {
    // Filter out batsmen who are already out (only for batsmen selection)
    List<TeamPlayer> availablePlayers = players;

    if (matchId != null &&
        inningsNumber != null &&
        (label.toLowerCase().contains('striker') ||
            label.toLowerCase().contains('batsman'))) {
      final firestore = ref.read(firestoreProvider);
      final battingSnapshot = await firestore
          .collection('matches')
          .doc(matchId)
          .collection('batting')
          .where('inningsNumber', isEqualTo: inningsNumber)
          .where('isOut', isEqualTo: true)
          .get();

      final outPlayerIds =
          battingSnapshot.docs.map((doc) => doc.data()['playerId']).toSet();

      availablePlayers =
          players.where((p) => !outPlayerIds.contains(p.playerId)).toList();
    }

    if (!context.mounted) return;

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
            if (availablePlayers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No available players',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...availablePlayers.map((player) => ListTile(
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
                      onPlayerSelected(player);
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
