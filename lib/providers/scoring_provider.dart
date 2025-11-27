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

// Innings 1 provider (for showing target)
final innings1Provider =
    StreamProvider.family<Innings?, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('innings')
      .doc('1')
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return Innings.fromFirestore(snapshot);
  });
});

// Innings 2 provider
final innings2Provider =
    StreamProvider.family<Innings?, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('innings')
      .doc('2')
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return Innings.fromFirestore(snapshot);
  });
});

// Batting stats provider
final battingStatsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('batting')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});

// Bowling stats provider
final bowlingStatsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('bowling')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
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

    // Use transaction for immediate atomic updates
    await _firestore.runTransaction((transaction) async {
      final inningsDoc = await transaction.get(inningsRef);
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
          // Complete over (6 balls done: 0,1,2,3,4,5)
          newOvers = (currentOver + 1).toDouble();
        } else {
          // Add one ball properly
          newOvers = currentOver.toDouble() + ((ballsInOver + 1) / 10.0);
        }
      }

      // Get match details for overs limit and playing XI count
      final matchDoc =
          await transaction.get(_firestore.collection('matches').doc(matchId));
      final matchData = matchDoc.data() as Map<String, dynamic>;
      final maxOvers = matchData['overs'] ?? 20;

      // Get batting team's playing XI count
      final battingTeamId = innings.battingTeamId;
      final playingXI = battingTeamId == matchData['teamA']['teamId']
          ? (matchData['teamAPlayingXI'] as List?)
          : (matchData['teamBPlayingXI'] as List?);
      final totalPlayers = playingXI?.length ?? 11;
      final maxWickets = totalPlayers - 1; // All out = total players - 1

      // Check if innings is complete
      bool isInningsComplete =
          newWickets >= maxWickets || newOvers.floor() >= maxOvers;

      // For innings 2, also check if target is chased
      if (inningsNumber == 2) {
        final innings1Doc = await transaction.get(_firestore
            .collection('matches')
            .doc(matchId)
            .collection('innings')
            .doc('1'));
        if (innings1Doc.exists) {
          final innings1 = Innings.fromFirestore(innings1Doc);
          if (newRuns > innings1.runs) {
            isInningsComplete = true; // Target chased!
          }
        }
      }

      transaction.update(inningsRef, {
        'runs': newRuns,
        'wickets': newWickets,
        'overs': newOvers,
        'extras': newExtras,
        'isCompleted': isInningsComplete,
      });

      transaction.update(_firestore.collection('matches').doc(matchId), {
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return isInningsComplete;
    }).then((isInningsComplete) async {
      if (isInningsComplete) {
        await _handleInningsCompletion(matchId, inningsNumber, 0);
      }
    });
  }

  Future<void> _handleInningsCompletion(
      String matchId, int inningsNumber, int runs) async {
    final matchDoc = await _firestore.collection('matches').doc(matchId).get();
    final matchData = matchDoc.data() as Map<String, dynamic>;

    if (inningsNumber == 1) {
      // Start second innings
      final battingTeamId =
          matchData['teamA']['teamId'] == matchData['battingFirst']
              ? matchData['teamB']['teamId']
              : matchData['teamA']['teamId'];
      final bowlingTeamId =
          matchData['teamA']['teamId'] == matchData['battingFirst']
              ? matchData['teamA']['teamId']
              : matchData['teamB']['teamId'];

      await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('innings')
          .doc('2')
          .update({
        'battingTeamId': battingTeamId,
        'bowlingTeamId': bowlingTeamId,
      });
    } else {
      // Match complete - calculate result
      await _calculateMatchResult(matchId);
    }
  }

  Future<void> _calculateMatchResult(String matchId) async {
    final matchDoc = await _firestore.collection('matches').doc(matchId).get();
    final matchData = matchDoc.data() as Map<String, dynamic>;

    final innings1Doc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc('1')
        .get();
    final innings2Doc = await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('innings')
        .doc('2')
        .get();

    final innings1 = Innings.fromFirestore(innings1Doc);
    final innings2 = Innings.fromFirestore(innings2Doc);

    // Get playing XI counts for accurate wickets calculation
    final teamBPlayingXI = matchData['teamBPlayingXI'] as List?;
    final totalPlayersTeamB = teamBPlayingXI?.length ?? 11;
    final maxWicketsTeamB = totalPlayersTeamB - 1;

    String result;
    String? winnerId;

    if (innings2.runs > innings1.runs) {
      winnerId = innings2.battingTeamId;
      final wicketsLeft = maxWicketsTeamB - innings2.wickets;
      result =
          '${_getTeamName(matchData, winnerId)} won by $wicketsLeft wickets';
    } else if (innings1.runs > innings2.runs) {
      winnerId = innings1.battingTeamId;
      final margin = innings1.runs - innings2.runs;
      result = '${_getTeamName(matchData, winnerId)} won by $margin runs';
    } else {
      result = 'Match tied';
    }

    await _firestore.collection('matches').doc(matchId).update({
      'status': 'completed',
      'result': result,
      'winnerId': winnerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _getTeamName(Map<String, dynamic> matchData, String teamId) {
    if (matchData['teamA']['teamId'] == teamId) {
      return matchData['teamA']['name'];
    }
    return matchData['teamB']['name'];
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
