import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/network/api_client.dart';
import '../../api/partnership/partnership_model.dart';
import '../../errors/app_error.dart';

final partnershipServiceProvider = Provider(
  (ref) => PartnershipService(ref.read(apiClientProvider)),
);

class PartnershipService {
  final ApiClient _api;

  PartnershipService(this._api);

  String get generatePartnershipId => const Uuid().v4().replaceAll('-', '');

  Future<String> updatePartnership(PartnershipModel partnership) async {
    try {
      final id = partnership.id.isNotEmpty ? partnership.id : generatePartnershipId;
      final response = await _api.put(
        '/partnerships/$id',
        data: {
          'match_id': partnership.match_id,
          'inning_id': partnership.inning_id,
          'player_ids': partnership.player_ids,
          'players': partnership.players
              .map((p) => {
                    'player_id': p.player_id,
                    'runs': p.runs,
                    'ball_faced': p.ball_faced,
                    'fours': p.fours,
                    'sixes': p.sixes,
                  })
              .toList(),
          'runs': partnership.runs,
          'extras': partnership.extras,
          'ball_faced': partnership.ball_faced,
          'start_over': partnership.start_over,
          'end_over': partnership.end_over,
        },
      );
      return (response as Map<String, dynamic>)['id'] as String;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel yet - emits a single snapshot. See BallScoreService
  /// for the same caveat during live scoring.
  Stream<List<PartnershipModel>> streamPartnershipByMatches(String matchId) async* {
    try {
      final response = await _api.get('/partnerships/by-match/$matchId');
      yield (response as List)
          .map((json) => PartnershipModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deletePartnership(String partnershipId) async {
    try {
      await _api.delete('/partnerships/$partnershipId');
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
