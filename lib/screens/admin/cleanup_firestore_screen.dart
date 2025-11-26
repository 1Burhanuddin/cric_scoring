import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CleanupFirestoreScreen extends StatefulWidget {
  const CleanupFirestoreScreen({super.key});

  @override
  State<CleanupFirestoreScreen> createState() => _CleanupFirestoreScreenState();
}

class _CleanupFirestoreScreenState extends State<CleanupFirestoreScreen> {
  bool _isLoading = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleanup Firestore'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'WARNING',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will delete ALL data from Firestore. This action cannot be undone!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteAllTeams,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete All Teams'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteAllMatches,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete All Matches'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteAllPlayers,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete All Players'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteEverything,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('DELETE EVERYTHING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_status.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _status,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAllTeams() async {
    final confirm = await _showConfirmDialog('Delete All Teams?');
    if (!confirm) return;

    setState(() {
      _isLoading = true;
      _status = 'Deleting teams...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final teams = await firestore.collection('teams').get();

      int count = 0;
      for (var doc in teams.docs) {
        // Delete subcollections first
        final players = await doc.reference.collection('players').get();
        for (var player in players.docs) {
          await player.reference.delete();
        }

        await doc.reference.delete();
        count++;
      }

      setState(() {
        _status = 'Deleted $count teams successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllMatches() async {
    final confirm = await _showConfirmDialog('Delete All Matches?');
    if (!confirm) return;

    setState(() {
      _isLoading = true;
      _status = 'Deleting matches...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final matches = await firestore.collection('matches').get();

      int count = 0;
      for (var doc in matches.docs) {
        // Delete subcollections
        final innings = await doc.reference.collection('innings').get();
        for (var inning in innings.docs) {
          await inning.reference.delete();
        }

        final balls = await doc.reference.collection('balls').get();
        for (var ball in balls.docs) {
          await ball.reference.delete();
        }

        await doc.reference.delete();
        count++;
      }

      setState(() {
        _status = 'Deleted $count matches successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllPlayers() async {
    final confirm = await _showConfirmDialog('Delete All Players?');
    if (!confirm) return;

    setState(() {
      _isLoading = true;
      _status = 'Deleting players...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final players = await firestore.collection('players').get();

      int count = 0;
      for (var doc in players.docs) {
        await doc.reference.delete();
        count++;
      }

      setState(() {
        _status = 'Deleted $count players successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEverything() async {
    final confirm = await _showConfirmDialog(
      'DELETE EVERYTHING?\n\nThis will delete:\n- All teams\n- All matches\n- All players\n- All subcollections\n\nThis CANNOT be undone!',
    );
    if (!confirm) return;

    setState(() {
      _isLoading = true;
      _status = 'Deleting everything...';
    });

    try {
      await _deleteAllTeams();
      await _deleteAllMatches();
      await _deleteAllPlayers();

      setState(() {
        _status = 'All data deleted successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool> _showConfirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
