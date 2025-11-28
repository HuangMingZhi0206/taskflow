import 'package:cloud_firestore/cloud_firestore.dart';

/// Course Model - Represents a university course/class
class CourseModel {
  final String id;
  final String userId; // Student who owns this course
  final String courseCode; // e.g., CS101, MATH202
  final String courseName; // e.g., Introduction to Programming
  final String? instructor;
  final String color; // Hex color code for visual distinction
  final String? room;
  final String? description;
  final DateTime createdAt;
  final bool isActive;

  CourseModel({
    required this.id,
    required this.userId,
    required this.courseCode,
    required this.courseName,
    this.instructor,
    this.color = '3b82f6', // Default blue
    this.room,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courseCode: data['courseCode'] ?? '',
      courseName: data['courseName'] ?? '',
      instructor: data['instructor'],
      color: data['color'] ?? '3b82f6',
      room: data['room'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseCode': courseCode,
      'courseName': courseName,
      'instructor': instructor,
      'color': color,
      'room': room,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_code': courseCode,
      'course_name': courseName,
      'instructor': instructor,
      'color': color,
      'room': room,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// Class Schedule - Recurring class times
class ClassScheduleModel {
  final String id;
  final String courseId;
  final String userId;
  final String dayOfWeek; // 'monday', 'tuesday', etc.
  final String startTime; // '09:00'
  final String endTime; // '10:30'
  final String? room;
  final bool isActive;

  ClassScheduleModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.isActive = true,
  });

  factory ClassScheduleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassScheduleModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      room: data['room'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'userId': userId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'isActive': isActive,
    };
  }

  int get dayIndex {
    const days = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };
    return days[dayOfWeek.toLowerCase()] ?? 1;
  }
}

/// Study Session - Pomodoro/timed study sessions
class StudySessionModel {
  final String id;
  final String userId;
  final String? courseId;
  final String? taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String sessionType; // 'pomodoro', 'deep-work', 'review'
  final String? notes;

  StudySessionModel({
    required this.id,
    required this.userId,
    this.courseId,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.sessionType = 'pomodoro',
    this.notes,
  });

  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudySessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'],
      taskId: data['taskId'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      durationMinutes: data['durationMinutes'] ?? 0,
      sessionType: data['sessionType'] ?? 'pomodoro',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'taskId': taskId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'sessionType': sessionType,
      'notes': notes,
    };
  }
}

