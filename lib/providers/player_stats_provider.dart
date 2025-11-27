import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/player_stats_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';
import 'package:cric_scoring/controllers/auth_controller.dart';

// Provider to get player stats by player ID
final playerStatsProvider =
    StreamProvider.family<PlayerStats?, String>((ref, playerId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('playerStats')
      .doc(playerId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) {
      return PlayerStats(
        playerId: playerId,
        lastUpdated: DateTime.now(),
      );
    }
    return PlayerStats.fromMap(doc.data()!);
  });
});

// Provider to get current user's stats
final currentUserStatsProvider = StreamProvider<PlayerStats?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);

  final userId = authState.value?.uid;
  if (userId == null) {
    return Stream.value(null);
  }

  return firestore.collection('playerStats').doc(userId).snapshots().map((doc) {
    if (!doc.exists) {
      return PlayerStats(
        playerId: userId,
        lastUpdated: DateTime.now(),
      );
    }
    return PlayerStats.fromMap(doc.data()!);
  });
});
