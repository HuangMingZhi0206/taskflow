import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseService {
  static final CourseService instance = CourseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CourseService._init();

  CollectionReference get _courses => _firestore.collection('courses');

  // Create a new course
  Future<String> createCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    String? instructor,
    String? room,
    String? description,
    String? color,
  }) async {
    try {
      DocumentReference doc = await _courses.add({
        'user_id': userId,
        'course_code': courseCode,
        'course_name': courseName,
        'lecturer': instructor,
        'room': room,
        'day_of_week': 0,
        'start_time': '00:00',
        'end_time': '00:00',
        'color': color ?? '3b82f6',
        'semester': null,
        'credits': null,
      });
      await doc.update({'id': doc.id});
      return doc.id;
    } catch (e) {
      debugPrint('Error creating course: $e');
      rethrow;
    }
  }

  // Get all courses for a user
  Future<List<CourseModel>> getUserCourses(String userId) async {
    QuerySnapshot snapshot = await _courses
        .where('user_id', isEqualTo: userId)
        .where('day_of_week', isEqualTo: 0)
        .get();

    final courses = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return CourseModel.fromMap(data);
    }).toList();

    // Sort by course code
    courses.sort((a, b) => a.courseCode.compareTo(b.courseCode));
    return courses;
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    DocumentSnapshot doc = await _courses.doc(courseId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return CourseModel.fromMap(data);
    }
    return null;
  }

  // Update course
  Future<void> updateCourse(
    String courseId,
    Map<String, dynamic> updates,
  ) async {
    await _courses.doc(courseId).update(updates);
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    await _courses.doc(courseId).delete();
  }

  // Add general schedule (non-course event)
  Future<String> addGeneralSchedule({
    required String userId,
    required String title,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    String? color,
    String? description,
  }) async {
    // Map day name to number
    final dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    final dayNumber = dayMap[dayOfWeek] ?? 1;

    DocumentReference doc = await _courses.add({
      'user_id': userId,
      'course_name': title, // Use course_name field for title compatibility
      'title': title,
      'day_of_week': dayNumber,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'color': color ?? '64748b', // Default gray
      'description': description,
      'type': 'general',
      'is_active': 1,
    });
    await doc.update({'id': doc.id});
    return doc.id;
  }

  // Add class schedule (creates a new course entry with schedule)
  Future<String> addClassSchedule({
    required String userId,
    required String courseId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    // Get the course details
    final course = await getCourseById(courseId);
    if (course == null) {
      throw Exception('Course not found');
    }

    // Map day name to number
    final dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final dayNumber = dayMap[dayOfWeek] ?? 1;

    DocumentReference doc = await _courses.add({
      'course_id': courseId,
      'user_id': userId,
      'course_code': course.courseCode,
      'course_name': course.courseName,
      'lecturer': course.instructor,
      'room': room ?? course.room,
      'day_of_week': dayNumber,
      'start_time': startTime,
      'end_time': endTime,
      'color': course.color,
      'semester': course.semester,
      'credits': course.credits,
      'type': 'course',
      'is_active': 1,
    });
    await doc.update({'id': doc.id});

    return doc.id;
  }

  // Get user's class schedules
  Future<List<ClassScheduleModel>> getUserSchedules(String userId) async {
    // Fetch all records for the user to avoid composite index requirements
    QuerySnapshot snapshot = await _courses
        .where('user_id', isEqualTo: userId)
        .get();

    final allSchedules = snapshot.docs
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          // Include if:
          // 1. Has day_of_week > 0 (recurring schedule), OR
          // 2. Has specific_date (one-time event/task)
          final dayOfWeek = data['day_of_week'];
          final hasSpecificDate = data['specific_date'] != null;

          if (dayOfWeek == null ||
              (dayOfWeek is int && dayOfWeek == 0 && !hasSpecificDate)) {
            return null; // Skip courses without schedule
          }

          try {
            return ClassScheduleModel.fromMap(data);
          } catch (e) {
            debugPrint('Error parsing schedule: $e');
            return null;
          }
        })
        .whereType<ClassScheduleModel>()
        .toList();

    // Sort manually since we removed the DB sort
    allSchedules.sort((a, b) {
      // If both have specific dates, sort by date
      if (a.specificDate != null && b.specificDate != null) {
        final dateCompare = a.specificDate!.compareTo(b.specificDate!);
        if (dateCompare != 0) return dateCompare;
        return _compareTime(a.startTime, b.startTime);
      }

      // Specific dates come before recurring events
      if (a.specificDate != null) return -1;
      if (b.specificDate != null) return 1;

      // Both are recurring, sort by day then time
      if (a.dayIndex != b.dayIndex) {
        return a.dayIndex.compareTo(b.dayIndex);
      }
      return _compareTime(a.startTime, b.startTime);
    });

    return allSchedules;
  }

  int _compareTime(String timeA, String timeB) {
    try {
      final a = _parseTimeToMinutes(timeA);
      final b = _parseTimeToMinutes(timeB);
      return a.compareTo(b);
    } catch (e) {
      return 0;
    }
  }

  int _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final isPM = parts[1].toUpperCase() == 'PM';
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  // Delete class schedule
  Future<void> deleteClassSchedule(String scheduleId) async {
    await _courses.doc(scheduleId).delete();
  }
}
