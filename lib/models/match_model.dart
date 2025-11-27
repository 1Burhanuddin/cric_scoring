import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamInfo {
  final String teamId;
  final String name;
  final String? logoUrl;
  final String color;

  const TeamInfo({
    required this.teamId,
    required this.name,
    this.logoUrl,
    required this.color,
  });

  factory TeamInfo.fromMap(Map<String, dynamic> data) {
    return TeamInfo(
      teamId: data['teamId'] ?? '',
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      color: data['color'] ?? '0xFF1E88E5',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'name': name,
      'logoUrl': logoUrl,
      'color': color,
    };
  }

  String get initials => name.split(' ').map((e) => e[0]).take(2).join();
  Color get colorValue => Color(int.parse(color));
}

class Match {
  final String matchId;
  final String? tournamentId;
  final TeamInfo teamA;
  final TeamInfo teamB;
  final int overs;
  final String ground;
  final DateTime date;
  final String status;
  final String createdBy; // User ID of match creator
  final List<String> scorers; // User IDs who can score
  final String? tossWinner;
  final String? tossDecision;
  final String? battingFirst;
  final String? result;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Match({
    required this.matchId,
    this.tournamentId,
    required this.teamA,
    required this.teamB,
    required this.overs,
    required this.ground,
    required this.date,
    required this.status,
    required this.createdBy,
    this.scorers = const [],
    this.tossWinner,
    this.tossDecision,
    this.battingFirst,
    this.result,
    this.winnerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match(
      matchId: doc.id,
      tournamentId: data['tournamentId'],
      teamA: TeamInfo.fromMap(data['teamA'] ?? {}),
      teamB: TeamInfo.fromMap(data['teamB'] ?? {}),
      overs: data['overs'] ?? 20,
      ground: data['ground'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'upcoming',
      createdBy: data['createdBy'] ?? '',
      scorers: List<String>.from(data['scorers'] ?? []),
      tossWinner: data['tossWinner'],
      tossDecision: data['tossDecision'],
      battingFirst: data['battingFirst'],
      result: data['result'],
      winnerId: data['winnerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'tournamentId': tournamentId,
      'teamA': teamA.toMap(),
      'teamB': teamB.toMap(),
      'overs': overs,
      'ground': ground,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdBy': createdBy,
      'scorers': scorers,
      'tossWinner': tossWinner,
      'tossDecision': tossDecision,
      'battingFirst': battingFirst,
      'result': result,
      'winnerId': winnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isLive => status == 'live';
  bool get isCompleted => status == 'completed';
  bool get isUpcoming => status == 'upcoming';

  // Check if user can score this match
  bool canUserScore(String userId) {
    return createdBy == userId || scorers.contains(userId);
  }
}
