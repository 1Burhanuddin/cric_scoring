import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cric_scoring/models/match_model.dart';
import 'package:cric_scoring/models/squad_model.dart';
import 'package:cric_scoring/models/match_creation_state.dart';

class MatchRepository {
  final FirebaseFirestore _firestore;

  MatchRepository(this._firestore);

  // Create new match
  Future<String> createMatch(MatchCreationState state, String createdBy) async {
    final matchRef = _firestore.collection('matches').doc();
    final matchId = matchRef.id;

    final teamAInfo = TeamInfo(
      teamId: state.teamA!.teamId,
      name: state.teamA!.name,
      logoUrl: state.teamA!.logoUrl,
      color: state.teamA!.color,
    );

    final teamBInfo = TeamInfo(
      teamId: state.teamB!.teamId,
      name: state.teamB!.name,
      logoUrl: state.teamB!.logoUrl,
      color: state.teamB!.color,
    );

    final match = Match(
      matchId: matchId,
      tournamentId: state.tournamentId,
      teamA: teamAInfo,
      teamB: teamBInfo,
      overs: state.overs,
      ground: state.ground,
      date: state.matchDate,
      status: 'upcoming',
      createdBy: createdBy,
      scorers: [], // Empty list initially
      tossWinner: state.tossWinner,
      tossDecision: state.tossDecision,
      battingFirst: state.battingFirst,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();

    // Create match document
    batch.set(matchRef, match.toFirestore());

    // Create squads subcollection
    final teamASquadRef = matchRef.collection('squads').doc('teamA');
    final teamBSquadRef = matchRef.collection('squads').doc('teamB');

    batch.set(teamASquadRef, state.teamASquad!.toFirestore());
    batch.set(teamBSquadRef, state.teamBSquad!.toFirestore());

    // Initialize innings documents
    final innings1Ref = matchRef.collection('innings').doc('1');
    final innings2Ref = matchRef.collection('innings').doc('2');

    final battingTeamId = state.battingFirst;
    final bowlingTeamId = battingTeamId == state.teamA!.teamId
        ? state.teamB!.teamId
        : state.teamA!.teamId;

    batch.set(innings1Ref, {
      'inningsNumber': 1,
      'battingTeamId': battingTeamId,
      'bowlingTeamId': bowlingTeamId,
      'runs': 0,
      'wickets': 0,
      'overs': 0.0,
      'extras': {'wides': 0, 'noBalls': 0, 'byes': 0, 'legByes': 0},
      'isDeclared': false,
      'isCompleted': false,
    });

    batch.set(innings2Ref, {
      'inningsNumber': 2,
      'battingTeamId': bowlingTeamId,
      'bowlingTeamId': battingTeamId,
      'runs': 0,
      'wickets': 0,
      'overs': 0.0,
      'extras': {'wides': 0, 'noBalls': 0, 'byes': 0, 'legByes': 0},
      'isDeclared': false,
      'isCompleted': false,
    });

    // Add to tournament if specified
    if (state.tournamentId != null) {
      final tournamentMatchRef = _firestore
          .collection('tournaments')
          .doc(state.tournamentId)
          .collection('matches')
          .doc(matchId);

      batch.set(tournamentMatchRef, {
        'matchId': matchId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return matchId;
  }

  // Get match by ID
  Stream<Match> getMatch(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .map((doc) => Match.fromFirestore(doc));
  }

  // Get matches by status
  Stream<List<Match>> getMatchesByStatus(String status) {
    return _firestore
        .collection('matches')
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList());
  }

  // Get matches by tournament
  Stream<List<Match>> getMatchesByTournament(String tournamentId) {
    return _firestore
        .collection('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList());
  }

  // Get team squad for match
  Stream<TeamSquad> getTeamSquad(String matchId, String team) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('squads')
        .doc(team)
        .snapshots()
        .map((doc) => TeamSquad.fromFirestore(doc));
  }

  // Update match status
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Start match
  Future<void> startMatch(String matchId) async {
    await updateMatchStatus(matchId, 'live');
  }

  // Delete match
  Future<void> deleteMatch(String matchId) async {
    final batch = _firestore.batch();

    // Delete match document
    final matchRef = _firestore.collection('matches').doc(matchId);
    batch.delete(matchRef);

    // Delete subcollections would require additional queries
    // For now, we'll just delete the main document
    // In production, use Cloud Functions to clean up subcollections

    await batch.commit();
  }
}
