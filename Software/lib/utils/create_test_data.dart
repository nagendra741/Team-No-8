import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class CreateTestData {
  static Future<void> createSampleData() async {
    try {
      print('Creating sample data...');

      // Create Lost & Found items
      await _createLostAndFoundData();
      
      // Create Feedback data
      await _createFeedbackData();
      
      // Create Events data
      await _createEventsData();
      
      print('Sample data created successfully!');
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  static Future<void> _createLostAndFoundData() async {
    // Sample Lost & Found items
    final lostFoundItems = [
      {
        'title': 'Lost iPhone 13',
        'description': 'Black iPhone 13 with blue case, lost near library',
        'category': 'Electronics',
        'status': 'lost',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1ABC123',
        'contactNumber': '+919876543210',
        'finderName': 'Rahul Sharma',
        'location': 'Library Building',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Found Blue Backpack',
        'description': 'Blue Jansport backpack found in cafeteria with books inside',
        'category': 'Accessories',
        'status': 'found',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1DEF456',
        'contactNumber': '+919876543211',
        'finderName': 'Priya Patel',
        'location': 'Cafeteria',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
      {
        'title': 'Lost Car Keys',
        'description': 'Honda car keys with red keychain, lost in parking lot',
        'category': 'Keys',
        'status': 'lost',
        'imageUrl': 'https://drive.google.com/uc?export=view&id=1GHI789',
        'contactNumber': '+919876543212',
        'finderName': 'Amit Kumar',
        'location': 'Parking Lot A',
        'dateReported': FieldValue.serverTimestamp(),
        'isResolved': false,
        'resolvedDate': null,
      },
    ];

    for (var item in lostFoundItems) {
      await FirebaseFirestore.instance.collection('lost_and_found').add(item);
    }
    print('Lost & Found data created');
  }

  static Future<void> _createFeedbackData() async {
    // Sample Feedback
    final feedbackItems = [
      {
        'userName': 'Anonymous',
        'email': null,
        'rating': 5,
        'category': 'App',
        'title': 'Excellent Campus App!',
        'message': 'This app is incredibly helpful for campus navigation and finding lost items. Great work!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'Student123',
        'email': 'student@college.edu',
        'rating': 4,
        'category': 'Campus',
        'title': 'More WiFi spots needed',
        'message': 'The app is great but we need more WiFi hotspots around campus, especially in the library.',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
      {
        'userName': 'TechStudent',
        'email': null,
        'rating': 5,
        'category': 'Services',
        'title': 'GPS routing is amazing',
        'message': 'The GPS routing feature helped me find my classes on the first day. Very useful!',
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': true,
        'adminResponse': null,
      },
    ];

    for (var feedback in feedbackItems) {
      await FirebaseFirestore.instance.collection('feedback').add(feedback);
    }
    print('Feedback data created');
  }

  static Future<void> _createEventsData() async {
    // Sample Events
    final events = [
      {
        'title': 'Tech Fest 2024',
        'description': 'Annual technology festival featuring coding competitions, robotics, and tech talks by industry experts.',
        'category': 'Technical',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1TECH123',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 32))),
        'venue': 'Main Auditorium',
        'organizer': 'Computer Science Department',
        'contactInfo': '+919876543213',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/techfest2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Cultural Night',
        'description': 'Celebrate diversity with music, dance, and cultural performances from students around the world.',
        'category': 'Cultural',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1CULT456',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15, hours: 4))),
        'venue': 'Open Air Theatre',
        'organizer': 'Cultural Committee',
        'contactInfo': '+919876543214',
        'registrationRequired': false,
        'registrationLink': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Career Fair 2024',
        'description': 'Meet with top companies and explore internship and job opportunities. Bring your resume!',
        'category': 'Academic',
        'posterUrl': 'https://drive.google.com/uc?export=view&id=1CAREER789',
        'startDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45, hours: 6))),
        'venue': 'Sports Complex',
        'organizer': 'Placement Cell',
        'contactInfo': '+919876543215',
        'registrationRequired': true,
        'registrationLink': 'https://forms.google.com/careerfair2024',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var event in events) {
      await FirebaseFirestore.instance.collection('events').add(event);
    }
    print('Events data created');
  }
}
