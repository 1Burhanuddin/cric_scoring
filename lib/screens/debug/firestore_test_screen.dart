import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  final _teamIdController = TextEditingController(
    text: 'MNVBWAPz7Ej90LIef2Ev', // Default from screenshot
  );
  String _result = '';
  bool _loading = false;

  Future<void> _testQuery() async {
    setState(() {
      _loading = true;
      _result = 'Testing...';
    });

    try {
      final teamId = _teamIdController.text.trim();
      debugPrint('Testing query for team: $teamId');

      final snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .get();

      debugPrint('Query completed. Found ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        setState(() {
          _result = '❌ No players found in:\nteams/$teamId/players';
          _loading = false;
        });
        return;
      }

      final players = snapshot.docs.map((doc) {
        final data = doc.data();
        return '✅ ${data['name'] ?? 'Unknown'} (#${data['jerseyNumber'] ?? '?'})';
      }).join('\n');

      setState(() {
        _result = '✅ Found ${snapshot.docs.length} players:\n\n$players';
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('ERROR: $e');
      debugPrint('Stack: $stack');
      setState(() {
        _result = '❌ Error:\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Firestore Query',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamIdController,
              decoration: const InputDecoration(
                labelText: 'Team ID',
                border: OutlineInputBorder(),
                helperText: 'Enter the team ID from the screenshot',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _testQuery,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Query'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _result,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _teamIdController.dispose();
    super.dispose();
  }
}
