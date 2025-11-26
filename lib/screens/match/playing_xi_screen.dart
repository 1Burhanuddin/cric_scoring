import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/screens/match/toss_screen.dart';

class PlayingXIScreen extends ConsumerStatefulWidget {
  const PlayingXIScreen({super.key});

  @override
  ConsumerState<PlayingXIScreen> createState() => _PlayingXIScreenState();
}

class _PlayingXIScreenState extends ConsumerState<PlayingXIScreen> {
  final Set<String> _teamASelected = {};
  final Set<String> _teamBSelected = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);

    if (state.teamA == null || state.teamB == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playing XI')),
        body: const Center(child: Text('Teams not selected')),
      );
    }

    final teamAPlayersAsync =
        ref.watch(teamPlayersProvider(state.teamA!.teamId));
    final teamBPlayersAsync =
        ref.watch(teamPlayersProvider(state.teamB!.teamId));

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
                teamAPlayersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No players in this team'),
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
                          subtitle: Text(player.role),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                if (_teamASelected.length < 11) {
                                  _teamASelected.add(player.playerId);
                                }
                              } else {
                                _teamASelected.remove(player.playerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading players'),
                ),

                const SizedBox(height: 24),

                // Team B Section
                _buildTeamHeader(state.teamB!.name, _teamBSelected.length),
                const SizedBox(height: 8),
                teamBPlayersAsync.when(
                  data: (players) {
                    if (players.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No players in this team'),
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
                          subtitle: Text(player.role),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                if (_teamBSelected.length < 11) {
                                  _teamBSelected.add(player.playerId);
                                }
                              } else {
                                _teamBSelected.remove(player.playerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading players'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildValidationChip(
                      '${state.teamA!.name}: ${_teamASelected.length}/11',
                      _teamASelected.length == 11,
                    ),
                    _buildValidationChip(
                      '${state.teamB!.name}: ${_teamBSelected.length}/11',
                      _teamBSelected.length == 11,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _canProceed(teamAPlayersAsync, teamBPlayersAsync)
                      ? () {
                          // Save squads
                          teamAPlayersAsync.whenData((players) {
                            notifier.setTeamASquad(
                                players, _teamASelected.toList());
                          });
                          teamBPlayersAsync.whenData((players) {
                            notifier.setTeamBSquad(
                                players, _teamBSelected.toList());
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TossScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
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
              '$selectedCount/11 selected',
              style: TextStyle(
                color: selectedCount == 11 ? Colors.green : Colors.orange,
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
      label: Text(label),
      backgroundColor: isValid ? Colors.green.shade100 : Colors.orange.shade100,
      avatar: Icon(
        isValid ? Icons.check_circle : Icons.warning,
        color: isValid ? Colors.green : Colors.orange,
        size: 18,
      ),
    );
  }

  bool _canProceed(teamAAsync, teamBAsync) {
    if (_teamASelected.length != 11 || _teamBSelected.length != 11) {
      return false;
    }

    // Check for wicket-keeper in both teams
    bool teamAHasWK = false;
    bool teamBHasWK = false;

    teamAAsync.whenData((players) {
      teamAHasWK = players
          .where((p) => _teamASelected.contains(p.playerId))
          .any((p) => p.role.toLowerCase().contains('keeper'));
    });

    teamBAsync.whenData((players) {
      teamBHasWK = players
          .where((p) => _teamBSelected.contains(p.playerId))
          .any((p) => p.role.toLowerCase().contains('keeper'));
    });

    return teamAHasWK && teamBHasWK;
  }
}
