import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/match_event/match_event_model.dart';
import '../../api/network/api_client.dart';
import '../../errors/app_error.dart';

final matchEventServiceProvider = Provider(
  (ref) => MatchEventService(ref.read(apiClientProvider)),
);

class MatchEventService {
  final ApiClient _api;

  MatchEventService(this._api);

  String get generateMatchEventId => const Uuid().v4().replaceAll('-', '');

  /// No realtime channel yet - emits a single snapshot. See BallScoreService
  /// for the same caveat during live scoring.
  Stream<List<MatchEventModel>> streamEventsByMatches(String matchId) async* {
    try {
      final response = await _api.get('/match-events/by-match/$matchId');
      yield (response as List)
          .map((json) => MatchEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<String> updateMatchEvent(MatchEventModel event) async {
    try {
      final id = event.id.isNotEmpty ? event.id : generateMatchEventId;
      final response = await _api.put(
        '/match-events/$id',
        data: {
          'match_id': event.match_id,
          'inning_id': event.inning_id,
          'type': event.type.value,
          'time': event.time.toIso8601String(),
          'bowler_id': event.bowler_id,
          'batsman_id': event.batsman_id,
          'fielding_position': event.fielding_position?.value,
          'over': event.over,
          'ball_ids': event.ball_ids,
          'wickets': event.wickets
              .map((w) => {
                    'time': w.time.toIso8601String(),
                    'ball_id': w.ball_id,
                    'batsman_id': w.batsman_id,
                    'wicket_type': w.wicket_type.value,
                    'over': w.over,
                    'wicket_taker_id': w.wicket_taker_id,
                  })
              .toList(),
          'milestone': event.milestone
              .map((m) => {
                    'time': m.time.toIso8601String(),
                    'ball_id': m.ball_id,
                    'over': m.over,
                    'runs': m.runs,
                    'ball_faced': m.ball_faced,
                    'fours': m.fours,
                    'sixes': m.sixes,
                  })
              .toList(),
        },
      );
      return (response as Map<String, dynamic>)['id'] as String;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deleteMatchEvent(String eventId) async {
    try {
      await _api.delete('/match-events/$eventId');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
