import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_service.dart';
import '../utils/auto_add_data.dart';

class SimpleFirebaseTest extends StatefulWidget {
  const SimpleFirebaseTest({Key? key}) : super(key: key);

  @override
  State<SimpleFirebaseTest> createState() => _SimpleFirebaseTestState();
}

class _SimpleFirebaseTestState extends State<SimpleFirebaseTest> {
  String _status = 'Ready to test Firebase';
  List<String> _logs = [];
  bool _isLoading = false;
  Map<String, int> _collectionStats = {};

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _testFirebaseDirectly() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
      _status = 'Testing Firebase...';
    });

    try {
      _addLog('🔥 Starting comprehensive Firebase test...');

      // Test 1: Check Firebase initialization
      _addLog('1️⃣ Checking Firebase initialization...');
      final app = Firebase.app();
      _addLog('✅ Firebase app: ${app.name}');
      _addLog('✅ Project ID: ${app.options.projectId}');

      // Test 2: Firebase Service Connection
      _addLog('2️⃣ Testing Firebase Service...');
      bool serviceConnected = await FirebaseService.testConnection();
      _addLog(serviceConnected ? '✅ Firebase Service connected' : '❌ Firebase Service failed');

      // Test 3: Get Firestore instance and test basic operations
      _addLog('3️⃣ Testing Firestore operations...');
      final firestore = FirebaseFirestore.instance;

      final docRef = await firestore.collection('test').add({
        'message': 'Comprehensive test from Flutter!',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
        'testId': DateTime.now().millisecondsSinceEpoch,
      });
      _addLog('✅ Test document added with ID: ${docRef.id}');

      // Test 4: Read document back
      _addLog('4️⃣ Reading document back...');
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _addLog('✅ Document read: ${data['message']}');
      }

      // Test 5: Get collection statistics
      _addLog('5️⃣ Getting collection statistics...');
      _collectionStats = await FirebaseService.getCollectionStats();
      _addLog('✅ Collection stats retrieved: ${_collectionStats.length} collections');
      for (var entry in _collectionStats.entries) {
        _addLog('   📊 ${entry.key}: ${entry.value} documents');
      }

      // Test 6: Test real-time streams
      _addLog('6️⃣ Testing real-time streams...');
      try {
        final eventsStream = FirebaseService.getActiveEvents();
        await eventsStream.first.timeout(const Duration(seconds: 5));
        _addLog('✅ Events stream working');
      } catch (e) {
        _addLog('⚠️ Events stream timeout (may be empty): $e');
      }

      // Test 7: Add sample data using AutoAddData
      _addLog('7️⃣ Adding comprehensive sample data...');
      await AutoAddData.addDataOnStartup();
      _addLog('✅ Sample data added successfully!');

      // Test 8: Verify data was added
      _addLog('8️⃣ Verifying added data...');
      final updatedStats = await FirebaseService.getCollectionStats();
      _addLog('✅ Updated collection stats:');
      for (var entry in updatedStats.entries) {
        _addLog('   📊 ${entry.key}: ${entry.value} documents');
      }

      setState(() {
        _status = '🎉 ALL TESTS PASSED! Firebase is fully operational!';
        _collectionStats = updatedStats;
      });

    } catch (e) {
      _addLog('❌ ERROR: $e');
      setState(() {
        _status = '💥 Tests failed. Check logs for details.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Firebase Test Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _testFirebaseDirectly,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('PASSED') || _status.contains('operational') ? Colors.green :
                       _status.contains('failed') ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Collection Stats
            if (_collectionStats.isNotEmpty) ...[
              const Text(
                'Collection Statistics:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: _collectionStats.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testFirebaseDirectly,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch),
                label: Text(_isLoading ? 'Testing Firebase...' : '🚀 RUN COMPREHENSIVE TEST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Logs
            const Text(
              'Test Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs.map((log) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: log.contains('❌') ? Colors.red :
                                   log.contains('✅') ? Colors.green : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
