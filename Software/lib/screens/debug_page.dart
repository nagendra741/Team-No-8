import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String _status = 'Checking...';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _runTests() async {
    _addLog('Starting Firebase tests...');

    try {
      // Test 1: Check if Firebase is initialized
      _addLog('Test 1: Checking Firebase initialization...');
      final app = Firebase.app();
      _addLog('✅ Firebase app initialized: ${app.name}');

      // Test 2: Check Firestore connection
      _addLog('Test 2: Testing Firestore connection...');
      final firestore = FirebaseFirestore.instance;
      _addLog('✅ Firestore instance created');

      // Test 3: Try to read from Firestore
      _addLog('Test 3: Attempting to read from Firestore...');
      final testDoc = await firestore.collection('test').limit(1).get();
      _addLog('✅ Firestore read successful. Docs: ${testDoc.docs.length}');

      // Test 4: Try to write to Firestore
      _addLog('Test 4: Attempting to write to Firestore...');
      await firestore.collection('test').add({
        'message': 'Test from debug page',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'web',
      });
      _addLog('✅ Firestore write successful');

      setState(() {
        _status = 'All tests passed! Firebase is working.';
      });

    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Tests failed. Check logs for details.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('passed') ? Colors.green : 
                       _status.contains('failed') ? Colors.red : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Logs
            const Text(
              'Test Logs:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

            const SizedBox(height: 20),

            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _logs.clear();
                    _status = 'Checking...';
                  });
                  _runTests();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Run Tests Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
