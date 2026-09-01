import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/innings/inning_model.dart';
import '../../api/network/supabase_client_provider.dart';
import '../../errors/app_error.dart';

final inningServiceProvider = Provider((ref) {
  return InningsService(ref.read(supabaseClientProvider));
});

class InningsService {
  final SupabaseClient _supabase;

  InningsService(this._supabase);

  String get generateInningId => const Uuid().v4().replaceAll('-', '');

  Future<void> createInnings({
    required List<InningModel> innings,
  }) async {
    try {
      await _supabase.from('innings').upsert(
            innings
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
          );
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<InningModel>> streamInningsByMatchId({
    required String matchId,
  }) {
    try {
      return _supabase
          .from('innings')
          .stream(primaryKey: ['id'])
          .eq('match_id', matchId)
          .map((rows) => rows.map(_inningFromRow).toList());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateInningStatus({
    required String inningId,
    required InningStatus status,
  }) async {
    try {
      await _supabase.from('innings').update({'innings_status': status.value}).eq('id', inningId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> updateInningsStatuses(Map<String, InningStatus> innings) async {
    try {
      for (final entry in innings.entries) {
        await _supabase.from('innings').update({'innings_status': entry.value.value}).eq('id', entry.key);
      }
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  InningModel _inningFromRow(Map<String, dynamic> row) => InningModel(
        id: row['id'] as String,
        match_id: row['match_id'] as String,
        team_id: row['team_id'] as String,
        overs: (row['overs'] as num).toDouble(),
        index: row['index'] as int,
        total_runs: row['total_runs'] as int,
        total_wickets: row['total_wickets'] as int,
        innings_status: row['innings_status'] != null
            ? InningStatus.values.firstWhere((e) => e.value == row['innings_status'])
            : null,
      );
}
