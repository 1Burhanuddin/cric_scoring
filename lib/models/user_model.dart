import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? playerRole; // batsman, bowler, allrounder, wicketkeeper
  final String? battingStyle;
  final String? bowlingStyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.photoUrl,
    this.jerseyNumber,
    this.playerRole,
    this.battingStyle,
    this.bowlingStyle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: data['role'] ?? 'viewer',
      photoUrl: data['photoUrl'],
      jerseyNumber: data['jerseyNumber'],
      playerRole: data['playerRole'],
      battingStyle: data['battingStyle'],
      bowlingStyle: data['bowlingStyle'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'jerseyNumber': jerseyNumber,
      'playerRole': playerRole,
      'battingStyle': battingStyle,
      'bowlingStyle': bowlingStyle,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isScorer => role == 'scorer' || role == 'admin';
  bool get canWrite => isScorer;

  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasPlayerProfile => jerseyNumber != null && playerRole != null;
}
