import 'package:cric_scoring/models/team_model.dart';
import 'package:cric_scoring/models/squad_model.dart';

class MatchCreationState {
  final String? tournamentId;
  final String? tournamentName;
  final Team? teamA;
  final Team? teamB;
  final int overs;
  final String ground;
  final DateTime matchDate;
  final String ballType;
  final TeamSquad? teamASquad;
  final TeamSquad? teamBSquad;
  final String? tossWinner;
  final String? tossDecision;
  final String? battingFirst;

  MatchCreationState({
    this.tournamentId,
    this.tournamentName,
    this.teamA,
    this.teamB,
    this.overs = 20,
    this.ground = '',
    DateTime? matchDate,
    this.ballType = 'tennis',
    this.teamASquad,
    this.teamBSquad,
    this.tossWinner,
    this.tossDecision,
    this.battingFirst,
  }) : matchDate = matchDate ?? DateTime.now();

  MatchCreationState copyWith({
    String? tournamentId,
    String? tournamentName,
    Team? teamA,
    Team? teamB,
    int? overs,
    String? ground,
    DateTime? matchDate,
    String? ballType,
    TeamSquad? teamASquad,
    TeamSquad? teamBSquad,
    String? tossWinner,
    String? tossDecision,
    String? battingFirst,
  }) {
    return MatchCreationState(
      tournamentId: tournamentId ?? this.tournamentId,
      tournamentName: tournamentName ?? this.tournamentName,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      overs: overs ?? this.overs,
      ground: ground ?? this.ground,
      matchDate: matchDate ?? this.matchDate,
      ballType: ballType ?? this.ballType,
      teamASquad: teamASquad ?? this.teamASquad,
      teamBSquad: teamBSquad ?? this.teamBSquad,
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
      battingFirst: battingFirst ?? this.battingFirst,
    );
  }

  bool get isBasicInfoValid =>
      teamA != null &&
      teamB != null &&
      teamA!.teamId != teamB!.teamId &&
      overs > 0 &&
      ground.isNotEmpty;

  bool get isSquadValid =>
      teamASquad != null &&
      teamBSquad != null &&
      teamASquad!.isValidXI &&
      teamBSquad!.isValidXI;

  bool get isTossComplete =>
      tossWinner != null && tossDecision != null && battingFirst != null;

  bool get isReadyToCreate =>
      isBasicInfoValid && isSquadValid && isTossComplete;
}
