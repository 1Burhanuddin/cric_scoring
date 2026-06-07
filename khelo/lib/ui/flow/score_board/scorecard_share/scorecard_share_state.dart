import 'package:cricheros_data/api/match/match_model.dart';

/// Sentinel used by [ScorecardShareState.copyWith] so that callers can
/// explicitly pass `null` (e.g. to clear an error) while still allowing
/// omitted parameters to retain their previous value.
const Object _sentinel = Object();

/// Aggregated batting line for the top run scorer of a match.
class TopBatterPerformance {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;

  const TopBatterPerformance({
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
  });

  double get strikeRate => balls == 0 ? 0 : (runs / balls) * 100;
}

/// Aggregated bowling line for the top wicket taker of a match.
class TopBowlerPerformance {
  final String name;
  final int wickets;
  final int runsConceded;
  final int balls;

  const TopBowlerPerformance({
    required this.name,
    required this.wickets,
    required this.runsConceded,
    required this.balls,
  });

  /// Overs in cricket notation, e.g. 3.4 means 3 overs and 4 balls.
  double get overs {
    final completed = balls ~/ 6;
    final remaining = balls % 6;
    return double.parse('$completed.$remaining');
  }

  double get economy {
    final overCount = balls / 6;
    return overCount == 0 ? 0 : runsConceded / overCount;
  }
}

/// Immutable state for the shareable scorecard screen.
///
/// NOTE: This is intentionally a hand-written immutable class (instead of the
/// `@freezed` pattern used elsewhere) so that the feature compiles without a
/// build_runner code-generation step.
class ScorecardShareState {
  final Object? error;
  final Object? actionError;
  final MatchModel? match;
  final TopBatterPerformance? topBatter;
  final TopBowlerPerformance? topBowler;
  final bool loading;
  final bool isSharing;
  final bool isDownloading;
  final String? savedFilePath;

  const ScorecardShareState({
    this.error,
    this.actionError,
    this.match,
    this.topBatter,
    this.topBowler,
    this.loading = false,
    this.isSharing = false,
    this.isDownloading = false,
    this.savedFilePath,
  });

  ScorecardShareState copyWith({
    Object? error = _sentinel,
    Object? actionError = _sentinel,
    MatchModel? match,
    Object? topBatter = _sentinel,
    Object? topBowler = _sentinel,
    bool? loading,
    bool? isSharing,
    bool? isDownloading,
    Object? savedFilePath = _sentinel,
  }) {
    return ScorecardShareState(
      error: identical(error, _sentinel) ? this.error : error,
      actionError:
          identical(actionError, _sentinel) ? this.actionError : actionError,
      match: match ?? this.match,
      topBatter: identical(topBatter, _sentinel)
          ? this.topBatter
          : topBatter as TopBatterPerformance?,
      topBowler: identical(topBowler, _sentinel)
          ? this.topBowler
          : topBowler as TopBowlerPerformance?,
      loading: loading ?? this.loading,
      isSharing: isSharing ?? this.isSharing,
      isDownloading: isDownloading ?? this.isDownloading,
      savedFilePath: identical(savedFilePath, _sentinel)
          ? this.savedFilePath
          : savedFilePath as String?,
    );
  }
}
