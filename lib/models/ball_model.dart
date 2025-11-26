import 'package:cloud_firestore/cloud_firestore.dart';

class Ball {
  final String ballId;
  final int inningsNumber;
  final int overNumber;
  final int ballNumber;
  final String batsmanId;
  final String bowlerId;
  final int runs;
  final bool isWide;
  final bool isNoBall;
  final bool isBye;
  final bool isLegBye;
  final bool isWicket;
  final String? wicketType;
  final String? fielderIds;
  final DateTime timestamp;

  const Ball({
    required this.ballId,
    required this.inningsNumber,
    required this.overNumber,
    required this.ballNumber,
    required this.batsmanId,
    required this.bowlerId,
    required this.runs,
    this.isWide = false,
    this.isNoBall = false,
    this.isBye = false,
    this.isLegBye = false,
    this.isWicket = false,
    this.wicketType,
    this.fielderIds,
    required this.timestamp,
  });

  factory Ball.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ball(
      ballId: doc.id,
      inningsNumber: data['inningsNumber'] ?? 1,
      overNumber: data['overNumber'] ?? 0,
      ballNumber: data['ballNumber'] ?? 0,
      batsmanId: data['batsmanId'] ?? '',
      bowlerId: data['bowlerId'] ?? '',
      runs: data['runs'] ?? 0,
      isWide: data['isWide'] ?? false,
      isNoBall: data['isNoBall'] ?? false,
      isBye: data['isBye'] ?? false,
      isLegBye: data['isLegBye'] ?? false,
      isWicket: data['isWicket'] ?? false,
      wicketType: data['wicketType'],
      fielderIds: data['fielderIds'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inningsNumber': inningsNumber,
      'overNumber': overNumber,
      'ballNumber': ballNumber,
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
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  bool get isExtra => isWide || isNoBall || isBye || isLegBye;

  int get totalRuns {
    int total = runs;
    if (isWide || isNoBall) total += 1;
    return total;
  }

  String get displayText {
    if (isWicket) return 'W';
    if (isWide) return 'WD';
    if (isNoBall) return 'NB';
    return runs.toString();
  }
}
