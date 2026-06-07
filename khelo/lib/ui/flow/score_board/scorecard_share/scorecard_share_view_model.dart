import 'dart:io';
import 'dart:typed_data';

import 'package:cricheros_data/api/ball_score/ball_score_model.dart';
import 'package:cricheros_data/api/match/match_model.dart';
import 'package:cricheros_data/service/ball_score/ball_score_service.dart';
import 'package:cricheros_data/service/match/match_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'scorecard_share_state.dart';

final scorecardShareStateProvider = StateNotifierProvider.autoDispose<
    ScorecardShareViewNotifier, ScorecardShareState>((ref) {
  return ScorecardShareViewNotifier(
    ref.read(matchServiceProvider),
    ref.read(ballScoreServiceProvider),
  );
});

class ScorecardShareViewNotifier extends StateNotifier<ScorecardShareState> {
  final MatchService _matchService;
  final BallScoreService _ballScoreService;
  String? matchId;

  ScorecardShareViewNotifier(this._matchService, this._ballScoreService)
      : super(const ScorecardShareState());

  void setData(String id) {
    matchId = id;
    loadData();
  }

  Future<void> loadData() async {
    if (matchId == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final match = await _matchService.getMatchById(matchId!);
      final balls = await _ballScoreService.getBallScoresByMatchIds([matchId!]);
      final names = _buildPlayerNameMap(match);
      state = state.copyWith(
        match: match,
        topBatter: _topBatter(balls, names),
        topBowler: _topBowler(balls, names),
        loading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e, loading: false);
      debugPrint("ScorecardShareViewNotifier: error while loading data -> $e");
    }
  }

  Map<String, String> _buildPlayerNameMap(MatchModel match) {
    final map = <String, String>{};
    for (final team in match.teams) {
      for (final player in team.squad) {
        map[player.id] = player.player.name ?? 'Player';
      }
    }
    return map;
  }

  TopBatterPerformance? _topBatter(
      List<BallScoreModel> balls, Map<String, String> names) {
    if (balls.isEmpty) return null;
    final runs = <String, int>{};
    final faced = <String, int>{};
    final fours = <String, int>{};
    final sixes = <String, int>{};

    for (final ball in balls) {
      final id = ball.batsman_id;
      runs[id] = (runs[id] ?? 0) + ball.runs_scored;
      // A wide is not counted as a ball faced by the batter.
      if (ball.extras_type != ExtrasType.wide) {
        faced[id] = (faced[id] ?? 0) + 1;
      }
      if (ball.is_four) fours[id] = (fours[id] ?? 0) + 1;
      if (ball.is_six) sixes[id] = (sixes[id] ?? 0) + 1;
    }

    String? topId;
    var topRuns = -1;
    runs.forEach((id, value) {
      if (value > topRuns) {
        topRuns = value;
        topId = id;
      }
    });
    if (topId == null) return null;

    return TopBatterPerformance(
      name: names[topId] ?? 'Player',
      runs: runs[topId] ?? 0,
      balls: faced[topId] ?? 0,
      fours: fours[topId] ?? 0,
      sixes: sixes[topId] ?? 0,
    );
  }

  TopBowlerPerformance? _topBowler(
      List<BallScoreModel> balls, Map<String, String> names) {
    if (balls.isEmpty) return null;
    final wickets = <String, int>{};
    final conceded = <String, int>{};
    final legalBalls = <String, int>{};

    for (final ball in balls) {
      final id = ball.bowler_id;
      conceded[id] = (conceded[id] ?? 0) +
          ball.runs_scored +
          (ball.extras_type == ExtrasType.wide ||
                  ball.extras_type == ExtrasType.noBall
              ? (ball.extras_awarded ?? 0)
              : 0);
      if (ball.extras_type != ExtrasType.wide &&
          ball.extras_type != ExtrasType.noBall) {
        legalBalls[id] = (legalBalls[id] ?? 0) + 1;
      }
      // Credit the wicket to the bowler when they are the wicket taker.
      if (ball.player_out_id != null && ball.wicket_taker_id == id) {
        wickets[id] = (wickets[id] ?? 0) + 1;
      }
    }

    String? topId;
    var topWickets = -1;
    var topConceded = 1 << 30;
    wickets.forEach((id, value) {
      final runsAgainst = conceded[id] ?? 0;
      if (value > topWickets ||
          (value == topWickets && runsAgainst < topConceded)) {
        topWickets = value;
        topConceded = runsAgainst;
        topId = id;
      }
    });
    if (topId == null) return null;

    return TopBowlerPerformance(
      name: names[topId] ?? 'Player',
      wickets: wickets[topId] ?? 0,
      runsConceded: conceded[topId] ?? 0,
      balls: legalBalls[topId] ?? 0,
    );
  }

  Future<File> _writeImage(Uint8List bytes) async {
    final file = File('${Directory.systemTemp.path}/cricheros_scorecard.png');
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> shareScorecard(Uint8List bytes) async {
    state = state.copyWith(isSharing: true, actionError: null);
    try {
      final file = await _writeImage(bytes);
      final teams = state.match?.teams ?? [];
      final title = teams.length >= 2
          ? '${teams[0].team.name} vs ${teams[1].team.name}'
          : 'Match Scorecard';
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$title — scored on CricHeros 🏏',
      );
      state = state.copyWith(isSharing: false);
    } catch (e) {
      state = state.copyWith(isSharing: false, actionError: e);
      debugPrint("ScorecardShareViewNotifier: error while sharing -> $e");
    }
  }

  Future<void> downloadScorecard(Uint8List bytes) async {
    state = state.copyWith(isDownloading: true, actionError: null);
    try {
      final file = await _writeImage(bytes);
      state = state.copyWith(isDownloading: false, savedFilePath: file.path);
    } catch (e) {
      state = state.copyWith(isDownloading: false, actionError: e);
      debugPrint("ScorecardShareViewNotifier: error while downloading -> $e");
    }
  }
}
