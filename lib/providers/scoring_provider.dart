import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/ball_model.dart';
import 'package:cric_scoring/models/innings_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// Current innings provider
final currentInningsProvider =
    StreamProvider.family<Innings?, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('innings')
      .where('isCompleted', isEqualTo: false)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return Innings.fromFirestore(snapshot.docs.first);
  });
});

// Balls in current over provider
final currentOverBallsProvider =
    StreamProvider.family<List<Ball>, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);
  final innings = ref.watch(currentInningsProvider(matchId)).value;

  if (innings == null) {
    return Stream.value([]);
  }

  final currentOver = innings.overs.floor();

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('balls')
      .where('inningsNumber', isEqualTo: innings.inningsNumber)
      .where('overNumber', isEqualTo: currentOver)
      .orderBy('ballNumber')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Ball.fromFirestore(doc)).toList();
  });
});

// Scoring notifier
final scoringNotifierProvider =
    StateNotifierProvider<ScoringNotifier, AsyncValue<void>>((ref) {
  return ScoringNotifier(ref.watch(firestoreProvider));
});

class ScoringNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  ScoringNotifier(this._firestore) : super(const AsyncValue.data(null));

  // Record a ball
  Future<void> recordBall({
    required String matchId,
    required int inningsNumber,
    required String batsmanId,
    required String bowlerId,
    required int runs,
    bool isWide = false,
    bool isNoBall = false,
    bool isBye = false,
    bool isLegBye = false,
    bool isWicket = false,
    String? wicketType,
    String? fielderIds,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Get current innings
      final inningsDoc = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('innings')
          .doc(inningsNumber.toString())
          .get();

      final innings = Innings.fromFirestore(inningsDoc);
      final currentOver = innings.overs.floor();
      final ballsInOver = ((innings.overs - currentOver) * 10).round();

      // Create ball document
      final ballRef = _firestore
          .collection('matches')
          .doc(matchId)
          .collection('balls')
          .doc();

      await ballRef.set({
        'inningsNumber': inningsNumber,
        'overNumber': currentOver,
        'ballNumber': ballsInOver,
        'batsmanId': batsmanId,
        'bowlerId': bowlerId,
        'runs': runs,
        'isWide': isWide,
        'isNoBall': isNoBall,
        'isBye': isBye,
        'isLegBye': isLegBye,
        'isWicket': isWicket,
        'wicketType': wicketType,
        'fielderIds': fielderIds,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update innings
      await _updateInnings(
        matchId: matchId,
        inningsNumber: inningsNumber,
        runs: runs,
        isWide: isWide,
        isNoBall: isNoBall,
        isBye: isBye,
        isLegBye: isLegBye,
        isWicket: isWicket,
        currentOvers: innings.overs,
      );

      // Update batsman stats
      await _updateBatsmanStats(
        matchId: matchId,
        inningsNumber: inningsNumber,
        batsmanId: batsmanId,
        runs: runs,
        isBye: isBye,
        isLegBye: isLegBye,
        isWicket: isWicket,
      );

      // Update bowler stats
      await _updateBowlerStats(
        matchId: matchId,
        inningsNumber: inningsNumber,
        bowlerId: bowlerId,
        runs: runs,
        isWide: isWide,
        isNoBall: isNoBall,
        isBye: isBye,
        isLegBye: isLegBye,
        isWicket: isWicket,
      );

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> _updateInnings({
    required String matchId,
    required int inningsNumber,
    required int runs,
    required bool isWide,
    required bool isNoBall,
    required bool isBye,
    required bool isLegBye,
    required bool isWicket,
    required double currentOvers,
  }) async {
    final inningsRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc(inningsNumber.toString());

    final inningsDoc = await inningsRef.get();
    final innings = Innings.fromFirestore(inningsDoc);

    // Calculate new values
    int newRuns = innings.runs;
    int newWickets = innings.wickets;
    double newOvers = innings.overs;
    final newExtras = Map<String, int>.from(innings.extras);

    // Add runs
    newRuns += runs;
    if (isWide) {
      newRuns += 1;
      newExtras['wides'] = (newExtras['wides'] ?? 0) + 1;
    }
    if (isNoBall) {
      newRuns += 1;
      newExtras['noBalls'] = (newExtras['noBalls'] ?? 0) + 1;
    }
    if (isBye) {
      newExtras['byes'] = (newExtras['byes'] ?? 0) + runs;
    }
    if (isLegBye) {
      newExtras['legByes'] = (newExtras['legByes'] ?? 0) + runs;
    }

    // Add wicket
    if (isWicket) {
      newWickets += 1;
    }

    // Update overs (only if not wide or no-ball)
    if (!isWide && !isNoBall) {
      final currentOver = newOvers.floor();
      final ballsInOver = ((newOvers - currentOver) * 10).round();

      if (ballsInOver >= 5) {
        // Complete over
        newOvers = (currentOver + 1).toDouble();
      } else {
        // Add one ball
        newOvers = currentOver + ((ballsInOver + 1) / 10);
      }
    }

    await inningsRef.update({
      'runs': newRuns,
      'wickets': newWickets,
      'overs': newOvers,
      'extras': newExtras,
    });

    // Update match timestamp
    await _firestore.collection('matches').doc(matchId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Undo last ball
  Future<void> undoLastBall(String matchId, int inningsNumber) async {
    state = const AsyncValue.loading();

    try {
      // Get last ball
      final ballsSnapshot = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('balls')
          .where('inningsNumber', isEqualTo: inningsNumber)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (ballsSnapshot.docs.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final lastBall = Ball.fromFirestore(ballsSnapshot.docs.first);

      // Delete ball
      await ballsSnapshot.docs.first.reference.delete();

      // Reverse innings update
      await _reverseInningsUpdate(matchId, inningsNumber, lastBall);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> _reverseInningsUpdate(
    String matchId,
    int inningsNumber,
    Ball ball,
  ) async {
    final inningsRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc(inningsNumber.toString());

    final inningsDoc = await inningsRef.get();
    final innings = Innings.fromFirestore(inningsDoc);

    int newRuns = innings.runs - ball.runs;
    int newWickets = innings.wickets;
    double newOvers = innings.overs;
    final newExtras = Map<String, int>.from(innings.extras);

    if (ball.isWide) {
      newRuns -= 1;
      newExtras['wides'] = (newExtras['wides'] ?? 0) - 1;
    }
    if (ball.isNoBall) {
      newRuns -= 1;
      newExtras['noBalls'] = (newExtras['noBalls'] ?? 0) - 1;
    }
    if (ball.isBye) {
      newExtras['byes'] = (newExtras['byes'] ?? 0) - ball.runs;
    }
    if (ball.isLegBye) {
      newExtras['legByes'] = (newExtras['legByes'] ?? 0) - ball.runs;
    }
    if (ball.isWicket) {
      newWickets -= 1;
    }

    // Reverse overs
    if (!ball.isWide && !ball.isNoBall) {
      final currentOver = newOvers.floor();
      final ballsInOver = ((newOvers - currentOver) * 10).round();

      if (ballsInOver == 0) {
        newOvers = (currentOver - 1) + 0.5;
      } else {
        newOvers = currentOver + ((ballsInOver - 1) / 10);
      }
    }

    await inningsRef.update({
      'runs': newRuns,
      'wickets': newWickets,
      'overs': newOvers,
      'extras': newExtras,
    });
  }

  Future<void> _updateBatsmanStats({
    required String matchId,
    required int inningsNumber,
    required String batsmanId,
    required int runs,
    required bool isBye,
    required bool isLegBye,
    required bool isWicket,
  }) async {
    final battingRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('batting')
        .doc(batsmanId);

    final battingDoc = await battingRef.get();

    if (!battingDoc.exists) {
      await battingRef.set({
        'playerId': batsmanId,
        'inningsNumber': inningsNumber,
        'runs': isBye || isLegBye ? 0 : runs,
        'balls': 1,
        'fours': runs == 4 && !isBye && !isLegBye ? 1 : 0,
        'sixes': runs == 6 && !isBye && !isLegBye ? 1 : 0,
        'isOut': isWicket,
      });
    } else {
      final data = battingDoc.data() as Map<String, dynamic>;
      await battingRef.update({
        'runs': (data['runs'] ?? 0) + (isBye || isLegBye ? 0 : runs),
        'balls': (data['balls'] ?? 0) + 1,
        'fours':
            (data['fours'] ?? 0) + (runs == 4 && !isBye && !isLegBye ? 1 : 0),
        'sixes':
            (data['sixes'] ?? 0) + (runs == 6 && !isBye && !isLegBye ? 1 : 0),
        'isOut': isWicket ? true : (data['isOut'] ?? false),
      });
    }
  }

  Future<void> _updateBowlerStats({
    required String matchId,
    required int inningsNumber,
    required String bowlerId,
    required int runs,
    required bool isWide,
    required bool isNoBall,
    required bool isBye,
    required bool isLegBye,
    required bool isWicket,
  }) async {
    final bowlingRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('bowling')
        .doc(bowlerId);

    final bowlingDoc = await bowlingRef.get();

    int runsAgainst = runs;
    if (isBye || isLegBye) {
      runsAgainst = 0;
    }
    if (isWide || isNoBall) {
      runsAgainst += 1;
    }

    if (!bowlingDoc.exists) {
      await bowlingRef.set({
        'playerId': bowlerId,
        'inningsNumber': inningsNumber,
        'overs': isWide || isNoBall ? 0.0 : 0.1,
        'runs': runsAgainst,
        'wickets': isWicket ? 1 : 0,
        'wides': isWide ? 1 : 0,
        'noBalls': isNoBall ? 1 : 0,
      });
    } else {
      final data = bowlingDoc.data() as Map<String, dynamic>;
      double currentOvers = (data['overs'] ?? 0.0).toDouble();

      if (!isWide && !isNoBall) {
        final completeOvers = currentOvers.floor();
        final balls = ((currentOvers - completeOvers) * 10).round();
        if (balls >= 5) {
          currentOvers = (completeOvers + 1).toDouble();
        } else {
          currentOvers = completeOvers + ((balls + 1) / 10);
        }
      }

      await bowlingRef.update({
        'overs': currentOvers,
        'runs': (data['runs'] ?? 0) + runsAgainst,
        'wickets': (data['wickets'] ?? 0) + (isWicket ? 1 : 0),
        'wides': (data['wides'] ?? 0) + (isWide ? 1 : 0),
        'noBalls': (data['noBalls'] ?? 0) + (isNoBall ? 1 : 0),
      });
    }
  }
}
