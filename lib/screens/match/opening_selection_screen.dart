import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

class OpeningSelectionScreen extends ConsumerStatefulWidget {
  const OpeningSelectionScreen({super.key});

  @override
  ConsumerState<OpeningSelectionScreen> createState() =>
      _OpeningSelectionScreenState();
}

class _OpeningSelectionScreenState
    extends ConsumerState<OpeningSelectionScreen> {
  String? _striker;
  String? _nonStriker;
  String? _openingBowler;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);

    if (state.teamASquad == null || state.teamBSquad == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Opening Players')),
        body: const Center(child: Text('Squads not selected')),
      );
    }

    final battingTeamId = state.battingFirst;
    final battingSquad = battingTeamId == state.teamA!.teamId
        ? state.teamASquad!
        : state.teamBSquad!;
    final bowlingSquad = battingTeamId == state.teamA!.teamId
        ? state.teamBSquad!
        : state.teamASquad!;

    final battingPlayers = battingSquad.playingXI;
    final bowlingPlayers = bowlingSquad.playingXI;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Opening Players'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${battingSquad.teamName} - Opening Batsmen',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPlayerSelector(
              'Striker',
              _striker,
              battingPlayers,
              (playerId) => setState(() => _striker = playerId),
            ),
            const SizedBox(height: 12),
            _buildPlayerSelector(
              'Non-Striker',
              _nonStriker,
              battingPlayers,
              (playerId) => setState(() => _nonStriker = playerId),
            ),
            const SizedBox(height: 24),
            Text(
              '${bowlingSquad.teamName} - Opening Bowler',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPlayerSelector(
              'Opening Bowler',
              _openingBowler,
              bowlingPlayers,
              (playerId) => setState(() => _openingBowler = playerId),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _canProceed() ? _createMatch : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create Match'),
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
                  title: Text(player.name),
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

  bool _canProceed() {
    return _striker != null &&
        _nonStriker != null &&
        _openingBowler != null &&
        _striker != _nonStriker;
  }

  Future<void> _createMatch() async {
    setState(() => _isCreating = true);

    try {
      final currentUser = ref.read(authStateChangesProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final notifier = ref.read(matchCreationProvider.notifier);
      final matchId = await notifier.createMatch(currentUser.uid);

      // Match created as 'upcoming', not 'live' yet
      // Opening players will be selected when starting the match

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
