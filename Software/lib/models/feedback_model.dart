import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userName;
  final String? email;
  final int rating;
  final String category;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isPublic;
  final String? adminResponse;

  FeedbackModel({
    required this.id,
    required this.userName,
    this.email,
    required this.rating,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isPublic,
    this.adminResponse,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return FeedbackModel(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      email: data['email'],
      rating: data['rating'] ?? 5,
      category: data['category'] ?? 'General',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: data['isPublic'] ?? true,
      adminResponse: data['adminResponse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'email': email,
      'rating': rating,
      'category': category,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isPublic': isPublic,
      'adminResponse': adminResponse,
    };
  }
}

// Categories for Feedback
class FeedbackCategories {
  static const List<String> categories = [
    'App',
    'Campus',
    'Services',
    'Faculty',
    'Infrastructure',
    'Events',
    'Other',
  ];
}
