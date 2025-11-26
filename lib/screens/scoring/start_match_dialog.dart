import 'package:flutter/material.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartMatchDialog extends StatefulWidget {
  final Match match;

  const StartMatchDialog({super.key, required this.match});

  @override
  State<StartMatchDialog> createState() => _StartMatchDialogState();
}

class _StartMatchDialogState extends State<StartMatchDialog> {
  String? tossWinner;
  String? tossDecision;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Match'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toss Winner',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(widget.match.teamA.name),
                  value: widget.match.teamA.teamId,
                  groupValue: tossWinner,
                  onChanged: (value) => setState(() => tossWinner = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(widget.match.teamB.name),
                  value: widget.match.teamB.teamId,
                  groupValue: tossWinner,
                  onChanged: (value) => setState(() => tossWinner = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Elected to',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Bat'),
                  value: 'bat',
                  groupValue: tossDecision,
                  onChanged: (value) => setState(() => tossDecision = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Bowl'),
                  value: 'bowl',
                  groupValue: tossDecision,
                  onChanged: (value) => setState(() => tossDecision = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (tossWinner != null && tossDecision != null && !isLoading)
              ? _startMatch
              : null,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Start Match'),
        ),
      ],
    );
  }

  Future<void> _startMatch() async {
    setState(() => isLoading = true);

    try {
      final battingFirst = tossDecision == 'bat' ? tossWinner : _getOtherTeam();

      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.match.matchId)
          .update({
        'status': 'live',
        'tossWinner': tossWinner,
        'tossDecision': tossDecision,
        'battingFirst': battingFirst,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true);
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

  String _getOtherTeam() {
    return tossWinner == widget.match.teamA.teamId
        ? widget.match.teamB.teamId
        : widget.match.teamA.teamId;
  }
}
