// Firebase disabled - using SQLite only
// import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? semester;
  final int? credits;
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
    this.semester,
    this.credits,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_code': courseCode,
      'course_name': courseName,
      'lecturer': instructor,
      'color': color,
      'room': room,
      'description': description,
      'semester': semester,
      'credits': credits,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      courseCode: map['course_code']?.toString() ?? '',
      courseName: map['course_name']?.toString() ?? '',
      instructor: map['lecturer']?.toString(),
      color: map['color']?.toString() ?? '3b82f6',
      room: map['room']?.toString(),
      description: map['description']?.toString(),
      semester: map['semester']?.toString(),
      credits: map['credits'] is int
          ? map['credits']
          : (int.tryParse(map['credits']?.toString() ?? '')),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
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

  // Firebase disabled - fromFirestore method commented out
  /*
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
  */

  // Firebase disabled - toFirestore method commented out
  /*
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
  */

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'user_id': userId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ClassScheduleModel.fromMap(Map<String, dynamic> map) {
    // Convert day number to day name
    final dayNumber = map['day_of_week'];
    String dayName = 'monday';

    if (dayNumber is int) {
      const dayNames = ['', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      if (dayNumber >= 1 && dayNumber <= 7) {
        dayName = dayNames[dayNumber];
      }
    } else if (dayNumber is String) {
      dayName = dayNumber.toLowerCase();
    }

    return ClassScheduleModel(
      id: map['id']?.toString() ?? '',
      courseId: map['course_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      dayOfWeek: dayName,
      startTime: map['start_time']?.toString() ?? '00:00',
      endTime: map['end_time']?.toString() ?? '00:00',
      room: map['room']?.toString(),
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
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

  // Firebase disabled - fromFirestore method commented out
  /*
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
  */

  // Firebase disabled - toFirestore method commented out
  /*
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
  */
}

