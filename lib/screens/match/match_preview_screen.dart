import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';

class MatchPreviewScreen extends ConsumerStatefulWidget {
  const MatchPreviewScreen({super.key});

  @override
  ConsumerState<MatchPreviewScreen> createState() => _MatchPreviewScreenState();
}

class _MatchPreviewScreenState extends ConsumerState<MatchPreviewScreen> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);

    if (!state.isReadyToCreate) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Preview')),
        body: const Center(child: Text('Match details incomplete')),
      );
    }

    final tossWinnerName = state.tossWinner == state.teamA!.teamId
        ? state.teamA!.name
        : state.teamB!.name;

    final battingFirstName = state.battingFirst == state.teamA!.teamId
        ? state.teamA!.name
        : state.teamB!.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Preview'),
        elevation: 0,
      ),
      body: _isCreating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating match...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Match header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTeamLogo(
                                state.teamA!.name, state.teamA!.logoUrl),
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildTeamLogo(
                                state.teamB!.name, state.teamB!.logoUrl),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${state.teamA!.name} vs ${state.teamB!.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Match details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Match Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildDetailRow('Format', '${state.overs} Overs'),
                        _buildDetailRow('Ground', state.ground),
                        _buildDetailRow(
                          'Date',
                          '${state.matchDate.day}/${state.matchDate.month}/${state.matchDate.year} '
                              '${state.matchDate.hour}:${state.matchDate.minute.toString().padLeft(2, '0')}',
                        ),
                        _buildDetailRow(
                          'Ball Type',
                          state.ballType == 'tennis'
                              ? 'Tennis Ball'
                              : 'Hard Ball',
                        ),
                        if (state.tournamentName != null)
                          _buildDetailRow('Tournament', state.tournamentName!),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toss result
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toss Result',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text(
                          '$tossWinnerName won the toss and chose to '
                          '${state.tossDecision == 'bat' ? 'bat' : 'bowl'} first',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Batting First: $battingFirstName',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Playing XI
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.teamA!.name} Playing XI',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...state.teamASquad!.playingXI
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final player = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('${index + 1}. '),
                                Expanded(child: Text(player.name)),
                                Text(
                                  player.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.teamB!.name} Playing XI',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...state.teamBSquad!.playingXI
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final player = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('${index + 1}. '),
                                Expanded(child: Text(player.name)),
                                Text(
                                  player.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create match button
                ElevatedButton(
                  onPressed: _isCreating ? null : _createMatch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Create Match',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTeamLogo(String name, String? logoUrl) {
    return Column(
      children: [
        if (logoUrl != null)
          Image.network(
            logoUrl,
            height: 60,
            width: 60,
            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 60),
          )
        else
          const Icon(Icons.shield, size: 60),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _createMatch() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final notifier = ref.read(matchCreationProvider.notifier);
      final matchId = await notifier.createMatch();

      if (mounted) {
        // Reset the state
        notifier.reset();

        // Navigate to match details
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to match details screen
        // Navigator.pushNamed(context, '/match/$matchId');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating match: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
