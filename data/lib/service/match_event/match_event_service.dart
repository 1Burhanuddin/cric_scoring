import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/ball_score/ball_score_model.dart';
import '../../api/match_event/match_event_model.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../errors/app_error.dart';

final matchEventServiceProvider = Provider(
  (ref) => MatchEventService(ref.read(supabaseClientProvider)),
);

class MatchEventService {
  final SupabaseClient _supabase;

  MatchEventService(this._supabase);

  String get generateMatchEventId => const Uuid().v4().replaceAll('-', '');

  Stream<List<MatchEventModel>> streamEventsByMatches(String matchId) {
    try {
      return _supabase
          .from('match_events')
          .stream(primaryKey: ['id'])
          .eq('match_id', matchId)
          .map((rows) => rows.map(_eventFromRow).toList());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<String> updateMatchEvent(MatchEventModel event) async {
    try {
      final id = event.id.isNotEmpty ? event.id : generateMatchEventId;
      // .toUtc() before serializing - the wickets/milestone JSONB entries'
      // "time" is a naive ISO string once inside jsonb, and the app treats
      // a naive string as UTC when reading it back (see
      // backend/app/schemas/scoring.py's older equivalent, ported here as
      // the same convention).
      await _supabase.from('match_events').upsert({
        'id': id,
        'match_id': event.match_id,
        'inning_id': event.inning_id,
        'type': event.type.value,
        'time': event.time.toUtc().toIso8601String(),
        'bowler_id': event.bowler_id,
        'batsman_id': event.batsman_id,
        'fielding_position': event.fielding_position?.value,
        'over': event.over,
        'ball_ids': event.ball_ids,
        'wickets': event.wickets
            .map((w) => {
                  'time': w.time.toUtc().toIso8601String(),
                  'ball_id': w.ball_id,
                  'batsman_id': w.batsman_id,
                  'wicket_type': w.wicket_type.value,
                  'over': w.over,
                  'wicket_taker_id': w.wicket_taker_id,
                })
            .toList(),
        'milestone': event.milestone
            .map((m) => {
                  'time': m.time.toUtc().toIso8601String(),
                  'ball_id': m.ball_id,
                  'over': m.over,
                  'runs': m.runs,
                  'ball_faced': m.ball_faced,
                  'fours': m.fours,
                  'sixes': m.sixes,
                })
            .toList(),
      });
      return id;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteMatchEvent(String eventId) async {
    try {
      await _supabase.from('match_events').delete().eq('id', eventId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  MatchEventModel _eventFromRow(Map<String, dynamic> row) => MatchEventModel(
        id: row['id'] as String,
        match_id: row['match_id'] as String,
        inning_id: row['inning_id'] as String,
        type: EventType.values.firstWhere((e) => e.value == row['type']),
        time: DateTime.parse(row['time'] as String),
        bowler_id: row['bowler_id'] as String?,
        batsman_id: row['batsman_id'] as String?,
        fielding_position: row['fielding_position'] != null
            ? FieldingPositionType.values.firstWhere((e) => e.value == row['fielding_position'])
            : null,
        over: (row['over'] as num).toDouble(),
        ball_ids: ((row['ball_ids'] as List?) ?? const []).cast<String>(),
        wickets: ((row['wickets'] as List?) ?? const [])
            .map((w) => MatchEventWicket(
                  time: DateTime.parse(w['time'] as String),
                  ball_id: w['ball_id'] as String,
                  batsman_id: w['batsman_id'] as String,
                  wicket_type: WicketType.values.firstWhere((e) => e.value == w['wicket_type']),
                  over: (w['over'] as num).toDouble(),
                  wicket_taker_id: w['wicket_taker_id'] as String?,
                ))
            .toList(),
        milestone: ((row['milestone'] as List?) ?? const [])
            .map((m) => MatchEventMilestone(
                  time: DateTime.parse(m['time'] as String),
                  ball_id: m['ball_id'] as String,
                  over: (m['over'] as num).toDouble(),
                  runs: m['runs'] as int,
                  ball_faced: m['ball_faced'] as int,
                  fours: m['fours'] as int,
                  sixes: m['sixes'] as int,
                ))
            .toList(),
      );
}
