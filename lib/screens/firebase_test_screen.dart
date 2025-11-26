import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/services/firebase_test_service.dart';
import 'package:cric_scoring/providers/firebase_providers.dart';

final firebaseTestServiceProvider = Provider((ref) {
  return FirebaseTestService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

class FirebaseTestScreen extends ConsumerStatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  ConsumerState<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends ConsumerState<FirebaseTestScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Ready to test Firebase connection';
  bool? _connectionSuccess;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Firebase connection...';
      _connectionSuccess = null;
    });

    try {
      final service = ref.read(firebaseTestServiceProvider);
      final success = await service.testFirestoreConnection();

      setState(() {
        _isLoading = false;
        _connectionSuccess = success;
        _statusMessage = success
            ? '✅ Firebase connected successfully!'
            : '❌ Firebase connection failed';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionSuccess = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test data...';
    });

    try {
      final service = ref.read(firebaseTestServiceProvider);
      await service.createTestCollection();

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Test data created successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Failed to create test data: $e';
      });
    }
  }

  Future<void> _cleanupTestData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cleaning up test data...';
    });

    try {
      final service = ref.read(firebaseTestServiceProvider);
      await service.cleanupTestData();

      setState(() {
        _isLoading = false;
        _statusMessage = '🧹 Test data cleaned up successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Failed to cleanup: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _connectionSuccess == null
                  ? Colors.blue.shade50
                  : _connectionSuccess!
                      ? Colors.green.shade50
                      : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Icon(
                        _connectionSuccess == null
                            ? Icons.info_outline
                            : _connectionSuccess!
                                ? Icons.check_circle
                                : Icons.error_outline,
                        size: 48,
                        color: _connectionSuccess == null
                            ? Colors.blue
                            : _connectionSuccess!
                                ? Colors.green
                                : Colors.red,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Auth Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    authState.when(
                      data: (user) => Text(
                        user != null
                            ? '✅ Signed in as: ${user.email ?? user.uid}'
                            : '❌ Not signed in',
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, __) => const Text('Error loading auth state'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Test Firestore Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTestData,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Test Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _cleanupTestData,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Cleanup Test Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Test connection to verify Firebase setup'),
                    Text('2. Create test data to populate Firestore'),
                    Text('3. Check Firebase Console to see the data'),
                    Text('4. Cleanup when done testing'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
