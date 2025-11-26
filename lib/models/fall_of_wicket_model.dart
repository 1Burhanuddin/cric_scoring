import 'package:cloud_firestore/cloud_firestore.dart';

class FallOfWicket {
  final int wicketNumber;
  final int scoreAtFall;
  final double over;
  final String batsmanOut;
  final String batsmanOutId;
  final String? dismissalType;
  final String? bowlerId;
  final String? bowlerName;
  final String? fielderId;
  final String? fielderName;

  const FallOfWicket({
    required this.wicketNumber,
    required this.scoreAtFall,
    required this.over,
    required this.batsmanOut,
    required this.batsmanOutId,
    this.dismissalType,
    this.bowlerId,
    this.bowlerName,
    this.fielderId,
    this.fielderName,
  });

  factory FallOfWicket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FallOfWicket(
      wicketNumber: int.parse(doc.id),
      scoreAtFall: data['scoreAtFall'] ?? 0,
      over: (data['over'] ?? 0.0).toDouble(),
      batsmanOut: data['batsmanOut'] ?? '',
      batsmanOutId: data['batsmanOutId'] ?? '',
      dismissalType: data['dismissalType'],
      bowlerId: data['bowlerId'],
      bowlerName: data['bowlerName'],
      fielderId: data['fielderId'],
      fielderName: data['fielderName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'wicketNumber': wicketNumber,
      'scoreAtFall': scoreAtFall,
      'over': over,
      'batsmanOut': batsmanOut,
      'batsmanOutId': batsmanOutId,
      'dismissalType': dismissalType,
      'bowlerId': bowlerId,
      'bowlerName': bowlerName,
      'fielderId': fielderId,
      'fielderName': fielderName,
    };
  }

  String get displayText => '$wicketNumber-$scoreAtFall ($over ov)';
}
