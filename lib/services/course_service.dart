// Firebase disabled - SQLite only mode
// This is a stub file to prevent import errors

import '../models/course_model.dart';

class CourseService {
  static final CourseService instance = CourseService._init();

  CourseService._init();

  // All Firebase methods are disabled in SQLite-only mode
  // Use local database methods instead

  Future<String> createCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    String? instructor,
    String? room,
    String? description,
    String? color,
  }) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<List<CourseModel>> getUserCourses(String userId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> deleteCourse(String courseId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<String> addClassSchedule({
    required String userId,
    required String courseId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<List<ClassScheduleModel>> getUserSchedules(String userId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> deleteClassSchedule(String scheduleId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }
}

