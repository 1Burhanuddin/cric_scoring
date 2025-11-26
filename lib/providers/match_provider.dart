import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/models/team_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// Matches list provider
final matchesListProvider = StreamProvider<List<Match>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList();
  });
});

// Matches by status provider
final matchesByStatusProvider =
    StreamProvider.family<List<Match>, String>((ref, status) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .where('status', isEqualTo: status)
      .snapshots()
      .map((snapshot) {
    final matches =
        snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList();
    // Sort in memory to avoid composite index requirement
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches;
  });
});

// Match provider notifier for CRUD operations
final matchProviderNotifier =
    StateNotifierProvider<MatchNotifier, AsyncValue<void>>((ref) {
  return MatchNotifier(ref.watch(firestoreProvider));
});

class MatchNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  MatchNotifier(this._firestore) : super(const AsyncValue.data(null));

  // Create match
  Future<String> createMatch({
    required Team teamA,
    required Team teamB,
    required int overs,
    required String ground,
    required DateTime date,
    required String ballType,
  }) async {
    state = const AsyncValue.loading();

    try {
      final matchRef = _firestore.collection('matches').doc();

      final teamAInfo = TeamInfo(
        teamId: teamA.teamId,
        name: teamA.name,
        logoUrl: teamA.logoUrl,
        color: teamA.color,
      );

      final teamBInfo = TeamInfo(
        teamId: teamB.teamId,
        name: teamB.name,
        logoUrl: teamB.logoUrl,
        color: teamB.color,
      );

      await matchRef.set({
        'matchId': matchRef.id,
        'teamA': teamAInfo.toMap(),
        'teamB': teamBInfo.toMap(),
        'overs': overs,
        'ground': ground,
        'date': Timestamp.fromDate(date),
        'status': 'upcoming',
        'ballType': ballType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize innings
      await _initializeInnings(matchRef.id, teamAInfo.teamId, teamBInfo.teamId);

      state = const AsyncValue.data(null);
      return matchRef.id;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Initialize innings for a match
  Future<void> _initializeInnings(
    String matchId,
    String teamAId,
    String teamBId,
  ) async {
    final batch = _firestore.batch();

    // Innings 1
    final innings1Ref = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc('1');

    batch.set(innings1Ref, {
      'inningsNumber': 1,
      'battingTeamId': teamAId,
      'bowlingTeamId': teamBId,
      'runs': 0,
      'wickets': 0,
      'overs': 0.0,
      'extras': {
        'wides': 0,
        'noBalls': 0,
        'byes': 0,
        'legByes': 0,
      },
      'isDeclared': false,
      'isCompleted': false,
    });

    // Innings 2
    final innings2Ref = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc('2');

    batch.set(innings2Ref, {
      'inningsNumber': 2,
      'battingTeamId': teamBId,
      'bowlingTeamId': teamAId,
      'runs': 0,
      'wickets': 0,
      'overs': 0.0,
      'extras': {
        'wides': 0,
        'noBalls': 0,
        'byes': 0,
        'legByes': 0,
      },
      'isDeclared': false,
      'isCompleted': false,
    });

    await batch.commit();
  }

  // Update match status
  Future<void> updateMatchStatus(String matchId, String status) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Start match
  Future<void> startMatch(String matchId) async {
    await updateMatchStatus(matchId, 'live');
  }

  // Complete match
  Future<void> completeMatch(
    String matchId, {
    required String winnerId,
    required String result,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'completed',
        'winnerId': winnerId,
        'result': result,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Delete match
  Future<void> deleteMatch(String matchId) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('matches').doc(matchId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
