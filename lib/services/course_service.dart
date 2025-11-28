// SQLite-based Course Service
import '../models/course_model.dart';
import '../database/database_helper.dart';

class CourseService {
  static final CourseService instance = CourseService._init();

  CourseService._init();

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
      final db = await DatabaseHelper.instance.database;
      final courseId = DateTime.now().millisecondsSinceEpoch.toString();

      print('Creating course with userId: $userId (type: ${userId.runtimeType})');

      await db.insert('courses', {
        'id': courseId,
        'user_id': userId.toString(), // Ensure it's a string
        'course_code': courseCode.toString(),
        'course_name': courseName.toString(),
        'lecturer': instructor?.toString(),
        'room': room?.toString(),
        'day_of_week': 0, // Default integer
        'start_time': '00:00', // Default string
        'end_time': '00:00', // Default string
        'color': (color ?? '3b82f6').toString(),
        'semester': null,
        'credits': null,
      });

      print('Course created successfully with ID: $courseId');
      return courseId;
    } catch (e, stackTrace) {
      print('Error creating course: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get all courses for a user
  Future<List<CourseModel>> getUserCourses(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'courses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'course_code ASC',
    );

    return results.map((map) => CourseModel.fromMap(map)).toList();
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );

    if (results.isEmpty) return null;
    return CourseModel.fromMap(results.first);
  }

  // Update course
  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'courses',
      updates,
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
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
    final db = await DatabaseHelper.instance.database;

    // Get the course details
    final course = await getCourseById(courseId);
    if (course == null) {
      throw Exception('Course not found');
    }

    // Create a new schedule entry (separate row in courses table)
    final scheduleId = DateTime.now().millisecondsSinceEpoch.toString();

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

    await db.insert('courses', {
      'id': scheduleId,
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
    });

    return scheduleId;
  }

  // Get user's class schedules
  Future<List<ClassScheduleModel>> getUserSchedules(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'courses',
      where: 'user_id = ? AND day_of_week > 0',
      whereArgs: [userId],
      orderBy: 'day_of_week ASC, start_time ASC',
    );

    return results.map((map) => ClassScheduleModel.fromMap(map)).toList();
  }

  // Delete class schedule
  Future<void> deleteClassSchedule(String scheduleId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }
}

