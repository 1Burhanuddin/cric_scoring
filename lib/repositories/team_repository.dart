import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/team_model.dart';
import 'package:cric_scoring/models/player_model.dart';

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository(this._firestore);

  // Get all teams
  Stream<List<Team>> getAllTeams() {
    return _firestore.collection('teams').orderBy('name').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList());
  }

  // Get team by ID
  Stream<Team> getTeam(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .snapshots()
        .map((doc) => Team.fromFirestore(doc));
  }

  // Get team players
  Stream<List<Player>> getTeamPlayers(String teamId) {
    return _firestore
        .collection('players')
        .where('teamId', isEqualTo: teamId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList());
  }
}
