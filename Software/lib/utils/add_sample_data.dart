import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddSampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addTestData() async {
    try {
      debugPrint('🔥 Starting to add sample data to Firebase...');

      // Add Lost & Found items
      await _addLostAndFoundItems();
      
      // Add Feedback items
      await _addFeedbackItems();
      
      // Add Events
      await _addEvents();
      
      debugPrint('✅ All sample data added successfully!');
    } catch (e) {
      debugPrint('❌ Error adding sample data: $e');
      rethrow;
    }
  }

  static Future<void> _addLostAndFoundItems() async {
    debugPrint('📱 Adding Lost & Found items...');

    final items = [
      {
        'title': 'Lost iPhone 13 Pro',
        'description': 'Black iPhone 13 Pro with cracked screen protector. Lost near the library building around 2 PM.',
        'category': 'Electronics',
        'status': 'lost',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1ABC123SAMPLE',
        'contactNumber': '+919876543210',
        'finderName': 'Rahul Sharma',
        'location': 'Library Building',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Found Blue Backpack',
        'description': 'Blue Jansport backpack found in the cafeteria. Contains notebooks and a water bottle.',
        'category': 'Accessories',
        'status': 'found',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1DEF456SAMPLE',
        'contactNumber': '+919876543211',
        'finderName': 'Priya Patel',
        'location': 'Cafeteria',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Lost Car Keys',
        'description': 'Honda car keys with red keychain and house keys attached. Lost in parking lot.',
        'category': 'Keys',
        'status': 'lost',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1GHI789SAMPLE',
        'contactNumber': '+919876543212',
        'finderName': 'Amit Kumar',
        'location': 'Parking Lot A',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Found Textbook',
        'description': 'Engineering Mathematics textbook found in classroom 101. Has name "Sarah" written inside.',
        'category': 'Books',
        'status': 'found',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1JKL012SAMPLE',
        'contactNumber': '+919876543213',
        'finderName': 'David Wilson',
        'location': 'Classroom 101',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': true,
        'resolvedDate': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < items.length; i++) {
      await _firestore.collection('lost_and_found').add(items[i]);
      debugPrint('✅ Added Lost & Found item ${i + 1}/${items.length}');
    }
  }

  static Future<void> _addFeedbackItems() async {
    debugPrint('💬 Adding Feedback items...');

    final feedbacks = [
      {
        'userName': 'Anonymous',
        'email': null,
        'rating': 5,
        'category': 'App',
        'title': 'Excellent Campus App!',
        'message': 'This app is incredibly helpful for campus navigation and finding lost items. The GPS routing feature is amazing!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'TechStudent',
        'email': 'student@college.edu',
        'rating': 4,
        'category': 'Campus',
        'title': 'Great app, need more WiFi',
        'message': 'Love the app features but we need more WiFi hotspots around campus, especially in the library and cafeteria areas.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'Sarah M.',
        'email': null,
        'rating': 5,
        'category': 'Services',
        'title': 'Lost & Found feature saved my day!',
        'message': 'I found my lost textbook through this app within 2 hours. The notification system works perfectly!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': 'Thank you for the feedback! We\'re glad the Lost & Found feature helped you.',
      },
      {
        'userName': 'Mike Johnson',
        'email': 'mike.j@college.edu',
        'rating': 3,
        'category': 'Faculty',
        'title': 'Faculty directory needs update',
        'message': 'Some faculty contact information is outdated. Please update the directory with current phone numbers.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'Anonymous',
        'email': null,
        'rating': 5,
        'category': 'Events',
        'title': 'Love the event notifications',
        'message': 'Getting notified about campus events is so convenient. Never miss any important announcements now!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
    ];

    for (int i = 0; i < feedbacks.length; i++) {
      await _firestore.collection('feedback').add(feedbacks[i]);
      debugPrint('✅ Added Feedback ${i + 1}/${feedbacks.length}');
    }
  }

  static Future<void> _addEvents() async {
    debugPrint('📅 Adding Events...');

    final events = [
      {
        'title': 'Tech Fest 2024',
        'description': 'Annual technology festival featuring coding competitions, robotics demonstrations, and tech talks by industry experts. Prizes worth ₹50,000!',
        'category': 'Technical',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1TECH2024SAMPLE',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 17))),
        'venue': 'Main Auditorium & Tech Labs',
        'organizer': 'Computer Science Department',
        'contactInfo': '+919876543214',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/techfest2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Cultural Night 2024',
        'description': 'Celebrate diversity with music, dance, and cultural performances from students around the world. Food stalls from different cultures!',
        'category': 'Cultural',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1CULTURAL2024SAMPLE',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 8))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 8, hours: 6))),
        'venue': 'Open Air Theatre',
        'organizer': 'Cultural Committee',
        'contactInfo': '+919876543215',
        'registrationRequired': false,
        'registrationLink': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Career Fair 2024',
        'description': 'Meet with top companies including Google, Microsoft, Amazon, and 50+ other companies. Explore internship and job opportunities.',
        'category': 'Academic',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1CAREER2024SAMPLE',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30, hours: 8))),
        'venue': 'Sports Complex',
        'organizer': 'Placement Cell',
        'contactInfo': '+919876543216',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/careerfair2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Workshop: AI & Machine Learning',
        'description': 'Hands-on workshop on Artificial Intelligence and Machine Learning. Learn Python, TensorFlow, and build your first AI model.',
        'category': 'Workshop',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1AIML2024SAMPLE',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5, hours: 4))),
        'venue': 'Computer Lab 1',
        'organizer': 'AI Club',
        'contactInfo': '+919876543217',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/aiworkshop2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < events.length; i++) {
      await _firestore.collection('events').add(events[i]);
      debugPrint('✅ Added Event ${i + 1}/${events.length}');
    }
  }
}
