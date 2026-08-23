import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/leaderboard/leaderboard_model.dart';
import '../../errors/app_error.dart';
import '../../extensions/date_extension.dart';
import '../../utils/constant/firestore_constant.dart';
import '../user/user_service.dart';

final leaderboardServiceProvider = Provider(
  (ref) => LeaderboardService(
    FirebaseFirestore.instance,
    ref.read(userServiceProvider),
  ),
);

class LeaderboardService {
  final FirebaseFirestore _firestore;
  final UserService _userService;

  LeaderboardService(
    this._firestore,
    this._userService,
  );

  CollectionReference<LeaderboardPlayer> _leaderboardCollection(
    LeaderboardType type,
  ) =>
      _firestore
          .collection(FireStoreConst.leaderboardCollection)
          .doc(type.getDatabaseConst())
          .collection(FireStoreConst.dataCollection)
          .withConverter(
            fromFirestore: LeaderboardPlayer.fromFireStore,
            toFirestore: (LeaderboardPlayer leaderboard, _) =>
                leaderboard.toJson(),
          );

  Future<List<LeaderboardPlayer>> getLeaderboardByField({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
    LeaderboardPlayer? lastPlayer,
    LeaderboardField field = LeaderboardField.batting,
  }) async {
    try {
      var query = _leaderboardCollection(type)
          .orderBy(field.getDatabaseConst(), descending: true)
          .orderBy(FieldPath.documentId)
          .where(
            field.getDatabaseConst(),
            isGreaterThan: field.getMinScoreToGetFeatured(),
          );

      if (type == LeaderboardType.weekly || type == LeaderboardType.monthly) {
        final now = DateTime.now();
        final startTime = type == LeaderboardType.weekly
            ? now.getStartOfWeek
            : now.getStartOfMonth;
        final endTime = type == LeaderboardType.weekly
            ? now.getEndOfWeek
            : now.getEndOfMonth;

        query = query.where(
          FireStoreConst.date,
          isGreaterThanOrEqualTo: startTime,
          isLessThanOrEqualTo: endTime,
        );
      }

      if (lastPlayer != null) {
        query = query.startAfter([
          field == LeaderboardField.batting
              ? lastPlayer.runs
              : field == LeaderboardField.bowling
                  ? lastPlayer.wickets
                  : lastPlayer.catches,
          lastPlayer.id,
        ]);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final docs = snapshot.docs.map((e) => e.data()).toList();

      final players =
          await _userService.getUsersByIds(docs.map((e) => e.id).toList());

      return docs.map((e) {
        final player = players.firstWhere((element) => element.id == e.id);
        return e.copyWith(user: player);
      }).toList();
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Stream<List<LeaderboardPlayer>> streamLeaderboardByField({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
    LeaderboardField field = LeaderboardField.batting,
  }) {
    var query = _leaderboardCollection(type)
        .orderBy(field.getDatabaseConst(), descending: true)
        .where(
          field.getDatabaseConst(),
          isGreaterThan: field.getMinScoreToGetFeatured(),
        );

    if (type == LeaderboardType.weekly || type == LeaderboardType.monthly) {
      final now = DateTime.now();
      final startTime = type == LeaderboardType.weekly
          ? now.getStartOfWeek
          : now.getStartOfMonth;
      final endTime =
          type == LeaderboardType.weekly ? now.getEndOfWeek : now.getEndOfMonth;

      final timeFilter = Filter.and(
        Filter(FireStoreConst.date, isGreaterThanOrEqualTo: startTime),
        Filter(FireStoreConst.date, isLessThanOrEqualTo: endTime),
      );

      query = query.where(timeFilter);
    }

    query = query.limit(limit);
    return query.snapshots().asyncMap((snapshot) async {
      final docs = snapshot.docs.map((e) => e.data()).toList();
      final players =
          await _userService.getUsersByIds(docs.map((e) => e.id).toList());
      return docs.map((e) {
        final player = players.firstWhere((element) => element.id == e.id);
        return e.copyWith(user: player);
      }).toList();
    }).handleError((error, stack) => throw AppError.fromError(error, stack));
  }

  /// Leaderboards aren't migrated to Postgres yet (out of scope for the
  /// matches migration pass) and Firestore access is unavailable now that
  /// the app no longer signs into Firebase Auth. Since there's no leaderboard
  /// data anywhere yet either way, this returns an accurate empty result
  /// rather than a Firestore permission-denied error - unblocks the home
  /// screen's combined matches+tournaments+leaderboard stream. Revert to the
  /// Firestore-backed version (or a real Postgres one) once leaderboards get
  /// their own migration pass.
  Stream<List<LeaderboardModel>> streamLeaderboard({
    LeaderboardType type = LeaderboardType.allTime,
    int limit = 20,
  }) {
    return Stream.value(const <LeaderboardModel>[]);
  }
}
