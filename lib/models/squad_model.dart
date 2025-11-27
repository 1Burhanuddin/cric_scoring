import 'package:cloud_firestore/cloud_firestore.dart';

class SquadPlayer {
  final String playerId;
  final String name;
  final String role;
  final String? photoUrl;
  final bool isPlaying;

  const SquadPlayer({
    required this.playerId,
    required this.name,
    required this.role,
    this.photoUrl,
    this.isPlaying = false,
  });

  factory SquadPlayer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SquadPlayer(
      playerId: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      photoUrl: data['photoUrl'],
      isPlaying: data['isPlaying'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'isPlaying': isPlaying,
    };
  }

  SquadPlayer copyWith({
    String? name,
    String? role,
    String? photoUrl,
    bool? isPlaying,
  }) {
    return SquadPlayer(
      playerId: playerId,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  bool get isWicketKeeper =>
      role.toLowerCase().contains('keeper') ||
      role.toLowerCase() == 'wicket-keeper';
}

class TeamSquad {
  final String teamId;
  final String teamName;
  final List<SquadPlayer> players;

  const TeamSquad({
    required this.teamId,
    required this.teamName,
    required this.players,
  });

  factory TeamSquad.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => SquadPlayer(
                  playerId: p['playerId'] ?? '',
                  name: p['name'] ?? '',
                  role: p['role'] ?? '',
                  photoUrl: p['photoUrl'],
                  isPlaying: p['isPlaying'] ?? false,
                ))
            .toList() ??
        [];

    return TeamSquad(
      teamId: doc.id,
      teamName: data['teamName'] ?? '',
      players: playersList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'players': players.map((p) => p.toFirestore()).toList(),
    };
  }

  List<SquadPlayer> get playingXI => players.where((p) => p.isPlaying).toList();
  int get playingXICount => playingXI.length;
  bool get hasWicketKeeper => playingXI.any((p) => p.isWicketKeeper);
  bool get isValidXI => playingXICount >= 2; // Minimum 2 players required
}
