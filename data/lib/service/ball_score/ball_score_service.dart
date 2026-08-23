import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show DocumentChangeType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/ball_score/ball_score_model.dart';
import '../../api/match/match_model.dart';
import '../../api/network/api_client.dart';
import '../../errors/app_error.dart';
import '../../extensions/double_extensions.dart';
import '../../extensions/list_extensions.dart';

final ballScoreServiceProvider = Provider((ref) {
  return BallScoreService(ref.read(apiClientProvider));
});

class BallScoreChange {
  final DocumentChangeType type;
  final BallScoreModel ballScore;

  BallScoreChange(this.type, this.ballScore);
}

class BallScoreService {
  final ApiClient _api;

  BallScoreService(this._api);

  String get generateBallScoreId => const Uuid().v4().replaceAll('-', '');

  /// Was a Firestore transaction spanning match+innings+ball_score writes.
  /// Now a single Postgres transaction on the backend (app/routers/ball_scores.py)
  /// - stronger atomicity guarantee than before, since match/innings/ball_score
  /// all live in the same database now.
  Future<void> addBallScoreAndUpdateTeamDetails({
    required BallScoreModel score,
    required String matchId,
    required String battingTeamId,
    required String battingTeamInningId,
    required int totalRuns,
    required String bowlingTeamId,
    required String bowlingTeamInningId,
    required int totalWicketTaken,
    int? totalBowlingTeamRuns,
    double otherInningOver = 0,
    int otherTotalRuns = 0,
    int otherTotalWicketTaken = 0,
    int otherTotalBowlingTeamRuns = 0,
    MatchPlayer? updatedPlayer,
  }) async {
    try {
      await _api.post(
        '/ball-scores',
        data: {
          'id': score.id,
          'inning_id': score.inning_id,
          'match_id': score.match_id,
          'over_number': score.over_number,
          'ball_number': score.ball_number,
          'bowler_id': score.bowler_id,
          'batsman_id': score.batsman_id,
          'non_striker_id': score.non_striker_id,
          'runs_scored': score.runs_scored,
          'extras_type': score.extras_type?.value,
          'extras_awarded': score.extras_awarded,
          'wicket_type': score.wicket_type?.value,
          'fielding_position': score.fielding_position?.value,
          'player_out_id': score.player_out_id,
          'wicket_taker_id': score.wicket_taker_id,
          'is_four': score.is_four,
          'is_six': score.is_six,
          'time': (score.time ?? score.score_time)?.toIso8601String(),
          'batting_team_id': battingTeamId,
          'batting_team_inning_id': battingTeamInningId,
          'total_runs': otherTotalRuns + totalRuns,
          'bowling_team_id': bowlingTeamId,
          'bowling_team_inning_id': bowlingTeamInningId,
          'total_wicket_taken': otherTotalWicketTaken + totalWicketTaken,
          'total_bowling_team_runs': totalBowlingTeamRuns != null
              ? otherTotalBowlingTeamRuns + totalBowlingTeamRuns
              : null,
          'over': score.formattedOver.add(otherInningOver.toBalls()),
          'updated_player': updatedPlayer != null
              ? {'id': updatedPlayer.id, 'status': updatedPlayer.status.value}
              : null,
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<List<BallScoreModel>> getBallScoresByMatchIds(
    List<String> matchIds,
  ) async {
    if (matchIds.isEmpty) return [];
    try {
      final data = <BallScoreModel>[];
      for (final ids in matchIds.chunked(30)) {
        final response = await _api.get('/ball-scores', query: {'match_ids': ids});
        data.addAll(
          (response as List).map((json) => BallScoreModel.fromJson(json as Map<String, dynamic>)),
        );
      }
      return data;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel yet (Firestore's docChanges gave add/modify/remove
  /// diffs; a REST snapshot can only say "here's everything, treat it as
  /// added" - callers that specifically depend on modified/removed events
  /// during live scoring won't see those until this gets a websocket).
  Stream<List<BallScoreChange>> streamBallScoresByInningIds({
    required List<String> inningIds,
    int? limit,
  }) async* {
    if (inningIds.isEmpty) {
      yield [];
      return;
    }
    try {
      final response = await _api.get(
        '/ball-scores/by-innings',
        query: {
          'inning_ids': inningIds,
          if (limit != null) 'limit': limit.toString(),
        },
      );
      yield (response as List)
          .map(
            (json) => BallScoreChange(
              DocumentChangeType.added,
              BallScoreModel.fromJson(json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteBallAndUpdateTeamDetails({
    required String ballId,
    required String matchId,
    required String battingTeamId,
    required String battingTeamInningId,
    required int totalRuns,
    required String bowlingTeamId,
    required String bowlingTeamInningId,
    required int totalWicketTaken,
    double? overCount,
    int? totalBowlingTeamRuns,
    double otherInningOver = 0,
    int otherTotalRuns = 0,
    int otherTotalWicketTaken = 0,
    int otherTotalBowlingTeamRuns = 0,
    List<MatchPlayer>? updatedPlayer,
  }) async {
    try {
      await _api.post(
        '/ball-scores/$ballId/delete-and-update',
        data: {
          'batting_team_id': battingTeamId,
          'batting_team_inning_id': battingTeamInningId,
          'total_runs': otherTotalRuns + totalRuns,
          'bowling_team_id': bowlingTeamId,
          'bowling_team_inning_id': bowlingTeamInningId,
          'total_wicket_taken': otherTotalWicketTaken + totalWicketTaken,
          'total_bowling_team_runs': totalBowlingTeamRuns != null
              ? otherTotalBowlingTeamRuns + totalBowlingTeamRuns
              : null,
          'over': overCount?.add(otherInningOver.toBalls()),
          'updated_players': (updatedPlayer ?? [])
              .map((p) => {'id': p.id, 'status': p.status.value})
              .toList(),
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
