import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/team_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// Team list provider
final teamsListProvider = StreamProvider<List<Team>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('teams')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList();
  });
});

// Team provider notifier for CRUD operations
final teamProviderNotifier =
    StateNotifierProvider<TeamNotifier, AsyncValue<void>>((ref) {
  return TeamNotifier(ref.watch(firestoreProvider));
});

class TeamNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  TeamNotifier(this._firestore) : super(const AsyncValue.data(null));

  // Create team
  Future<void> createTeam({
    required String name,
    required String city,
    required String color,
  }) async {
    state = const AsyncValue.loading();

    try {
      final teamRef = _firestore.collection('teams').doc();

      await teamRef.set({
        'teamId': teamRef.id,
        'name': name,
        'city': city,
        'color': color,
        'stats': {
          'matches': 0,
          'wins': 0,
          'losses': 0,
          'winPercentage': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Update team
  Future<void> updateTeam({
    required String teamId,
    required String name,
    required String city,
    required String color,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('teams').doc(teamId).update({
        'name': name,
        'city': city,
        'color': color,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Delete team
  Future<void> deleteTeam(String teamId) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('teams').doc(teamId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
