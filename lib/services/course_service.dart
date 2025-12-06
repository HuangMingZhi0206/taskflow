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
          // Handle potential integer/string mismatch for day_of_week here if needed
          // But strictly we only want items where day_of_week > 0
          if (data['day_of_week'] == null ||
              (data['day_of_week'] is int &&
                  (data['day_of_week'] as int) == 0)) {
            return null;
          }
          return ClassScheduleModel.fromMap(data);
        })
        .whereType<ClassScheduleModel>()
        .toList();

    // Sort manually since we removed the DB sort
    allSchedules.sort((a, b) {
      if (a.dayIndex != b.dayIndex) {
        return a.dayIndex.compareTo(b.dayIndex);
      }
      return a.startTime.compareTo(b.startTime);
    });

    return allSchedules;
  }

  // Delete class schedule
  Future<void> deleteClassSchedule(String scheduleId) async {
    await _courses.doc(scheduleId).delete();
  }
}
