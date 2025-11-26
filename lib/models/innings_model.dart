import 'package:cloud_firestore/cloud_firestore.dart';

class Innings {
  final int inningsNumber;
  final String battingTeamId;
  final String bowlingTeamId;
  final int runs;
  final int wickets;
  final double overs;
  final Map<String, int> extras;
  final bool isDeclared;
  final bool isCompleted;

  const Innings({
    required this.inningsNumber,
    required this.battingTeamId,
    required this.bowlingTeamId,
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.extras,
    this.isDeclared = false,
    this.isCompleted = false,
  });

  factory Innings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Innings(
      inningsNumber: data['inningsNumber'] ?? 1,
      battingTeamId: data['battingTeamId'] ?? '',
      bowlingTeamId: data['bowlingTeamId'] ?? '',
      runs: data['runs'] ?? 0,
      wickets: data['wickets'] ?? 0,
      overs: (data['overs'] ?? 0.0).toDouble(),
      extras: Map<String, int>.from(data['extras'] ?? {}),
      isDeclared: data['isDeclared'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inningsNumber': inningsNumber,
      'battingTeamId': battingTeamId,
      'bowlingTeamId': bowlingTeamId,
      'runs': runs,
      'wickets': wickets,
      'overs': overs,
      'extras': extras,
      'isDeclared': isDeclared,
      'isCompleted': isCompleted,
    };
  }

  int get totalExtras =>
      (extras['wides'] ?? 0) +
      (extras['noBalls'] ?? 0) +
      (extras['byes'] ?? 0) +
      (extras['legByes'] ?? 0);

  String get score => '$runs/$wickets';

  String get oversDisplay {
    final completeOvers = overs.floor();
    final balls = ((overs - completeOvers) * 10).round();
    return '$completeOvers.$balls';
  }
}
