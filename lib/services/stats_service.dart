import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/player_stats_model.dart';

class StatsService {
  final FirebaseFirestore _firestore;

  StatsService(this._firestore);

  /// Update player stats after a match
  Future<void> updatePlayerStats({
    required String playerId,
    required int runs,
    required int ballsFaced,
    required int fours,
    required int sixes,
    required bool isOut,
    required int wickets,
    required int ballsBowled,
    required int runsConceded,
    required int maidens,
    required int catches,
    required int runOuts,
    required int stumpings,
  }) async {
    final statsRef = _firestore.collection('playerStats').doc(playerId);

    await _firestore.runTransaction((transaction) async {
      final statsDoc = await transaction.get(statsRef);

      PlayerStats currentStats;
      if (statsDoc.exists) {
        currentStats = PlayerStats.fromMap(statsDoc.data()!);
      } else {
        currentStats = PlayerStats(
          playerId: playerId,
          lastUpdated: DateTime.now(),
        );
      }

      // Update batting stats
      final newTotalRuns = currentStats.totalRuns + runs;
      final newBallsFaced = currentStats.ballsFaced + ballsFaced;
      final newFours = currentStats.fours + fours;
      final newSixes = currentStats.sixes + sixes;
      final newHighestScore =
          runs > currentStats.highestScore ? runs : currentStats.highestScore;
      final newNotOuts =
          isOut ? currentStats.notOuts : currentStats.notOuts + 1;

      // Check for fifties and hundreds
      int newFifties = currentStats.fifties;
      int newHundreds = currentStats.hundreds;
      if (runs >= 100) {
        newHundreds++;
      } else if (runs >= 50) {
        newFifties++;
      }

      // Update bowling stats
      final newTotalWickets = currentStats.totalWickets + wickets;
      final newBallsBowled = currentStats.ballsBowled + ballsBowled;
      final newRunsConceded = currentStats.runsConceded + runsConceded;
      final newMaidens = currentStats.maidens + maidens;

      // Check for 4W and 5W
      int newFourWickets = currentStats.fourWickets;
      int newFiveWickets = currentStats.fiveWickets;
      if (wickets >= 5) {
        newFiveWickets++;
      } else if (wickets >= 4) {
        newFourWickets++;
      }

      // Update best bowling
      String? newBestBowling = currentStats.bestBowling;
      if (wickets > 0) {
        if (newBestBowling == null) {
          newBestBowling = '$wickets/$runsConceded';
        } else {
          final parts = newBestBowling.split('/');
          final bestWickets = int.tryParse(parts[0]) ?? 0;
          final bestRuns = int.tryParse(parts[1]) ?? 999;

          if (wickets > bestWickets ||
              (wickets == bestWickets && runsConceded < bestRuns)) {
            newBestBowling = '$wickets/$runsConceded';
          }
        }
      }

      // Update fielding stats
      final newCatches = currentStats.catches + catches;
      final newRunOuts = currentStats.runOuts + runOuts;
      final newStumpings = currentStats.stumpings + stumpings;

      final updatedStats = currentStats.copyWith(
        matchesPlayed: currentStats.matchesPlayed + 1,
        totalRuns: newTotalRuns,
        ballsFaced: newBallsFaced,
        fours: newFours,
        sixes: newSixes,
        highestScore: newHighestScore,
        fifties: newFifties,
        hundreds: newHundreds,
        notOuts: newNotOuts,
        totalWickets: newTotalWickets,
        ballsBowled: newBallsBowled,
        runsConceded: newRunsConceded,
        maidens: newMaidens,
        bestBowling: newBestBowling,
        fourWickets: newFourWickets,
        fiveWickets: newFiveWickets,
        catches: newCatches,
        runOuts: newRunOuts,
        stumpings: newStumpings,
        lastUpdated: DateTime.now(),
      );

      transaction.set(statsRef, updatedStats.toMap(), SetOptions(merge: true));
    });
  }

  /// Batch update stats for all players in a match
  Future<void> updateMatchStats({
    required String matchId,
    required Map<String, dynamic> battingStats,
    required Map<String, dynamic> bowlingStats,
    required Map<String, dynamic> fieldingStats,
  }) async {
    // Process each player's stats
    final allPlayerIds = <String>{
      ...battingStats.keys,
      ...bowlingStats.keys,
      ...fieldingStats.keys,
    };

    for (final playerId in allPlayerIds) {
      final batting = battingStats[playerId] ?? {};
      final bowling = bowlingStats[playerId] ?? {};
      final fielding = fieldingStats[playerId] ?? {};

      await updatePlayerStats(
        playerId: playerId,
        runs: batting['runs'] ?? 0,
        ballsFaced: batting['balls'] ?? 0,
        fours: batting['fours'] ?? 0,
        sixes: batting['sixes'] ?? 0,
        isOut: batting['isOut'] ?? false,
        wickets: bowling['wickets'] ?? 0,
        ballsBowled: bowling['balls'] ?? 0,
        runsConceded: bowling['runs'] ?? 0,
        maidens: bowling['maidens'] ?? 0,
        catches: fielding['catches'] ?? 0,
        runOuts: fielding['runOuts'] ?? 0,
        stumpings: fielding['stumpings'] ?? 0,
      );
    }
  }
}
