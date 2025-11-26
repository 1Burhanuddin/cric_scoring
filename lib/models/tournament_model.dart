import 'package:cloud_firestore/cloud_firestore.dart';

class Tournament {
  final String tournamentId;
  final String name;
  final String format;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int overs;
  final String ballType;
  final int totalTeams;
  final String status;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tournament({
    required this.tournamentId,
    required this.name,
    required this.format,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.overs,
    required this.ballType,
    required this.totalTeams,
    required this.status,
    this.winnerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tournament.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tournament(
      tournamentId: doc.id,
      name: data['name'] ?? '',
      format: data['format'] ?? 'league',
      location: data['location'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      overs: data['overs'] ?? 20,
      ballType: data['ballType'] ?? 'tennis',
      totalTeams: data['totalTeams'] ?? 0,
      status: data['status'] ?? 'upcoming',
      winnerId: data['winnerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tournamentId': tournamentId,
      'name': name,
      'format': format,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'overs': overs,
      'ballType': ballType,
      'totalTeams': totalTeams,
      'status': status,
      'winnerId': winnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
