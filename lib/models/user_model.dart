// Firebase disabled - using SQLite only
// import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String? studentId;
  final String email;
  final String role; // 'manager', 'staff', 'student'
  final String? avatarUrl;
  final String? position;
  final String? contactNumber;
  final String? major;
  final int? semester;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.studentId,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.position,
    this.contactNumber,
    this.major,
    this.semester,
    required this.createdAt,
  });

  // Convert to Map (for compatibility with existing code)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'email': email,
      'avatar_path': avatarUrl,
      'major': major,
      'semester': semester,
      'contact_number': contactNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

