import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/screens/match/match_preview_screen.dart';

class TossScreen extends ConsumerStatefulWidget {
  const TossScreen({super.key});

  @override
  ConsumerState<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends ConsumerState<TossScreen> {
  String? _tossWinner;
  String? _tossDecision;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);

    if (state.teamA == null || state.teamB == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toss')),
        body: const Center(child: Text('Teams not selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toss'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Who won the toss?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Toss winner selection
            Row(
              children: [
                Expanded(
                  child: _buildTeamCard(
                    state.teamA!.name,
                    state.teamA!.teamId,
                    state.teamA!.logoUrl,
                    _tossWinner == state.teamA!.teamId,
                    () {
                      setState(() {
                        _tossWinner = state.teamA!.teamId;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamCard(
                    state.teamB!.name,
                    state.teamB!.teamId,
                    state.teamB!.logoUrl,
                    _tossWinner == state.teamB!.teamId,
                    () {
                      setState(() {
                        _tossWinner = state.teamB!.teamId;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (_tossWinner != null) ...[
              const Text(
                'Choose to:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Toss decision
              Row(
                children: [
                  Expanded(
                    child: _buildDecisionCard(
                      'Bat First',
                      Icons.sports_cricket,
                      'bat',
                      _tossDecision == 'bat',
                      () {
                        setState(() {
                          _tossDecision = 'bat';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDecisionCard(
                      'Bowl First',
                      Icons.sports_baseball,
                      'bowl',
                      _tossDecision == 'bowl',
                      () {
                        setState(() {
                          _tossDecision = 'bowl';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Next button
            ElevatedButton(
              onPressed: _tossWinner != null && _tossDecision != null
                  ? () {
                      notifier.setToss(_tossWinner!, _tossDecision!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MatchPreviewScreen(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Next: Preview Match'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(
    String name,
    String teamId,
    String? logoUrl,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.blue.shade50 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (logoUrl != null)
                Image.network(
                  logoUrl,
                  height: 50,
                  width: 50,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 50),
                )
              else
                const Icon(Icons.shield, size: 50),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Icon(Icons.check_circle, color: Colors.blue, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionCard(
    String label,
    IconData icon,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.green.shade50 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
