import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/player_model.dart';
import 'package:cric_scoring/models/user_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// All users as players provider
final playersListProvider = StreamProvider<List<User>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
    final users = snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    debugPrint('playersListProvider: Loaded ${users.length} users');
    return users;
  }).handleError((error) {
    debugPrint('playersListProvider ERROR: $error');
    throw error;
  });
});

// Team players provider
final teamPlayersProvider =
    StreamProvider.family<List<TeamPlayer>, String>((ref, teamId) {
  final firestore = ref.watch(firestoreProvider);

  debugPrint('teamPlayersProvider: Fetching players for team: $teamId');

  return firestore
      .collection('teams')
      .doc(teamId)
      .collection('players')
      .snapshots()
      .map((snapshot) {
    debugPrint(
        'teamPlayersProvider: Got ${snapshot.docs.length} players for team $teamId');
    final players = snapshot.docs.map((doc) {
      debugPrint('  Player: ${doc.data()['name']} (${doc.id})');
      return TeamPlayer.fromMap(doc.data());
    }).toList();

    // Sort by jersey number in memory
    players.sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));
    return players;
  }).handleError((error) {
    debugPrint('teamPlayersProvider ERROR for team $teamId: $error');
    throw error;
  });
});

// Player provider notifier
final playerProviderNotifier =
    StateNotifierProvider<PlayerNotifier, AsyncValue<void>>((ref) {
  return PlayerNotifier(ref.watch(firestoreProvider));
});

class PlayerNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  PlayerNotifier(this._firestore) : super(const AsyncValue.data(null));

  // Update user player profile
  Future<void> updateUserPlayerProfile({
    required String userId,
    required int jerseyNumber,
    required String playerRole,
    required String battingStyle,
    String? bowlingStyle,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _firestore.collection('users').doc(userId).update({
        'jerseyNumber': jerseyNumber,
        'playerRole': playerRole,
        'battingStyle': battingStyle,
        'bowlingStyle': bowlingStyle,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Add user as player to team
  Future<void> addPlayerToTeam({
    required String teamId,
    required User user,
    bool isCaptain = false,
    bool isWicketKeeper = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .doc(user.uid)
          .set({
        'playerId': user.uid,
        'name': user.name,
        'role': user.playerRole ?? 'batsman',
        'jerseyNumber': user.jerseyNumber ?? 0,
        'isCaptain': isCaptain,
        'isWicketKeeper': isWicketKeeper,
        'addedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Remove player from team
  Future<void> removePlayerFromTeam(String teamId, String playerId) async {
    state = const AsyncValue.loading();

    try {
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .doc(playerId)
          .delete();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Update player in team
  Future<void> updatePlayerInTeam({
    required String teamId,
    required String playerId,
    bool? isCaptain,
    bool? isWicketKeeper,
  }) async {
    state = const AsyncValue.loading();

    try {
      final updates = <String, dynamic>{};
      if (isCaptain != null) updates['isCaptain'] = isCaptain;
      if (isWicketKeeper != null) updates['isWicketKeeper'] = isWicketKeeper;

      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .doc(playerId)
          .update(updates);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
