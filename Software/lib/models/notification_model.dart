import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'event', 'lost_found', 'feedback', 'general'
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final bool isRead;
  final String? userId; // null for global notifications

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.actionUrl,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
    this.userId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      imageUrl: data['imageUrl'],
      actionUrl: data['actionUrl'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'userId': userId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }

  // Helper methods
  bool get isGlobal => userId == null;
  bool get isPersonal => userId != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Notification Types
class NotificationTypes {
  static const String event = 'event';
  static const String lostFound = 'lost_found';
  static const String feedback = 'feedback';
  static const String general = 'general';
  static const String system = 'system';
  
  static const List<String> all = [
    event,
    lostFound,
    feedback,
    general,
    system,
  ];
}

// Notification Factory for creating different types
class NotificationFactory {
  static NotificationModel createEventNotification({
    required String eventTitle,
    required String eventId,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: '',
      title: 'New Event: $eventTitle',
      message: 'A new event has been added. Check it out!',
      type: NotificationTypes.event,
      imageUrl: imageUrl,
      actionUrl: '/events/$eventId',
      metadata: {'eventId': eventId},
      createdAt: DateTime.now(),
    );
  }

  static NotificationModel createLostFoundNotification({
    required String itemTitle,
    required String itemId,
    required String status, // 'lost' or 'found'
    String? imageUrl,
  }) {
    return NotificationModel(
      id: '',
      title: status == 'lost' ? 'Item Lost: $itemTitle' : 'Item Found: $itemTitle',
      message: status == 'lost' 
          ? 'Someone has reported a lost item. Check if it\'s yours!'
          : 'Someone found an item. Check if it\'s yours!',
      type: NotificationTypes.lostFound,
      imageUrl: imageUrl,
      actionUrl: '/lost-found/$itemId',
      metadata: {'itemId': itemId, 'status': status},
      createdAt: DateTime.now(),
    );
  }

  static NotificationModel createFeedbackNotification({
    required String feedbackTitle,
    required String feedbackId,
  }) {
    return NotificationModel(
      id: '',
      title: 'New Feedback: $feedbackTitle',
      message: 'New feedback has been submitted.',
      type: NotificationTypes.feedback,
      actionUrl: '/feedback/$feedbackId',
      metadata: {'feedbackId': feedbackId},
      createdAt: DateTime.now(),
    );
  }

  static NotificationModel createSystemNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: '',
      title: title,
      message: message,
      type: NotificationTypes.system,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      createdAt: DateTime.now(),
    );
  }
}
