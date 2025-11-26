import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/tournament_model.dart';

class TournamentRepository {
  final FirebaseFirestore _firestore;

  TournamentRepository(this._firestore);

  // Get all tournaments
  Stream<List<Tournament>> getAllTournaments() {
    return _firestore
        .collection('tournaments')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tournament.fromFirestore(doc)).toList());
  }

  // Get active tournaments
  Stream<List<Tournament>> getActiveTournaments() {
    return _firestore
        .collection('tournaments')
        .where('status', whereIn: ['upcoming', 'live'])
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tournament.fromFirestore(doc)).toList());
  }

  // Get tournament by ID
  Stream<Tournament> getTournament(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .snapshots()
        .map((doc) => Tournament.fromFirestore(doc));
  }
}
