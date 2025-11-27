import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/player_model.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';
import 'package:cric_scoring/screens/match/toss_selection_screen.dart';

class PlayingXIScreen extends ConsumerStatefulWidget {
  const PlayingXIScreen({super.key});

  @override
  ConsumerState<PlayingXIScreen> createState() => _PlayingXIScreenState();
}

class _PlayingXIScreenState extends ConsumerState<PlayingXIScreen> {
  final Set<String> _teamASelected = {};
  final Set<String> _teamBSelected = {};
  List<TeamPlayer> _teamAPlayers = [];
  List<TeamPlayer> _teamBPlayers = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);
    final firestore = ref.watch(firestoreProvider);

    if (state.teamA == null || state.teamB == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playing XI')),
        body: const Center(child: Text('Teams not selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Playing XI'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Team A Section
                _buildTeamHeader(state.teamA!.name, _teamASelected.length),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('teams')
                      .doc(state.teamA!.teamId)
                      .collection('players')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final players = snapshot.data!.docs.map((doc) {
                      return TeamPlayer.fromMap(
                          doc.data() as Map<String, dynamic>);
                    }).toList();

                    players.sort(
                        (a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

                    // Store Team A players
                    _teamAPlayers = players;

                    if (players.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.person_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('No players in ${state.teamA!.name}'),
                              const SizedBox(height: 4),
                              const Text(
                                'Add players to this team first',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: players.map((player) {
                        final isSelected =
                            _teamASelected.contains(player.playerId);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          title: Text(player.name),
                          subtitle: Text(player.role.toUpperCase()),
                          secondary: CircleAvatar(
                            radius: 16,
                            child: Text(
                              player.jerseyNumber.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _teamASelected.add(player.playerId);
                              } else {
                                _teamASelected.remove(player.playerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Team B Section
                _buildTeamHeader(state.teamB!.name, _teamBSelected.length),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('teams')
                      .doc(state.teamB!.teamId)
                      .collection('players')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final players = snapshot.data!.docs.map((doc) {
                      return TeamPlayer.fromMap(
                          doc.data() as Map<String, dynamic>);
                    }).toList();

                    players.sort(
                        (a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

                    // Store Team B players
                    _teamBPlayers = players;

                    if (players.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.person_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('No players in ${state.teamB!.name}'),
                              const SizedBox(height: 4),
                              const Text(
                                'Add players to this team first',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: players.map((player) {
                        final isSelected =
                            _teamBSelected.contains(player.playerId);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          title: Text(player.name),
                          subtitle: Text(player.role.toUpperCase()),
                          secondary: CircleAvatar(
                            radius: 16,
                            child: Text(
                              player.jerseyNumber.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _teamBSelected.add(player.playerId);
                              } else {
                                _teamBSelected.remove(player.playerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select at least 2 players per team',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildValidationChip(
                        '${state.teamA!.name}: ${_teamASelected.length}',
                        _teamASelected.length >= 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildValidationChip(
                        '${state.teamB!.name}: ${_teamBSelected.length}',
                        _teamBSelected.length >= 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _canProceed()
                      ? () {
                          // Convert TeamPlayer to Player
                          final teamAPlayers = _teamAPlayers
                              .map((tp) => Player(
                                    playerId: tp.playerId,
                                    name: tp.name,
                                    role: tp.role,
                                    battingStyle: 'right-hand',
                                    jerseyNumber: tp.jerseyNumber,
                                    createdAt: DateTime.now(),
                                  ))
                              .toList();

                          final teamBPlayers = _teamBPlayers
                              .map((tp) => Player(
                                    playerId: tp.playerId,
                                    name: tp.name,
                                    role: tp.role,
                                    battingStyle: 'right-hand',
                                    jerseyNumber: tp.jerseyNumber,
                                    createdAt: DateTime.now(),
                                  ))
                              .toList();

                          // Save squads
                          notifier.setTeamASquad(
                              teamAPlayers, _teamASelected.toList());
                          notifier.setTeamBSquad(
                              teamBPlayers, _teamBSelected.toList());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TossSelectionScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Next: Toss'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(String teamName, int selectedCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              teamName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$selectedCount selected (min 2)',
              style: TextStyle(
                color: selectedCount >= 2 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationChip(String label, bool isValid) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: isValid ? Colors.green.shade100 : Colors.orange.shade100,
      avatar: Icon(
        isValid ? Icons.check_circle : Icons.warning,
        color: isValid ? Colors.green : Colors.orange,
        size: 18,
      ),
    );
  }

  bool _canProceed() {
    return _teamASelected.length >= 2 && _teamBSelected.length >= 2;
  }
}
