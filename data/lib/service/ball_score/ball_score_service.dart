import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show DocumentChangeType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/ball_score/ball_score_model.dart';
import '../../api/match/match_model.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../errors/app_error.dart';
import '../../extensions/double_extensions.dart';
import '../../extensions/list_extensions.dart';

final ballScoreServiceProvider = Provider((ref) {
  return BallScoreService(ref.read(supabaseClientProvider));
});

class BallScoreChange {
  final DocumentChangeType type;
  final BallScoreModel ballScore;

  BallScoreChange(this.type, this.ballScore);
}

class BallScoreService {
  final SupabaseClient _supabase;

  BallScoreService(this._supabase);

  String get generateBallScoreId => const Uuid().v4().replaceAll('-', '');

  /// Was a Firestore transaction, then a single FastAPI-request Postgres
  /// transaction; now a single Postgres function call (rpc) -
  /// add_ball_score_and_update in supabase/migrations - still one atomic
  /// transaction, since a single RPC call is inherently one statement.
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
      // match_* (cumulative across every innings this team bats/bowls, e.g.
      // in a test match) vs inning_* (this single innings only) must stay
      // separate - collapsing them corrupts the per-innings figures once a
      // team has a prior innings.
      final inningOver = score.formattedOver;
      final matchOver = inningOver.add(otherInningOver.toBalls());

      await _supabase.rpc('add_ball_score_and_update', params: {
        'p_id': score.id,
        'p_inning_id': score.inning_id,
        'p_match_id': score.match_id,
        'p_over_number': score.over_number,
        'p_ball_number': score.ball_number,
        'p_bowler_id': score.bowler_id,
        'p_batsman_id': score.batsman_id,
        'p_non_striker_id': score.non_striker_id,
        'p_runs_scored': score.runs_scored,
        'p_extras_type': score.extras_type?.value,
        'p_extras_awarded': score.extras_awarded,
        'p_wicket_type': score.wicket_type?.value,
        'p_fielding_position': score.fielding_position?.value,
        'p_player_out_id': score.player_out_id,
        'p_wicket_taker_id': score.wicket_taker_id,
        'p_is_four': score.is_four,
        'p_is_six': score.is_six,
        'p_time': (score.time ?? score.score_time)?.toUtc().toIso8601String(),
        'p_batting_team_id': battingTeamId,
        'p_batting_team_inning_id': battingTeamInningId,
        'p_match_total_runs': otherTotalRuns + totalRuns,
        'p_inning_total_runs': totalRuns,
        'p_bowling_team_id': bowlingTeamId,
        'p_bowling_team_inning_id': bowlingTeamInningId,
        'p_match_wicket_taken': otherTotalWicketTaken + totalWicketTaken,
        'p_inning_wicket_taken': totalWicketTaken,
        'p_match_bowling_team_runs':
            totalBowlingTeamRuns != null ? otherTotalBowlingTeamRuns + totalBowlingTeamRuns : null,
        'p_inning_bowling_team_runs': totalBowlingTeamRuns,
        'p_match_over': matchOver,
        'p_inning_over': inningOver,
        'p_updated_player_id': updatedPlayer?.id,
        'p_updated_player_status': updatedPlayer?.status.value,
      });
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
        final rows = await _supabase.from('ball_scores').select().inFilter('match_id', ids);
        data.addAll(rows.map(_ballScoreFromRow));
      }
      return data;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<BallScoreChange>> streamBallScoresByInningIds({
    required List<String> inningIds,
    int? limit,
  }) {
    if (inningIds.isEmpty) return Stream.value([]);
    try {
      // Supabase Realtime's postgres_changes stream doesn't support an
      // inFilter()/whereIn() predicate, so this watches the whole table and
      // filters client-side - fine at this data volume, but worth a
      // targeted `.eq('match_id', ...)` stream instead if ball_scores grows
      // large enough for that to matter.
      return _supabase.from('ball_scores').stream(primaryKey: ['id']).map((rows) {
        final filtered = rows.where((r) => inningIds.contains(r['inning_id'])).toList();
        filtered.sort((a, b) => (b['score_time'] as String).compareTo(a['score_time'] as String));
        final limited = limit != null ? filtered.take(limit).toList() : filtered;
        return limited.map((r) => BallScoreChange(DocumentChangeType.added, _ballScoreFromRow(r))).toList();
      });
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
      await _supabase.rpc('delete_ball_score_and_update', params: {
        'p_ball_id': ballId,
        'p_batting_team_id': battingTeamId,
        'p_batting_team_inning_id': battingTeamInningId,
        'p_match_total_runs': otherTotalRuns + totalRuns,
        'p_inning_total_runs': totalRuns,
        'p_bowling_team_id': bowlingTeamId,
        'p_bowling_team_inning_id': bowlingTeamInningId,
        'p_match_wicket_taken': otherTotalWicketTaken + totalWicketTaken,
        'p_inning_wicket_taken': totalWicketTaken,
        'p_match_bowling_team_runs':
            totalBowlingTeamRuns != null ? otherTotalBowlingTeamRuns + totalBowlingTeamRuns : null,
        'p_inning_bowling_team_runs': totalBowlingTeamRuns,
        'p_match_over': overCount?.add(otherInningOver.toBalls()),
        'p_inning_over': overCount,
        'p_updated_players': (updatedPlayer ?? []).map((p) => {'id': p.id, 'status': p.status.value}).toList(),
      });
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  BallScoreModel _ballScoreFromRow(Map<String, dynamic> row) => BallScoreModel(
        id: row['id'] as String,
        inning_id: row['inning_id'] as String,
        match_id: row['match_id'] as String,
        over_number: row['over_number'] as int,
        ball_number: row['ball_number'] as int,
        bowler_id: row['bowler_id'] as String,
        batsman_id: row['batsman_id'] as String,
        non_striker_id: row['non_striker_id'] as String,
        runs_scored: row['runs_scored'] as int,
        extras_type:
            row['extras_type'] != null ? ExtrasType.values.firstWhere((e) => e.value == row['extras_type']) : null,
        extras_awarded: row['extras_awarded'] as int?,
        wicket_type:
            row['wicket_type'] != null ? WicketType.values.firstWhere((e) => e.value == row['wicket_type']) : null,
        fielding_position: row['fielding_position'] != null
            ? FieldingPositionType.values.firstWhere((e) => e.value == row['fielding_position'])
            : null,
        player_out_id: row['player_out_id'] as String?,
        wicket_taker_id: row['wicket_taker_id'] as String?,
        is_four: row['is_four'] as bool,
        is_six: row['is_six'] as bool,
        time: row['time'] != null ? DateTime.parse(row['time'] as String) : null,
        score_time: row['score_time'] != null ? DateTime.parse(row['score_time'] as String) : null,
      );
}
