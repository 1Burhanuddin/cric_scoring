import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/models/user_model.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authUser = auth.FirebaseAuth.instance.currentUser;

  if (authUser == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .asyncMap((doc) async {
    if (!doc.exists) {
      // If document doesn't exist, try to create it
      try {
        await firestore.collection('users').doc(authUser.uid).set({
          'uid': authUser.uid,
          'email': authUser.email ?? '',
          'name': authUser.displayName ?? 'User',
          'role': 'viewer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Fetch the newly created document
        final newDoc =
            await firestore.collection('users').doc(authUser.uid).get();
        if (newDoc.exists) {
          return User.fromFirestore(newDoc);
        }
      } catch (e) {
        debugPrint('Error auto-creating user document: $e');
      }
      return null;
    }
    return User.fromFirestore(doc);
  });
});

// All users provider
final allUsersProvider = StreamProvider<List<User>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  });
});

// User provider notifier
final userProviderNotifier =
    StateNotifierProvider<UserNotifier, AsyncValue<void>>((ref) {
  return UserNotifier(ref.watch(firestoreProvider));
});

class UserNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  UserNotifier(this._firestore) : super(const AsyncValue.data(null));

  // Update user player profile
  Future<void> updatePlayerProfile({
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
}
