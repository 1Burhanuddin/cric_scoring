import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../api/network/supabase_client_provider.dart';
import '../../api/partnership/partnership_model.dart';
import '../../errors/app_error.dart';

final partnershipServiceProvider = Provider(
  (ref) => PartnershipService(ref.read(supabaseClientProvider)),
);

class PartnershipService {
  final SupabaseClient _supabase;

  PartnershipService(this._supabase);

  String get generatePartnershipId => const Uuid().v4().replaceAll('-', '');

  Future<String> updatePartnership(PartnershipModel partnership) async {
    try {
      final id = partnership.id.isNotEmpty ? partnership.id : generatePartnershipId;
      await _supabase.from('partnerships').upsert({
        'id': id,
        'match_id': partnership.match_id,
        'inning_id': partnership.inning_id,
        'player_ids': partnership.player_ids,
        'players': partnership.players.map((p) => p.toJson()).toList(),
        'runs': partnership.runs,
        'extras': partnership.extras,
        'ball_faced': partnership.ball_faced,
        'start_over': partnership.start_over,
        'end_over': partnership.end_over,
      });
      return id;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<PartnershipModel>> streamPartnershipByMatches(String matchId) {
    try {
      return _supabase
          .from('partnerships')
          .stream(primaryKey: ['id'])
          .eq('match_id', matchId)
          .map((rows) => rows.map(_partnershipFromRow).toList());
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<void> deletePartnership(String partnershipId) async {
    try {
      await _supabase.from('partnerships').delete().eq('id', partnershipId);
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  PartnershipModel _partnershipFromRow(Map<String, dynamic> row) => PartnershipModel(
        id: row['id'] as String,
        match_id: row['match_id'] as String,
        inning_id: row['inning_id'] as String,
        player_ids: ((row['player_ids'] as List?) ?? const []).cast<String>(),
        players: ((row['players'] as List?) ?? const [])
            .map((p) => PartnershipPlayer.fromJson(p as Map<String, dynamic>))
            .toList(),
        runs: row['runs'] as int,
        extras: row['extras'] as int,
        ball_faced: row['ball_faced'] as int,
        start_over: (row['start_over'] as num).toDouble(),
        end_over: (row['end_over'] as num).toDouble(),
      );
}
