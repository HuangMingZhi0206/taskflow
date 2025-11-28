/// Database Helper Wrapper
///
/// Unified interface for all database operations
/// Uses SQLite for local storage
library;

import 'sqlite_database_helper.dart';
import '../services/local_auth_service.dart';
import '../services/local_storage_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  final LocalAuthService _auth = LocalAuthService.instance;
  final SQLiteDatabaseHelper _db = SQLiteDatabaseHelper.instance;

  DatabaseHelper._init();

  // ==================== USER OPERATIONS ====================

  Future<Map<String, dynamic>?> loginUser(String emailOrStudentId, String password) async {
    try {
      return await _auth.loginUser(emailOrStudentId, password);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<int> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? studentId,
    String? major,
    int? semester,
    String? contactNumber,
  }) async {
    try {
      Map<String, dynamic>? user = await _auth.registerUser(
        name: name,
        email: email,
        password: password,
        studentId: studentId ?? '',
        major: major,
        semester: semester,
        contactNumber: contactNumber,
      );
      return user != null ? 1 : 0;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    return await registerUser(
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      password: user['password'] ?? '',
      role: 'student', // All users are students
      studentId: user['student_id'],
      major: user['major'],
      semester: user['semester'],
      contactNumber: user['contact_number'],
    );
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      return await _db.getUserById(userId);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByStudentId(String studentId) async {
    try {
      return await _db.getUserByStudentId(studentId);
    } catch (e) {
      print('Error getting user by student ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      return await _db.getUserByEmail(email);
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await _db.getAllUsers();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<int> updateUser({
    required String userId,
    String? name,
    String? avatarPath,
    String? major,
    int? semester,
    String? contactNumber,
  }) async {
    try {
      await _auth.updateUser(
        userId: userId,
        name: name,
        avatarUrl: avatarPath,
        major: major,
        semester: semester,
        contactNumber: contactNumber,
      );
      return 1;
    } catch (e) {
      print('Error updating user: $e');
      return 0;
    }
  }

  // ==================== TASK OPERATIONS ====================

  Future<int> insertTask(Map<String, dynamic> task) async {
    try {
      String taskId = await _db.createTask(task);
      return taskId.hashCode;
    } catch (e) {
      print('Error inserting task: $e');
      return 0;
    }
  }

  Future<String> createTask(Map<String, dynamic> task) async {
    try {
      return await _db.createTask(task);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    try {
      return await _db.getAllTasks();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(String userId) async {
    try {
      return await _db.getTasksByUserId(userId);
    } catch (e) {
      print('Error getting tasks by user: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTasksByAssignee(String userId) async {
    return await getTasksByUserId(userId);
  }

  Future<int> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      return await _db.updateTask(taskId, updates);
    } catch (e) {
      print('Error updating task: $e');
      return 0;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _db.updateTaskStatus(taskId, status);
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  Future<int> deleteTask(String taskId) async {
    try {
      return await _db.deleteTask(taskId);
    } catch (e) {
      print('Error deleting task: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    try {
      return await _db.getTaskById(taskId);
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  Future<void> addTaskTag(String taskId, String tagId) async {
    try {
      await _db.addTaskTag(taskId, tagId);
    } catch (e) {
      print('Error adding task tag: $e');
      rethrow;
    }
  }

  // ==================== SUBTASK OPERATIONS ====================

  Future<int> insertSubtask(Map<String, dynamic> subtask) async {
    try {
      String subtaskId = await _db.insertSubtask(subtask);
      return subtaskId.hashCode;
    } catch (e) {
      print('Error inserting subtask: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getSubtasksByTask(String taskId) async {
    try {
      return await _db.getSubtasksByTask(taskId);
    } catch (e) {
      print('Error getting subtasks: $e');
      return [];
    }
  }

  Future<int> updateSubtask(String taskId, String subtaskId, Map<String, dynamic> updates) async {
    try {
      return await _db.updateSubtask(subtaskId, updates);
    } catch (e) {
      print('Error updating subtask: $e');
      return 0;
    }
  }

  Future<int> deleteSubtask(String taskId, String subtaskId) async {
    try {
      return await _db.deleteSubtask(subtaskId);
    } catch (e) {
      print('Error deleting subtask: $e');
      return 0;
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  Future<int> insertComment(Map<String, dynamic> comment) async {
    try {
      String commentId = await _db.insertComment(comment);
      return commentId.hashCode;
    } catch (e) {
      print('Error inserting comment: $e');
      return 0;
    }
  }

  Future<void> addTaskComment(Map<String, dynamic> comment) async {
    await insertComment(comment);
  }

  Future<List<Map<String, dynamic>>> getCommentsByTask(String taskId) async {
    try {
      return await _db.getCommentsByTask(taskId);
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTaskComments(String taskId) async {
    return await getCommentsByTask(taskId);
  }

  Future<int> deleteComment(String taskId, String commentId) async {
    try {
      return await _db.deleteComment(commentId);
    } catch (e) {
      print('Error deleting comment: $e');
      return 0;
    }
  }

  // ==================== TAG OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getAllTags() async {
    try {
      return await _db.getAllTags();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }

  Future<int> insertTag(Map<String, dynamic> tag) async {
    try {
      String tagId = await _db.insertTag(tag);
      return tagId.hashCode;
    } catch (e) {
      print('Error inserting tag: $e');
      return 0;
    }
  }

  Future<int> linkTagToTask(String taskId, String tagId) async {
    try {
      await _db.addTaskTag(taskId, tagId);
      return 1;
    } catch (e) {
      print('Error linking tag: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getTagsByTask(String taskId) async {
    try {
      return await _db.getTagsByTask(taskId);
    } catch (e) {
      print('Error getting tags by task: $e');
      return [];
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  Future<int> createNotification(Map<String, dynamic> notification) async {
    try {
      String notificationId = await _db.createNotification(notification);
      return notificationId.hashCode;
    } catch (e) {
      print('Error creating notification: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationsByUser(String userId) async {
    try {
      return await _db.getNotificationsByUser(userId);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<int> markNotificationAsRead(String userId, String notificationId) async {
    try {
      return await _db.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      return 0;
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      return await _db.getUnreadNotificationCount(userId);
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ==================== ACTIVITY LOG ====================

  Future<List<Map<String, dynamic>>> getActivityLog(String taskId) async {
    try {
      return await _db.getActivityLog(taskId);
    } catch (e) {
      print('Error getting activity log: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getTaskStatistics(String userId) async {
    try {
      return await _db.getTaskStatistics(userId);
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'total': 0,
        'todo': 0,
        'in_progress': 0,
        'done': 0,
        'completion_rate': '0.0',
        'total_estimated_hours': 0.0,
      };
    }
  }

  // ==================== UTILITY ====================

  String? get currentUserId => _auth.currentUserId;

  Future<void> logout() async {
    await _auth.logout();
  }

  Future<bool> emailExists(String email) async {
    return await _auth.emailExists(email);
  }

  Future<bool> studentIdExists(String studentId) async {
    return await _auth.studentIdExists(studentId);
  }

  Future<dynamic> get database async {
    return _db.database;
  }
}

