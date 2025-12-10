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

/// Class Schedule - Recurring class times or one-time events
class ClassScheduleModel {
  final String id;
  final String? courseId; // Nullable for general events
  final String userId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? courseName; // Acts as "Title" for general events
  final String? color;
  final bool isActive;
  final String type; // 'course', 'general', or 'task'
  final DateTime?
  specificDate; // For one-time events (tasks), null for recurring

  ClassScheduleModel({
    required this.id,
    this.courseId,
    required this.userId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.courseName,
    this.color,
    this.isActive = true,
    this.type = 'course',
    this.specificDate,
  });

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
      'course_name': courseName,
      'color': color,
      'is_active': isActive ? 1 : 0,
      'type': type,
      'specific_date': specificDate?.toIso8601String(),
    };
  }

  factory ClassScheduleModel.fromMap(Map<String, dynamic> map) {
    // Convert day number to day name
    final dayNumber = map['day_of_week'];
    String dayName = 'monday';

    if (dayNumber is int) {
      const dayNames = [
        '',
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];
      if (dayNumber >= 1 && dayNumber <= 7) {
        dayName = dayNames[dayNumber];
      }
    } else if (dayNumber is String) {
      dayName = dayNumber.toLowerCase();
    }

    // Smart time handling for tasks
    String startTimeStr = map['start_time']?.toString() ?? '00:00';
    String endTimeStr = map['end_time']?.toString() ?? '00:00';

    // If it's a task with midnight time (00:00 or 12:00 AM), default to 9:00 AM
    final isTask = map['type']?.toString() == 'task';
    final hasSpecificDate = map['specific_date'] != null;

    if (isTask && hasSpecificDate) {
      // Check if time is midnight/unspecified
      if (startTimeStr == '00:00' ||
          startTimeStr == '0:00' ||
          startTimeStr.contains('12:00 AM')) {
        startTimeStr = '9:00 AM';
        endTimeStr = '10:00 AM';
      }
    }

    return ClassScheduleModel(
      id: map['id']?.toString() ?? '',
      courseId: map['course_id']?.toString(), // Nullable
      userId: map['user_id']?.toString() ?? '',
      dayOfWeek: dayName,
      startTime: startTimeStr,
      endTime: endTimeStr,
      room: map['room']?.toString(),
      courseName:
          map['course_name']?.toString() ??
          map['title']?.toString(), // Fallback to title
      color: map['color']?.toString(),
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      type: map['type']?.toString() ?? 'course',
      specificDate: map['specific_date'] != null
          ? DateTime.tryParse(map['specific_date'].toString())
          : null,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'task_id': taskId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'session_type': sessionType,
      'notes': notes,
    };
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      courseId: map['course_id']?.toString(),
      taskId: map['task_id']?.toString(),
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      durationMinutes: map['duration_minutes'] ?? 0,
      sessionType: map['session_type'] ?? 'pomodoro',
      notes: map['notes']?.toString(),
    );
  }
}
