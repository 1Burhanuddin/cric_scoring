import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamStats {
  final int matches;
  final int wins;
  final int losses;
  final double winPercentage;
  final String? highestScore;
  final String? lowestScore;

  const TeamStats({
    this.matches = 0,
    this.wins = 0,
    this.losses = 0,
    this.winPercentage = 0.0,
    this.highestScore,
    this.lowestScore,
  });

  factory TeamStats.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const TeamStats();

    return TeamStats(
      matches: data['matches'] ?? 0,
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      winPercentage: (data['winPercentage'] ?? 0.0).toDouble(),
      highestScore: data['highestScore'],
      lowestScore: data['lowestScore'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matches': matches,
      'wins': wins,
      'losses': losses,
      'winPercentage': winPercentage,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
    };
  }
}

class Team {
  final String teamId;
  final String name;
  final String city;
  final String? logoUrl;
  final String color;
  final TeamStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Team({
    required this.teamId,
    required this.name,
    required this.city,
    this.logoUrl,
    required this.color,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      teamId: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      logoUrl: data['logoUrl'],
      color: data['color'] ?? '0xFF1E88E5',
      stats: TeamStats.fromMap(data['stats']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'name': name,
      'city': city,
      'logoUrl': logoUrl,
      'color': color,
      'stats': stats.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get initials => name.split(' ').map((e) => e[0]).take(2).join();
  Color get colorValue => Color(int.parse(color));
}
