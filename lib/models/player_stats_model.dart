class PlayerStats {
  final String playerId;
  final int matchesPlayed;

  // Batting stats
  final int totalRuns;
  final int ballsFaced;
  final int fours;
  final int sixes;
  final int highestScore;
  final int fifties;
  final int hundreds;
  final int notOuts;

  // Bowling stats
  final int totalWickets;
  final int ballsBowled;
  final int runsConceded;
  final int maidens;
  final String? bestBowling; // e.g., "5/23"
  final int fourWickets;
  final int fiveWickets;

  // Fielding stats
  final int catches;
  final int runOuts;
  final int stumpings;

  final DateTime lastUpdated;

  const PlayerStats({
    required this.playerId,
    this.matchesPlayed = 0,
    this.totalRuns = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.highestScore = 0,
    this.fifties = 0,
    this.hundreds = 0,
    this.notOuts = 0,
    this.totalWickets = 0,
    this.ballsBowled = 0,
    this.runsConceded = 0,
    this.maidens = 0,
    this.bestBowling,
    this.fourWickets = 0,
    this.fiveWickets = 0,
    this.catches = 0,
    this.runOuts = 0,
    this.stumpings = 0,
    required this.lastUpdated,
  });

  // Calculated stats
  double get battingAverage {
    final innings = matchesPlayed - notOuts;
    if (innings == 0) return 0.0;
    return totalRuns / innings;
  }

  double get strikeRate {
    if (ballsFaced == 0) return 0.0;
    return (totalRuns / ballsFaced) * 100;
  }

  double get bowlingAverage {
    if (totalWickets == 0) return 0.0;
    return runsConceded / totalWickets;
  }

  double get economy {
    if (ballsBowled == 0) return 0.0;
    final overs = ballsBowled / 6;
    return runsConceded / overs;
  }

  double get bowlingStrikeRate {
    if (totalWickets == 0) return 0.0;
    return ballsBowled / totalWickets;
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      playerId: map['playerId'] ?? '',
      matchesPlayed: map['matchesPlayed'] ?? 0,
      totalRuns: map['totalRuns'] ?? 0,
      ballsFaced: map['ballsFaced'] ?? 0,
      fours: map['fours'] ?? 0,
      sixes: map['sixes'] ?? 0,
      highestScore: map['highestScore'] ?? 0,
      fifties: map['fifties'] ?? 0,
      hundreds: map['hundreds'] ?? 0,
      notOuts: map['notOuts'] ?? 0,
      totalWickets: map['totalWickets'] ?? 0,
      ballsBowled: map['ballsBowled'] ?? 0,
      runsConceded: map['runsConceded'] ?? 0,
      maidens: map['maidens'] ?? 0,
      bestBowling: map['bestBowling'],
      fourWickets: map['fourWickets'] ?? 0,
      fiveWickets: map['fiveWickets'] ?? 0,
      catches: map['catches'] ?? 0,
      runOuts: map['runOuts'] ?? 0,
      stumpings: map['stumpings'] ?? 0,
      lastUpdated: map['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'matchesPlayed': matchesPlayed,
      'totalRuns': totalRuns,
      'ballsFaced': ballsFaced,
      'fours': fours,
      'sixes': sixes,
      'highestScore': highestScore,
      'fifties': fifties,
      'hundreds': hundreds,
      'notOuts': notOuts,
      'totalWickets': totalWickets,
      'ballsBowled': ballsBowled,
      'runsConceded': runsConceded,
      'maidens': maidens,
      'bestBowling': bestBowling,
      'fourWickets': fourWickets,
      'fiveWickets': fiveWickets,
      'catches': catches,
      'runOuts': runOuts,
      'stumpings': stumpings,
      'lastUpdated': lastUpdated,
    };
  }

  PlayerStats copyWith({
    int? matchesPlayed,
    int? totalRuns,
    int? ballsFaced,
    int? fours,
    int? sixes,
    int? highestScore,
    int? fifties,
    int? hundreds,
    int? notOuts,
    int? totalWickets,
    int? ballsBowled,
    int? runsConceded,
    int? maidens,
    String? bestBowling,
    int? fourWickets,
    int? fiveWickets,
    int? catches,
    int? runOuts,
    int? stumpings,
    DateTime? lastUpdated,
  }) {
    return PlayerStats(
      playerId: playerId,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      totalRuns: totalRuns ?? this.totalRuns,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      highestScore: highestScore ?? this.highestScore,
      fifties: fifties ?? this.fifties,
      hundreds: hundreds ?? this.hundreds,
      notOuts: notOuts ?? this.notOuts,
      totalWickets: totalWickets ?? this.totalWickets,
      ballsBowled: ballsBowled ?? this.ballsBowled,
      runsConceded: runsConceded ?? this.runsConceded,
      maidens: maidens ?? this.maidens,
      bestBowling: bestBowling ?? this.bestBowling,
      fourWickets: fourWickets ?? this.fourWickets,
      fiveWickets: fiveWickets ?? this.fiveWickets,
      catches: catches ?? this.catches,
      runOuts: runOuts ?? this.runOuts,
      stumpings: stumpings ?? this.stumpings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
