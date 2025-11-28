import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseService {
  static final CourseService instance = CourseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CourseService._init();

  // Create a new course
  Future<String> createCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    String? instructor,
    String color = '3b82f6',
    String? room,
    String? description,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('courses').add({
        'userId': userId,
        'courseCode': courseCode,
        'courseName': courseName,
        'instructor': instructor,
        'color': color,
        'room': room,
        'description': description,
        'createdAt': Timestamp.now(),
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  // Get all courses for a user
  Future<List<CourseModel>> getUserCourses(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courses')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('courseCode')
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  // Update course
  Future<void> updateCourse({
    required String courseId,
    String? courseCode,
    String? courseName,
    String? instructor,
    String? color,
    String? room,
    String? description,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (courseCode != null) updates['courseCode'] = courseCode;
      if (courseName != null) updates['courseName'] = courseName;
      if (instructor != null) updates['instructor'] = instructor;
      if (color != null) updates['color'] = color;
      if (room != null) updates['room'] = room;
      if (description != null) updates['description'] = description;

      if (updates.isNotEmpty) {
        await _firestore.collection('courses').doc(courseId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  // Delete/deactivate course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('courses').doc(courseId).get();
      if (!doc.exists) return null;
      return CourseModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }

  // ===== Class Schedule Management =====

  // Add class schedule
  Future<String> addClassSchedule({
    required String courseId,
    required String userId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('class_schedules').add({
        'courseId': courseId,
        'userId': userId,
        'dayOfWeek': dayOfWeek.toLowerCase(),
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add class schedule: $e');
    }
  }

  // Get all schedules for a user
  Future<List<ClassScheduleModel>> getUserSchedules(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('class_schedules')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ClassScheduleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting schedules: $e');
      return [];
    }
  }

  // Get schedules for a specific course
  Future<List<ClassScheduleModel>> getCourseSchedules(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('class_schedules')
          .where('courseId', isEqualTo: courseId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ClassScheduleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting course schedules: $e');
      return [];
    }
  }

  // Delete class schedule
  Future<void> deleteClassSchedule(String scheduleId) async {
    try {
      await _firestore.collection('class_schedules').doc(scheduleId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // ===== Study Session Management =====

  // Start a study session
  Future<String> startStudySession({
    required String userId,
    String? courseId,
    String? taskId,
    int durationMinutes = 25,
    String sessionType = 'pomodoro',
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('study_sessions').add({
        'userId': userId,
        'courseId': courseId,
        'taskId': taskId,
        'startTime': Timestamp.now(),
        'endTime': null,
        'durationMinutes': durationMinutes,
        'sessionType': sessionType,
        'notes': null,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start study session: $e');
    }
  }

  // End a study session
  Future<void> endStudySession(String sessionId, {String? notes}) async {
    try {
      Map<String, dynamic> updates = {
        'endTime': Timestamp.now(),
      };
      if (notes != null) {
        updates['notes'] = notes;
      }
      await _firestore.collection('study_sessions').doc(sessionId).update(updates);
    } catch (e) {
      throw Exception('Failed to end study session: $e');
    }
  }

  // Get study sessions for a user
  Future<List<StudySessionModel>> getUserStudySessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);

      if (startDate != null) {
        query = query.where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('startTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      QuerySnapshot snapshot = await query.limit(100).get();

      return snapshot.docs
          .map((doc) => StudySessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting study sessions: $e');
      return [];
    }
  }

  // Get total study time for a course
  Future<int> getCourseStudyTime(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('study_sessions')
          .where('courseId', isEqualTo: courseId)
          .where('endTime', isNull: false)
          .get();

      int totalMinutes = 0;
      for (var doc in snapshot.docs) {
        StudySessionModel session = StudySessionModel.fromFirestore(doc);
        if (session.endTime != null) {
          totalMinutes += session.endTime!.difference(session.startTime).inMinutes;
        }
      }
      return totalMinutes;
    } catch (e) {
      print('Error getting course study time: $e');
      return 0;
    }
  }
}

