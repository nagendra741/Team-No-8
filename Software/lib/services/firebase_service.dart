import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Enable offline persistence for better performance
    if (!kIsWeb) {
      await _firestore.enablePersistence();
    }

    debugPrint('🔥 Firebase initialized successfully!');
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
      });
      debugPrint('✅ Firebase connection test successful!');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection test failed: $e');
      return false;
    }
  }

  // Lost & Found Methods
  static Future<String> addLostAndFoundItem({
    required String title,
    required String description,
    required String category,
    required String status, // 'lost' or 'found'
    required String imageUrl,
    required String contactNumber,
    required String finderName,
    required String location,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('lost_and_found').add({
        'title': title,
        'description': description,
        'category': category,
        'status': status,
        'imageUrl': imageUrl,
        'contactNumber': contactNumber,
        'finderName': finderName,
        'location': location,
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      });

      // Create notification for new lost/found item
      await addNotification(
        title: status == 'lost' ? 'Item Lost: $title' : 'Item Found: $title',
        message: status == 'lost'
            ? 'Someone has reported a lost item. Check if it\'s yours!'
            : 'Someone found an item. Check if it\'s yours!',
        type: 'lost_found',
        imageUrl: imageUrl,
        actionUrl: '/lost-found/${docRef.id}',
        metadata: {'itemId': docRef.id, 'status': status},
      );

      debugPrint('✅ Lost & Found item added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to add lost & found item: $e');
      throw Exception('Failed to add item: $e');
    }
  }

  static Future<void> markItemAsResolved(String itemId) async {
    try {
      await _firestore.collection('lost_and_found').doc(itemId).update({
        'isResolved': true,
        'resolvedDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark as resolved: $e');
    }
  }

  static Stream<QuerySnapshot> getLostAndFoundItems() {
    return _firestore
        .collection('lost_and_found')
        .orderBy('dateReported', descending: true)
        .snapshots();
  }

  static Future<void> markAsResolved(String itemId) async {
    try {
      await _firestore
          .collection('lost_and_found')
          .doc(itemId)
          .update({
        'isResolved': true,
        'resolvedDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark item as resolved: $e');
    }
  }

  // Feedback Methods
  static Future<String> addFeedback({
    required String userName,
    String? email,
    required int rating,
    required String category,
    required String title,
    required String message,
    bool isPublic = true,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('feedback').add({
        'userName': userName,
        'email': email,
        'rating': rating,
        'category': category,
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': isPublic,
        'adminResponse': null,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  static Stream<QuerySnapshot> getPublicFeedback() {
    return _firestore
        .collection('feedback')
        .where('isPublic', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Events Methods
  static Future<String> addEvent({
    required String title,
    required String description,
    required String category,
    required String posterUrl,
    required DateTime startDate,
    required DateTime endDate,
    required String venue,
    required String organizer,
    required String contactInfo,
    bool registrationRequired = false,
    String? registrationLink,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('events').add({
        'title': title,
        'description': description,
        'category': category,
        'posterUrl': posterUrl,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'venue': venue,
        'organizer': organizer,
        'contactInfo': contactInfo,
        'registrationRequired': registrationRequired,
        'registrationLink': registrationLink,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for new event
      await addNotification(
        title: 'New Event: $title',
        message: 'A new event has been added. Check it out!',
        type: 'event',
        imageUrl: posterUrl,
        actionUrl: '/events/${docRef.id}',
        metadata: {'eventId': docRef.id},
      );

      debugPrint('✅ Event added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to add event: $e');
      throw Exception('Failed to add event: $e');
    }
  }

  static Stream<QuerySnapshot> getActiveEvents() {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate', descending: false)
        .snapshots();
  }

  static Stream<QuerySnapshot> getEventsByCategory(String category) {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('startDate', descending: false)
        .snapshots();
  }

  static Future<void> deactivateEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to deactivate event: $e');
    }
  }

  // Image Upload Service
  static Future<String> uploadImage(File imageFile, String folder) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Image deleted successfully');
    } catch (e) {
      debugPrint('❌ Image deletion failed: $e');
    }
  }

  // Utility method to convert Google Drive share link to direct image URL
  static String convertDriveUrl(String driveShareUrl) {
    // Extract file ID from Google Drive share URL
    final RegExp regExp = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
    final Match? match = regExp.firstMatch(driveShareUrl);

    if (match != null) {
      final String fileId = match.group(1)!;
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    // If it's already a direct URL or different format, return as is
    return driveShareUrl;
  }

  // Batch operations for better performance
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (var operation in operations) {
        final String collection = operation['collection'];
        final Map<String, dynamic> data = operation['data'];
        final String? docId = operation['docId'];

        if (docId != null) {
          batch.set(_firestore.collection(collection).doc(docId), data);
        } else {
          batch.set(_firestore.collection(collection).doc(), data);
        }
      }

      await batch.commit();
      debugPrint('✅ Batch write completed successfully');
    } catch (e) {
      debugPrint('❌ Batch write failed: $e');
      throw Exception('Batch operation failed: $e');
    }
  }

  // Notification Methods
  static Future<String> addNotification({
    required String title,
    required String message,
    required String type,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    String? userId, // null for global notifications
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'imageUrl': imageUrl,
        'actionUrl': actionUrl,
        'metadata': metadata,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': userId,
      });

      debugPrint('✅ Notification added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to add notification: $e');
      throw Exception('Failed to add notification: $e');
    }
  }

  static Stream<QuerySnapshot> getNotifications({String? userId}) {
    Query query = _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    if (userId != null) {
      // Get both global notifications and user-specific ones
      query = query.where('userId', whereIn: [null, userId]);
    } else {
      // Get only global notifications
      query = query.where('userId', isNull: true);
    }

    return query.snapshots();
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      debugPrint('✅ Notification marked as read');
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
    }
  }

  static Future<void> markAllNotificationsAsRead({String? userId}) async {
    try {
      Query query = _firestore.collection('notifications').where('isRead', isEqualTo: false);

      if (userId != null) {
        query = query.where('userId', whereIn: [null, userId]);
      } else {
        query = query.where('userId', isNull: true);
      }

      final QuerySnapshot snapshot = await query.get();
      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      debugPrint('✅ All notifications marked as read');
    } catch (e) {
      debugPrint('❌ Failed to mark all notifications as read: $e');
    }
  }

  static Future<int> getUnreadNotificationCount({String? userId}) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('isRead', isEqualTo: false);

      if (userId != null) {
        query = query.where('userId', whereIn: [null, userId]);
      } else {
        query = query.where('userId', isNull: true);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Failed to get unread notification count: $e');
      return 0;
    }
  }

  // Faculty Methods
  static Future<String> addFaculty({
    required String name,
    required String designation,
    required String department,
    required String email,
    required String phone,
    required String office,
    required List<String> specialization,
    String? imageUrl,
    required String experience,
    required String qualification,
    bool isAvailable = true,
    required String officeHours,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('faculty').add({
        'name': name,
        'designation': designation,
        'department': department,
        'email': email,
        'phone': phone,
        'office': office,
        'specialization': specialization,
        'imageUrl': imageUrl,
        'experience': experience,
        'qualification': qualification,
        'isAvailable': isAvailable,
        'officeHours': officeHours,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Faculty added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to add faculty: $e');
      throw Exception('Failed to add faculty: $e');
    }
  }

  static Stream<QuerySnapshot> getFaculty({String? department}) {
    Query query = _firestore.collection('faculty').orderBy('name');

    if (department != null && department.isNotEmpty) {
      query = query.where('department', isEqualTo: department);
    }

    return query.snapshots();
  }

  static Future<void> updateFacultyAvailability(String facultyId, bool isAvailable) async {
    try {
      await _firestore.collection('faculty').doc(facultyId).update({
        'isAvailable': isAvailable,
      });
      debugPrint('✅ Faculty availability updated');
    } catch (e) {
      debugPrint('❌ Failed to update faculty availability: $e');
    }
  }

  static Stream<QuerySnapshot> searchFaculty(String searchTerm) {
    return _firestore
        .collection('faculty')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .snapshots();
  }

  // Get collection statistics
  static Future<Map<String, int>> getCollectionStats() async {
    try {
      final Map<String, int> stats = {};

      final collections = ['events', 'lost_and_found', 'feedback', 'notifications', 'faculty'];

      for (String collection in collections) {
        final QuerySnapshot snapshot = await _firestore.collection(collection).get();
        stats[collection] = snapshot.docs.length;
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Failed to get collection stats: $e');
      return {};
    }
  }
}
