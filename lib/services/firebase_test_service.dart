import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTestService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTestService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Test Firestore connection by writing and reading a document
  Future<bool> testFirestoreConnection() async {
    try {
      final testRef = _firestore.collection('_test').doc('connection_test');

      // Write test document
      await testRef.set({
        'message': 'Firebase connection successful!',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'Flutter',
      });

      // Read test document
      final snapshot = await testRef.get();

      if (snapshot.exists) {
        print('✅ Firestore connection successful!');
        print('📄 Test document data: ${snapshot.data()}');

        // Clean up test document
        await testRef.delete();
        print('🧹 Test document cleaned up');

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }

  /// Test Firestore stream
  Stream<Map<String, dynamic>?> testFirestoreStream() {
    return _firestore
        .collection('_test')
        .doc('stream_test')
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Create a test collection with sample data
  Future<void> createTestCollection() async {
    try {
      final batch = _firestore.batch();

      // Create test teams
      final team1Ref = _firestore.collection('teams').doc('test_team_1');
      batch.set(team1Ref, {
        'teamId': 'test_team_1',
        'name': 'Test Warriors',
        'city': 'Test City',
        'color': '0xFF1E88E5',
        'stats': {
          'matches': 0,
          'wins': 0,
          'losses': 0,
          'winPercentage': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final team2Ref = _firestore.collection('teams').doc('test_team_2');
      batch.set(team2Ref, {
        'teamId': 'test_team_2',
        'name': 'Test Champions',
        'city': 'Test Town',
        'color': '0xFFE53935',
        'stats': {
          'matches': 0,
          'wins': 0,
          'losses': 0,
          'winPercentage': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create test players
      final player1Ref = _firestore.collection('players').doc('test_player_1');
      batch.set(player1Ref, {
        'playerId': 'test_player_1',
        'name': 'Test Player 1',
        'age': 25,
        'role': 'batsman',
        'battingStyle': 'Right-hand bat',
        'bowlingStyle': 'Right-arm medium',
        'teamId': 'test_team_1',
        'city': 'Test City',
        'stats': {
          'matches': 0,
          'runs': 0,
          'wickets': 0,
          'battingAverage': 0.0,
          'bowlingAverage': 0.0,
          'strikeRate': 0.0,
          'economy': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('✅ Test collection created successfully!');
    } catch (e) {
      print('❌ Failed to create test collection: $e');
      rethrow;
    }
  }

  /// Clean up test data
  Future<void> cleanupTestData() async {
    try {
      final batch = _firestore.batch();

      // Delete test teams
      batch.delete(_firestore.collection('teams').doc('test_team_1'));
      batch.delete(_firestore.collection('teams').doc('test_team_2'));

      // Delete test players
      batch.delete(_firestore.collection('players').doc('test_player_1'));

      await batch.commit();
      print('🧹 Test data cleaned up successfully!');
    } catch (e) {
      print('❌ Failed to cleanup test data: $e');
    }
  }

  /// Get Firebase Auth status
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
