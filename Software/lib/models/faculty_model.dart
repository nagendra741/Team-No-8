import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyModel {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String phone;
  final String office;
  final List<String> specialization;
  final String? imageUrl;
  final String experience;
  final String qualification;
  final bool isAvailable;
  final String officeHours;
  final DateTime createdAt;

  FacultyModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    required this.office,
    required this.specialization,
    this.imageUrl,
    required this.experience,
    required this.qualification,
    required this.isAvailable,
    required this.officeHours,
    required this.createdAt,
  });

  factory FacultyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return FacultyModel(
      id: doc.id,
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      department: data['department'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      office: data['office'] ?? '',
      specialization: List<String>.from(data['specialization'] ?? []),
      imageUrl: data['imageUrl'],
      experience: data['experience'] ?? '',
      qualification: data['qualification'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      officeHours: data['officeHours'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FacultyModel copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? email,
    String? phone,
    String? office,
    List<String>? specialization,
    String? imageUrl,
    String? experience,
    String? qualification,
    bool? isAvailable,
    String? officeHours,
    DateTime? createdAt,
  }) {
    return FacultyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      office: office ?? this.office,
      specialization: specialization ?? this.specialization,
      imageUrl: imageUrl ?? this.imageUrl,
      experience: experience ?? this.experience,
      qualification: qualification ?? this.qualification,
      isAvailable: isAvailable ?? this.isAvailable,
      officeHours: officeHours ?? this.officeHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get shortName {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return name;
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (parts.isNotEmpty) {
      return parts[0][0];
    }
    return 'F';
  }

  String get specializationText {
    if (specialization.isEmpty) return 'General';
    if (specialization.length == 1) return specialization.first;
    if (specialization.length <= 3) return specialization.join(', ');
    return '${specialization.take(2).join(', ')} +${specialization.length - 2} more';
  }

  String get availabilityStatus {
    return isAvailable ? 'Available' : 'Busy';
  }

  String get contactInfo {
    return '$email\n$phone';
  }
}

// Department Categories
class Departments {
  static const List<String> all = [
    'Computer Science & Engineering',
    'Electronics & Communication Engineering',
    'Electrical & Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Information Technology',
    'Aerospace Engineering',
    'Automobile Engineering',
    'Mathematics',
    'Physics',
    'Chemistry',
    'English',
    'Management Studies',
    'Other',
  ];

  static String getShortName(String department) {
    switch (department) {
      case 'Computer Science & Engineering':
        return 'CSE';
      case 'Electronics & Communication Engineering':
        return 'ECE';
      case 'Electrical & Electronics Engineering':
        return 'EEE';
      case 'Mechanical Engineering':
        return 'MECH';
      case 'Civil Engineering':
        return 'CIVIL';
      case 'Chemical Engineering':
        return 'CHEM';
      case 'Information Technology':
        return 'IT';
      case 'Aerospace Engineering':
        return 'AERO';
      case 'Automobile Engineering':
        return 'AUTO';
      case 'Management Studies':
        return 'MBA';
      default:
        return department.split(' ').map((word) => word[0]).join('').toUpperCase();
    }
  }
}

// Designation Categories
class Designations {
  static const List<String> all = [
    'Professor & Head',
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Lecturer',
    'Senior Lecturer',
    'Guest Faculty',
    'Visiting Professor',
  ];

  static int getHierarchyLevel(String designation) {
    switch (designation) {
      case 'Professor & Head':
        return 1;
      case 'Professor':
        return 2;
      case 'Associate Professor':
        return 3;
      case 'Assistant Professor':
        return 4;
      case 'Senior Lecturer':
        return 5;
      case 'Lecturer':
        return 6;
      case 'Guest Faculty':
        return 7;
      case 'Visiting Professor':
        return 8;
      default:
        return 9;
    }
  }
}
