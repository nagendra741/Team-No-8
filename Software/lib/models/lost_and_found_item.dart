import 'package:cloud_firestore/cloud_firestore.dart';

class LostAndFoundItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status; // 'lost' or 'found'
  final String imageUrl;
  final String contactNumber;
  final String finderName;
  final String location;
  final DateTime dateReported;
  final bool isResolved;
  final DateTime? resolvedDate;

  LostAndFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.contactNumber,
    required this.finderName,
    required this.location,
    required this.dateReported,
    required this.isResolved,
    this.resolvedDate,
  });

  factory LostAndFoundItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return LostAndFoundItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'lost',
      imageUrl: data['imageUrl'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      finderName: data['finderName'] ?? '',
      location: data['location'] ?? '',
      dateReported: (data['dateReported'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: data['isResolved'] ?? false,
      resolvedDate: (data['resolvedDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'contactNumber': contactNumber,
      'finderName': finderName,
      'location': location,
      'dateReported': Timestamp.fromDate(dateReported),
      'isResolved': isResolved,
      'resolvedDate': resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
    };
  }
}

// Categories for Lost & Found
class LostAndFoundCategories {
  static const List<String> categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Accessories',
    'Documents',
    'Keys',
    'Sports Equipment',
    'Other',
  ];
}
