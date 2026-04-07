import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String posterUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String organizer;
  final String contactInfo;
  final bool registrationRequired;
  final String? registrationLink;
  final bool isActive;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.organizer,
    required this.contactInfo,
    required this.registrationRequired,
    this.registrationLink,
    required this.isActive,
    required this.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: data['venue'] ?? '',
      organizer: data['organizer'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      registrationRequired: data['registrationRequired'] ?? false,
      registrationLink: data['registrationLink'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper method to check if event is upcoming
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  
  // Helper method to check if event is ongoing
  bool get isOngoing => 
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  
  // Helper method to check if event is past
  bool get isPast => endDate.isBefore(DateTime.now());
}

// Categories for Events
class EventCategories {
  static const List<String> categories = [
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Workshop',
    'Seminar',
    'Competition',
    'Other',
  ];
}
