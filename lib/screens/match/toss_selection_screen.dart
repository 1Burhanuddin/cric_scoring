import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

class TossSelectionScreen extends ConsumerStatefulWidget {
  const TossSelectionScreen({super.key});

  @override
  ConsumerState<TossSelectionScreen> createState() =>
      _TossSelectionScreenState();
}

class _TossSelectionScreenState extends ConsumerState<TossSelectionScreen> {
  String? _tossWinner;
  String? _tossDecision;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who won the toss?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              state.teamA!.name,
              Color(int.parse(state.teamA!.color)),
              state.teamA!.teamId,
            ),
            const SizedBox(height: 12),
            _buildTeamCard(
              state.teamB!.name,
              Color(int.parse(state.teamB!.color)),
              state.teamB!.teamId,
            ),
            if (_tossWinner != null) ...[
              const SizedBox(height: 32),
              const Text(
                'What did they choose?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDecisionCard('Bat First', 'bat', Icons.sports_cricket),
              const SizedBox(height: 12),
              _buildDecisionCard('Bowl First', 'bowl', Icons.sports_baseball),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _tossWinner != null && _tossDecision != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createMatch,
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
            )
          : null,
    );
  }

  Future<void> _createMatch() async {
    setState(() => _isCreating = true);

    try {
      final auth = ref.read(firebaseAuthProvider);
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final notifier = ref.read(matchCreationProvider.notifier);

      // Set toss info
      notifier.setToss(_tossWinner!, _tossDecision!);

      // Create match
      await notifier.createMatch(currentUser.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match created! Start scoring from match details.'),
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

  Widget _buildTeamCard(String teamName, Color teamColor, String teamId) {
    final isSelected = _tossWinner == teamId;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _tossWinner = teamId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: teamColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionCard(String title, String value, IconData icon) {
    final isSelected = _tossDecision == value;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _tossDecision = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
