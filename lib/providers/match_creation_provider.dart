import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/match_creation_state.dart';
import 'package:cric_scoring/models/team_model.dart';
import 'package:cric_scoring/models/squad_model.dart';
import 'package:cric_scoring/models/player_model.dart';
import 'package:cric_scoring/repositories/match_repository.dart';
import 'package:cric_scoring/repositories/team_repository.dart';
import 'package:cric_scoring/repositories/tournament_repository.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// Repositories
final matchRepositoryProvider = Provider((ref) {
  return MatchRepository(ref.watch(firestoreProvider));
});

final teamRepositoryProvider = Provider((ref) {
  return TeamRepository(ref.watch(firestoreProvider));
});

final tournamentRepositoryProvider = Provider((ref) {
  return TournamentRepository(ref.watch(firestoreProvider));
});

// Match creation state
final matchCreationProvider =
    StateNotifierProvider<MatchCreationNotifier, MatchCreationState>((ref) {
  return MatchCreationNotifier(ref.read(matchRepositoryProvider));
});

class MatchCreationNotifier extends StateNotifier<MatchCreationState> {
  final MatchRepository _repository;

  MatchCreationNotifier(this._repository)
      : super(MatchCreationState(matchDate: DateTime.now()));

  void setTournament(String? tournamentId, String? tournamentName) {
    state = state.copyWith(
      tournamentId: tournamentId,
      tournamentName: tournamentName,
    );
  }

  void setTeamA(Team team) {
    state = state.copyWith(teamA: team);
  }

  void setTeamB(Team team) {
    state = state.copyWith(teamB: team);
  }

  void setOvers(int overs) {
    state = state.copyWith(overs: overs);
  }

  void setGround(String ground) {
    state = state.copyWith(ground: ground);
  }

  void setMatchDate(DateTime date) {
    state = state.copyWith(matchDate: date);
  }

  void setBallType(String ballType) {
    state = state.copyWith(ballType: ballType);
  }

  void setTeamASquad(List<Player> allPlayers, List<String> selectedPlayerIds) {
    if (state.teamA == null) return;

    final squadPlayers = allPlayers.map((player) {
      return SquadPlayer(
        playerId: player.playerId,
        name: player.name,
        role: player.role,
        photoUrl: player.photoUrl,
        isPlaying: selectedPlayerIds.contains(player.playerId),
      );
    }).toList();

    final squad = TeamSquad(
      teamId: state.teamA!.teamId,
      teamName: state.teamA!.name,
      players: squadPlayers,
    );

    state = state.copyWith(teamASquad: squad);
  }

  void setTeamBSquad(List<Player> allPlayers, List<String> selectedPlayerIds) {
    if (state.teamB == null) return;

    final squadPlayers = allPlayers.map((player) {
      return SquadPlayer(
        playerId: player.playerId,
        name: player.name,
        role: player.role,
        photoUrl: player.photoUrl,
        isPlaying: selectedPlayerIds.contains(player.playerId),
      );
    }).toList();

    final squad = TeamSquad(
      teamId: state.teamB!.teamId,
      teamName: state.teamB!.name,
      players: squadPlayers,
    );

    state = state.copyWith(teamBSquad: squad);
  }

  void setToss(String tossWinner, String tossDecision) {
    final battingFirst = tossDecision == 'bat'
        ? tossWinner
        : (tossWinner == state.teamA!.teamId
            ? state.teamB!.teamId
            : state.teamA!.teamId);

    state = state.copyWith(
      tossWinner: tossWinner,
      tossDecision: tossDecision,
      battingFirst: battingFirst,
    );
  }

  Future<String> createMatch() async {
    if (!state.isReadyToCreate) {
      throw Exception('Match creation state is not valid');
    }
    return await _repository.createMatch(state);
  }

  void reset() {
    state = MatchCreationState(matchDate: DateTime.now());
  }
}

// Teams provider
final teamsProvider = StreamProvider((ref) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getAllTeams();
});

// Team players provider
final teamPlayersProvider =
    StreamProvider.family<List<Player>, String>((ref, teamId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getTeamPlayers(teamId);
});

// Active tournaments provider
final activeTournamentsProvider = StreamProvider((ref) {
  final repository = ref.watch(tournamentRepositoryProvider);
  return repository.getActiveTournaments();
});
