import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

class TeamPlayersDebugScreen extends ConsumerWidget {
  final String teamId;
  final String teamName;

  const TeamPlayersDebugScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug: $teamName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('teams')
            .doc(teamId)
            .collection('players')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error loading players'),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Team Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Team Name: $teamName'),
                      Text('Team ID: $teamId'),
                      Text('Players Found: ${docs.length}'),
                      const SizedBox(height: 8),
                      Text(
                        'Path: teams/$teamId/players',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.warning, size: 48, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          'No players in subcollection',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Players must be added to:\nteams/{teamId}/players',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          data['jerseyNumber']?.toString() ?? '?',
                        ),
                      ),
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Role: ${data['role'] ?? 'N/A'}'),
                          Text(
                            'Doc ID: ${doc.id}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (data['isCaptain'] == true)
                            const Text('C',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          if (data['isWicketKeeper'] == true)
                            const Text('WK',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
