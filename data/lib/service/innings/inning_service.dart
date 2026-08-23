import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../api/innings/inning_model.dart';
import '../../api/network/api_client.dart';
import '../../errors/app_error.dart';

final inningServiceProvider = Provider((ref) {
  return InningsService(ref.read(apiClientProvider));
});

class InningsService {
  final ApiClient _api;

  InningsService(this._api);

  String get generateInningId => const Uuid().v4().replaceAll('-', '');

  Future<void> createInnings({
    required List<InningModel> innings,
  }) async {
    try {
      await _api.post(
        '/innings/batch',
        data: {
          'innings': innings
              .map((i) => {
                    'id': i.id,
                    'match_id': i.match_id,
                    'team_id': i.team_id,
                    'overs': i.overs,
                    'index': i.index,
                    'total_runs': i.total_runs,
                    'total_wickets': i.total_wickets,
                    'innings_status': i.innings_status?.value,
                  })
              .toList(),
        },
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  /// No realtime channel for innings yet - see BallScoreService for the
  /// same caveat. Emits a single snapshot rather than live updates.
  Stream<List<InningModel>> streamInningsByMatchId({
    required String matchId,
  }) async* {
    try {
      final response = await _api.get('/innings/by-match/$matchId');
      yield (response as List)
          .map((json) => InningModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateInningStatus({
    required String inningId,
    required InningStatus status,
  }) async {
    try {
      await _api.patch('/innings/$inningId/status', data: {'innings_status': status.value});
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateInningsStatuses(Map<String, InningStatus> innings) async {
    try {
      await _api.patch(
        '/innings/status-batch',
        data: {'statuses': innings.map((id, status) => MapEntry(id, status.value))},
      );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }
}
