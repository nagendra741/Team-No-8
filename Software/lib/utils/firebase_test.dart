import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseTest {
  static Future<bool> testFirebaseConnection() async {
    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      
      // Try to read from a test collection
      await firestore.collection('test').limit(1).get();
      
      debugPrint('✅ Firebase connection successful');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection failed: $e');
      return false;
    }
  }

  static Future<void> createTestDocument() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      await firestore.collection('test').add({
        'message': 'Firebase is working!',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : 'mobile',
      });
      
      debugPrint('✅ Test document created successfully');
    } catch (e) {
      debugPrint('❌ Failed to create test document: $e');
    }
  }
}
