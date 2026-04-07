import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AutoAddData {
  static bool _dataAdded = false;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addDataOnStartup() async {
    if (_dataAdded) return; // Don't add data multiple times

    try {
      debugPrint('🔥 AUTO-ADDING Firebase data on startup...');

      // Clear existing data first (optional - remove if you want to keep existing data)
      await _clearExistingData();

      // Add all collections with sample data
      await _addEvents();
      await _addLostFoundItems();
      await _addFeedbackItems();
      await _addNotifications();
      await _addFacultyData();

      _dataAdded = true;
      debugPrint('✅ AUTO-ADD completed successfully!');

    } catch (e) {
      debugPrint('❌ AUTO-ADD failed: $e');
      rethrow;
    }
  }

  static Future<void> _clearExistingData() async {
    debugPrint('🧹 Clearing existing data...');

    final collections = ['events', 'lost_and_found', 'feedback', 'notifications', 'faculty'];

    for (String collection in collections) {
      try {
        final QuerySnapshot snapshot = await _firestore.collection(collection).get();
        WriteBatch batch = _firestore.batch();

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        if (snapshot.docs.isNotEmpty) {
          await batch.commit();
          debugPrint('✅ Cleared $collection collection (${snapshot.docs.length} documents)');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to clear $collection: $e');
      }
    }
  }

  static Future<void> _addLostFoundItems() async {
    debugPrint('📱 AUTO-ADDING Lost & Found items...');
    
    // Add multiple items with current timestamp
    final items = [
      {
        'title': 'Lost iPhone 14 Pro Max',
        'description': 'Purple iPhone 14 Pro Max with clear case. Lost near the main entrance.',
        'category': 'Electronics',
        'status': 'lost',
        'imageUrl': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
        'contactNumber': '+919876543210',
        'finderName': 'Arjun Patel',
        'location': 'Main Entrance',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Found Red Backpack',
        'description': 'Red Nike backpack found in the library. Contains textbooks and a laptop charger.',
        'category': 'Accessories',
        'status': 'found',
        'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        'contactNumber': '+919876543211',
        'finderName': 'Sneha Sharma',
        'location': 'Library - 2nd Floor',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Lost Car Keys - Honda',
        'description': 'Honda car keys with black leather keychain. Lost in parking area.',
        'category': 'Keys',
        'status': 'lost',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'contactNumber': '+919876543212',
        'finderName': 'Vikram Singh',
        'location': 'Parking Lot B',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Found Engineering Textbook',
        'description': 'Engineering Mathematics textbook by R.K. Jain. Found in classroom 205.',
        'category': 'Books',
        'status': 'found',
        'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
        'contactNumber': '+919876543213',
        'finderName': 'Priya Gupta',
        'location': 'Classroom 205',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': true,
        'resolvedDate': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Lost Smartwatch',
        'description': 'Black Apple Watch Series 8 with sport band. Lost during sports practice.',
        'category': 'Electronics',
        'status': 'lost',
        'imageUrl': 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
        'contactNumber': '+919876543214',
        'finderName': 'Rohit Kumar',
        'location': 'Sports Ground',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
    ];

    for (int i = 0; i < items.length; i++) {
      await _firestore.collection('lost_and_found').add(items[i]);
      debugPrint('✅ AUTO-ADDED Lost & Found item ${i + 1}/${items.length}');
    }
  }

  static Future<void> _addFeedbackItems() async {
    debugPrint('💬 AUTO-ADDING Feedback items...');
    
    final feedbacks = [
      {
        'userName': 'TechEnthusiast',
        'email': 'tech@college.edu',
        'rating': 5,
        'category': 'App',
        'title': 'Amazing Campus Companion!',
        'message': 'This app has revolutionized campus life! The GPS routing and lost & found features are incredible. Highly recommend to all students!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': 'Thank you for the wonderful feedback! We\'re glad you\'re enjoying the app.',
      },
      {
        'userName': 'Anonymous',
        'email': null,
        'rating': 4,
        'category': 'Campus',
        'title': 'Great app, minor suggestions',
        'message': 'Love the app overall! Could use more WiFi hotspots around campus and maybe a food court menu feature.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'StudyBuddy',
        'email': 'study@college.edu',
        'rating': 5,
        'category': 'Services',
        'title': 'Lost & Found saved my semester!',
        'message': 'I lost my project files USB drive and found it through this app within 3 hours! The notification system is perfect.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': 'So happy we could help! The Lost & Found feature is one of our favorites too.',
      },
      {
        'userName': 'FreshmanLife',
        'email': null,
        'rating': 5,
        'category': 'Faculty',
        'title': 'Faculty directory is super helpful',
        'message': 'As a new student, finding faculty offices was so confusing. This app made it so easy!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'EventLover',
        'email': 'events@college.edu',
        'rating': 4,
        'category': 'Events',
        'title': 'Never miss events anymore',
        'message': 'The event notifications are great! Would love to see more cultural events listed.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'CampusExplorer',
        'email': null,
        'rating': 5,
        'category': 'App',
        'title': 'Perfect for new students',
        'message': 'This app should be mandatory for all new students. Makes campus navigation so much easier!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': 'Thank you! We\'re working on making it part of the orientation package.',
      },
    ];

    for (int i = 0; i < feedbacks.length; i++) {
      await _firestore.collection('feedback').add(feedbacks[i]);
      debugPrint('✅ AUTO-ADDED Feedback ${i + 1}/${feedbacks.length}');
    }
  }

  static Future<void> _addEvents() async {
    debugPrint('📅 AUTO-ADDING Events...');
    
    final events = [
      {
        'title': 'Tech Fest 2024 - Innovation Summit',
        'description': 'Join us for the biggest tech event of the year! Featuring coding competitions, robotics demonstrations, AI workshops, and keynote speeches from industry leaders. Prizes worth ₹1,00,000!',
        'category': 'Technical',
        'posterUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 12))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'venue': 'Main Auditorium & Tech Labs',
        'organizer': 'Computer Science Department',
        'contactInfo': '+919876543220',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/techfest2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Cultural Extravaganza 2024',
        'description': 'Celebrate the rich diversity of our campus! Experience music, dance, drama, and art from different cultures. Food stalls, cultural performances, and traditional games.',
        'category': 'Cultural',
        'posterUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 6))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 6, hours: 8))),
        'venue': 'Open Air Theatre & Campus Grounds',
        'organizer': 'Cultural Committee',
        'contactInfo': '+919876543221',
        'registrationRequired': false,
        'registrationLink': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Mega Career Fair 2024',
        'description': 'Connect with 100+ top companies including Google, Microsoft, Amazon, TCS, Infosys, and many startups. Explore internships, full-time positions, and networking opportunities.',
        'category': 'Academic',
        'posterUrl': 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=600',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 25))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 26))),
        'venue': 'Sports Complex & Convention Center',
        'organizer': 'Placement Cell',
        'contactInfo': '+919876543222',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/careerfair2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'AI & Machine Learning Workshop',
        'description': 'Hands-on workshop covering Python, TensorFlow, neural networks, and real-world AI applications. Build your first machine learning model! Limited seats available.',
        'category': 'Workshop',
        'posterUrl': 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=600',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3, hours: 6))),
        'venue': 'Computer Lab 1 & 2',
        'organizer': 'AI & Robotics Club',
        'contactInfo': '+919876543223',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/aiworkshop2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < events.length; i++) {
      await _firestore.collection('events').add(events[i]);
      debugPrint('✅ AUTO-ADDED Event ${i + 1}/${events.length}');
    }
  }

  static Future<void> _addNotifications() async {
    debugPrint('🔔 AUTO-ADDING Notifications...');

    final notifications = [
      {
        'title': 'Welcome to Campus Companion!',
        'message': 'Your all-in-one campus app is ready to use. Explore events, lost & found, and more!',
        'type': 'system',
        'imageUrl': null,
        'actionUrl': null,
        'metadata': {'welcome': true},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': null, // Global notification
      },
      {
        'title': 'New Event Alert',
        'message': 'Tech Fest 2024 registration is now open! Don\'t miss out on exciting competitions.',
        'type': 'event',
        'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
        'actionUrl': '/events',
        'metadata': {'eventType': 'technical'},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': null,
      },
      {
        'title': 'Lost Item Found',
        'message': 'A red backpack was found in the library. Check if it\'s yours!',
        'type': 'lost_found',
        'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        'actionUrl': '/lost-found',
        'metadata': {'itemType': 'found'},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': null,
      },
      {
        'title': 'App Update Available',
        'message': 'New features added! Update to the latest version for the best experience.',
        'type': 'system',
        'imageUrl': null,
        'actionUrl': null,
        'metadata': {'version': '1.1.0'},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': null,
      },
      {
        'title': 'Feedback Appreciated',
        'message': 'Thank you for your feedback! We\'re working on the improvements you suggested.',
        'type': 'feedback',
        'imageUrl': null,
        'actionUrl': '/feedback',
        'metadata': {'responseType': 'appreciation'},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': true, // Mark as read
        'userId': null,
      },
    ];

    for (int i = 0; i < notifications.length; i++) {
      await _firestore.collection('notifications').add(notifications[i]);
      debugPrint('✅ AUTO-ADDED Notification ${i + 1}/${notifications.length}');
    }
  }

  static Future<void> _addFacultyData() async {
    debugPrint('👨‍🏫 AUTO-ADDING Faculty data...');

    final faculty = [
      {
        'name': 'Dr. Rajesh Kumar',
        'designation': 'Professor & Head',
        'department': 'Computer Science & Engineering',
        'email': 'rajesh.kumar@klu.ac.in',
        'phone': '+91-9876543201',
        'office': 'CSE Block - Room 301',
        'specialization': ['Artificial Intelligence', 'Machine Learning', 'Data Science'],
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'experience': '15 years',
        'qualification': 'Ph.D in Computer Science',
        'isAvailable': true,
        'officeHours': 'Mon-Fri: 10:00 AM - 4:00 PM',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dr. Priya Sharma',
        'designation': 'Associate Professor',
        'department': 'Electronics & Communication Engineering',
        'email': 'priya.sharma@klu.ac.in',
        'phone': '+91-9876543202',
        'office': 'ECE Block - Room 205',
        'specialization': ['VLSI Design', 'Digital Signal Processing', 'Embedded Systems'],
        'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
        'experience': '12 years',
        'qualification': 'Ph.D in Electronics Engineering',
        'isAvailable': true,
        'officeHours': 'Mon-Fri: 9:00 AM - 3:00 PM',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dr. Vikram Singh',
        'designation': 'Assistant Professor',
        'department': 'Mechanical Engineering',
        'email': 'vikram.singh@klu.ac.in',
        'phone': '+91-9876543203',
        'office': 'Mech Block - Room 102',
        'specialization': ['Thermal Engineering', 'Manufacturing', 'CAD/CAM'],
        'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        'experience': '8 years',
        'qualification': 'Ph.D in Mechanical Engineering',
        'isAvailable': false,
        'officeHours': 'Mon-Fri: 11:00 AM - 5:00 PM',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dr. Sneha Gupta',
        'designation': 'Professor',
        'department': 'Civil Engineering',
        'email': 'sneha.gupta@klu.ac.in',
        'phone': '+91-9876543204',
        'office': 'Civil Block - Room 401',
        'specialization': ['Structural Engineering', 'Earthquake Engineering', 'Construction Management'],
        'imageUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        'experience': '18 years',
        'qualification': 'Ph.D in Civil Engineering',
        'isAvailable': true,
        'officeHours': 'Mon-Fri: 10:00 AM - 4:00 PM',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dr. Arjun Patel',
        'designation': 'Associate Professor',
        'department': 'Electrical & Electronics Engineering',
        'email': 'arjun.patel@klu.ac.in',
        'phone': '+91-9876543205',
        'office': 'EEE Block - Room 303',
        'specialization': ['Power Systems', 'Renewable Energy', 'Smart Grid'],
        'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'experience': '10 years',
        'qualification': 'Ph.D in Electrical Engineering',
        'isAvailable': true,
        'officeHours': 'Mon-Fri: 9:00 AM - 3:00 PM',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < faculty.length; i++) {
      await _firestore.collection('faculty').add(faculty[i]);
      debugPrint('✅ AUTO-ADDED Faculty ${i + 1}/${faculty.length}');
    }
  }
}
