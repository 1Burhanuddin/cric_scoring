import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../errors/app_error.dart';

/// Watches one or more Postgres tables for any change and re-runs [fetch]
/// whenever something changes, emitting the freshly hydrated result.
///
/// Supabase Realtime's `.stream()` convenience wrapper only covers a single
/// un-joined table, but most of the app's list/detail queries are joined
/// (match + match_teams + match_players, tournament + tournament_teams +
/// tournament_members, ...) and the Flutter models need that joined shape.
/// This re-fetches the whole hydrated result on any change to any of the
/// given tables instead of trying to reconstruct the join from individual
/// change payloads - same "watch broad, filter/hydrate in the fetch"
/// tradeoff BallScoreService.streamBallScoresByInningIds already takes for
/// the same reason (postgres_changes doesn't support an inFilter-style
/// predicate). Fine at this data volume; worth revisiting with per-row
/// filters if a table involved here grows large.
Stream<T> watchTables<T>(
  SupabaseClient supabase,
  List<String> tables,
  Future<T> Function() fetch,
) {
  late final StreamController<T> controller;
  RealtimeChannel? channel;

  Future<void> emit() async {
    try {
      controller.add(await fetch());
    } catch (error, stack) {
      controller.addError(AppError.fromError(error, stack));
    }
  }

  controller = StreamController<T>.broadcast(
    onListen: () {
      emit();
      var ch = supabase.channel('watch-${const Uuid().v4()}');
      for (final table in tables) {
        ch = ch.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (_) => emit(),
        );
      }
      channel = ch..subscribe();
    },
    onCancel: () {
      final c = channel;
      if (c != null) supabase.removeChannel(c);
    },
  );

  return controller.stream;
}
