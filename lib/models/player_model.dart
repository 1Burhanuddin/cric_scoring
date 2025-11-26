import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String playerId;
  final String name;
  final String? photoUrl;
  final String role; // batsman, bowler, allrounder, wicketkeeper
  final String battingStyle; // right-hand, left-hand
  final String? bowlingStyle; // right-arm-fast, left-arm-spin, etc.
  final int jerseyNumber;
  final DateTime createdAt;

  const Player({
    required this.playerId,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.battingStyle,
    this.bowlingStyle,
    required this.jerseyNumber,
    required this.createdAt,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Player(
      playerId: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'batsman',
      battingStyle: data['battingStyle'] ?? 'right-hand',
      bowlingStyle: data['bowlingStyle'],
      jerseyNumber: data['jerseyNumber'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'battingStyle': battingStyle,
      'bowlingStyle': bowlingStyle,
      'jerseyNumber': jerseyNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get initials => name.split(' ').map((e) => e[0]).take(2).join();
}

class TeamPlayer {
  final String playerId;
  final String name;
  final String role;
  final int jerseyNumber;
  final bool isCaptain;
  final bool isWicketKeeper;

  const TeamPlayer({
    required this.playerId,
    required this.name,
    required this.role,
    required this.jerseyNumber,
    this.isCaptain = false,
    this.isWicketKeeper = false,
  });

  factory TeamPlayer.fromMap(Map<String, dynamic> data) {
    return TeamPlayer(
      playerId: data['playerId'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'batsman',
      jerseyNumber: data['jerseyNumber'] ?? 0,
      isCaptain: data['isCaptain'] ?? false,
      isWicketKeeper: data['isWicketKeeper'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'name': name,
      'role': role,
      'jerseyNumber': jerseyNumber,
      'isCaptain': isCaptain,
      'isWicketKeeper': isWicketKeeper,
    };
  }

  factory TeamPlayer.fromPlayer(Player player,
      {bool isCaptain = false, bool isWicketKeeper = false}) {
    return TeamPlayer(
      playerId: player.playerId,
      name: player.name,
      role: player.role,
      jerseyNumber: player.jerseyNumber,
      isCaptain: isCaptain,
      isWicketKeeper: isWicketKeeper,
    );
  }
}
