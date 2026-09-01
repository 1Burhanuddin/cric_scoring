import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../api/leaderboard/leaderboard_model.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../api/user/user_models.dart';
import '../../errors/app_error.dart';
import '../../extensions/date_extension.dart';
import '../user/user_service.dart';

final leaderboardServiceProvider = Provider(
  (ref) => LeaderboardService(
    ref.read(supabaseClientProvider),
    ref.read(userServiceProvider),
  ),
);

class LeaderboardService {
  final SupabaseClient _supabase;
  final UserService _userService;

  LeaderboardService(
    this._supabase,
    this._userService,
  );

  String _fieldColumn(LeaderboardField field) => switch (field) {
        LeaderboardField.batting => 'runs',
        LeaderboardField.bowling => 'wickets',
        LeaderboardField.fielding => 'catches',
      };

  Future<List<LeaderboardPlayer>> getLeaderboardByField({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
    LeaderboardPlayer? lastPlayer,
    LeaderboardField field = LeaderboardField.batting,
  }) async {
    try {
      final column = _fieldColumn(field);
      var query = _supabase
          .from('leaderboard_entries')
          .select()
          .eq('period', type.getDatabaseConst())
          .gt(column, field.getMinScoreToGetFeatured());

      if (type == LeaderboardType.weekly || type == LeaderboardType.monthly) {
        final now = DateTime.now();
        final startTime = type == LeaderboardType.weekly ? now.getStartOfWeek : now.getStartOfMonth;
        final endTime = type == LeaderboardType.weekly ? now.getEndOfWeek : now.getEndOfMonth;
        query = query
            .gte('date', startTime.toIso8601String().split('T').first)
            .lte('date', endTime.toIso8601String().split('T').first);
      }

      if (lastPlayer != null) {
        final lastValue = field == LeaderboardField.batting
            ? lastPlayer.runs
            : field == LeaderboardField.bowling
                ? lastPlayer.wickets
                : lastPlayer.catches;
        query = query.lt(column, lastValue);
      }

      final rows = await query.order(column, ascending: false).limit(limit);
      final entries = rows.map(_leaderboardPlayerFromRow).toList();

      final players = await _userService.getUsersByIds(entries.map((e) => e.id).toList());

      return entries.map((e) {
        final player = players.firstWhere((element) => element.id == e.id);
        return e.copyWith(user: player);
      }).toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel for the user-hydrated leaderboard query yet, same
  /// gap as MatchService/TournamentService - emits once immediately.
  Stream<List<LeaderboardPlayer>> streamLeaderboardByField({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
    LeaderboardField field = LeaderboardField.batting,
  }) async* {
    try {
      yield await getLeaderboardByField(type: type, limit: limit, field: field);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<LeaderboardModel>> streamLeaderboard({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
  }) async* {
    try {
      final results = await Future.wait(
        LeaderboardField.values.map(
          (field) async => LeaderboardModel(
            type: field,
            players: await getLeaderboardByField(type: type, limit: limit, field: field),
          ),
        ),
      );
      yield results.where((r) => r.players.isNotEmpty).toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// Ports khelo/functions/src/leaderboard (the old userStatWriteObserver
  /// Cloud Function, triggered on every user_stats write) to run client-side
  /// right after UserService.updateUserStats, since there's no Postgres
  /// trigger equivalent wired up. Diffs old vs new cumulative stats and adds
  /// the diff to each period's row, resetting a period's row instead of
  /// accumulating once its week/month has rolled over.
  Future<void> updateLeaderboardForUser(
    String userId,
    UserStat? oldStat,
    UserStat newStat,
  ) async {
    try {
      final runDiff = newStat.batting.run_scored - (oldStat?.batting.run_scored ?? 0);
      final wicketDiff = newStat.bowling.wicket_taken - (oldStat?.bowling.wicket_taken ?? 0);
      final catchDiff = newStat.fielding.catches - (oldStat?.fielding.catches ?? 0);

      final runs = runDiff >= 0 ? runDiff : newStat.batting.run_scored;
      final wickets = wicketDiff >= 0 ? wicketDiff : newStat.bowling.wicket_taken;
      final catches = catchDiff >= 0 ? catchDiff : newStat.fielding.catches;

      final now = DateTime.now();

      await _upsertPeriodEntry(
        LeaderboardType.weekly.getDatabaseConst(),
        userId,
        runs,
        wickets,
        catches,
        now,
        isCurrentPeriod: (date) => date.getStartOfWeek.isBefore(now.getEndOfWeek) && !date.isBefore(now.getStartOfWeek),
      );
      await _upsertPeriodEntry(
        LeaderboardType.monthly.getDatabaseConst(),
        userId,
        runs,
        wickets,
        catches,
        now,
        isCurrentPeriod: (date) => date.month == now.month && date.year == now.year,
      );
      await _upsertPeriodEntry(
        LeaderboardType.allTime.getDatabaseConst(),
        userId,
        runs,
        wickets,
        catches,
        now,
        isCurrentPeriod: (_) => true,
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> _upsertPeriodEntry(
    String period,
    String userId,
    int runs,
    int wickets,
    int catches,
    DateTime now, {
    required bool Function(DateTime date) isCurrentPeriod,
  }) async {
    final existing =
        await _supabase.from('leaderboard_entries').select().eq('period', period).eq('user_id', userId).maybeSingle();

    int newRuns = runs;
    int newWickets = wickets;
    int newCatches = catches;
    if (existing != null && isCurrentPeriod(DateTime.parse(existing['date'] as String))) {
      newRuns += existing['runs'] as int;
      newWickets += existing['wickets'] as int;
      newCatches += existing['catches'] as int;
    }

    await _supabase.from('leaderboard_entries').upsert({
      'period': period,
      'user_id': userId,
      'date': now.toIso8601String().split('T').first,
      'runs': newRuns,
      'wickets': newWickets,
      'catches': newCatches,
    }, onConflict: 'period,user_id');
  }

  LeaderboardPlayer _leaderboardPlayerFromRow(Map<String, dynamic> row) => LeaderboardPlayer(
        id: row['user_id'] as String,
        date: DateTime.parse(row['date'] as String),
        runs: row['runs'] as int,
        wickets: row['wickets'] as int,
        catches: row['catches'] as int,
      );
}
