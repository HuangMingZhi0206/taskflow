import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._init();

  // ==================== TASK OPERATIONS ====================

  // Create task
  Future<String> createTask(TaskModel task) async {
    try {
      DocumentReference docRef = await _firestore.collection('tasks').add(task.toFirestore());

      // Create activity log
      await _createActivityLog(
        taskId: docRef.id,
        userId: task.createdBy,
        actionType: 'created',
        newValue: 'Task created',
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  // Get tasks by assignee
  Future<List<TaskModel>> getTasksByAssignee(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('assigneeId', isEqualTo: userId)
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tasks by assignee: $e');
      return [];
    }
  }

  // Get tasks by creator
  Future<List<TaskModel>> getTasksByCreator(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tasks by creator: $e');
      return [];
    }
  }

  // Get tasks by status
  Future<List<TaskModel>> getTasksByStatus(String status, String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('assigneeId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tasks by status: $e');
      return [];
    }
  }

  // Update task
  Future<void> updateTask({
    required String taskId,
    required String userId,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? deadline,
    double? estimatedHours,
    String? category,
    List<String>? tagIds,
  }) async {
    try {
      // Get current task for activity log
      TaskModel? currentTask = await getTaskById(taskId);

      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (priority != null) updates['priority'] = priority;
      if (status != null) updates['status'] = status;
      if (deadline != null) updates['deadline'] = Timestamp.fromDate(deadline);
      if (estimatedHours != null) updates['estimatedHours'] = estimatedHours;
      if (category != null) updates['category'] = category;
      if (tagIds != null) updates['tagIds'] = tagIds;

      await _firestore.collection('tasks').doc(taskId).update(updates);

      // Create activity logs for each change
      if (currentTask != null) {
        if (status != null && status != currentTask.status) {
          await _createActivityLog(
            taskId: taskId,
            userId: userId,
            actionType: 'status_changed',
            fieldName: 'status',
            oldValue: currentTask.status,
            newValue: status,
          );
        }
        if (priority != null && priority != currentTask.priority) {
          await _createActivityLog(
            taskId: taskId,
            userId: userId,
            actionType: 'priority_changed',
            fieldName: 'priority',
            oldValue: currentTask.priority,
            newValue: priority,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      // Delete subcollections first
      await _deleteSubcollection(taskId, 'comments');
      await _deleteSubcollection(taskId, 'subtasks');
      await _deleteSubcollection(taskId, 'activity');

      // Delete the task
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Helper: Delete subcollection
  Future<void> _deleteSubcollection(String taskId, String subcollection) async {
    QuerySnapshot snapshot = await _firestore
        .collection('tasks')
        .doc(taskId)
        .collection(subcollection)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ==================== SUBTASK OPERATIONS ====================

  // Add subtask
  Future<String> addSubtask(SubtaskModel subtask) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tasks')
          .doc(subtask.taskId)
          .collection('subtasks')
          .add(subtask.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add subtask: $e');
    }
  }

  // Get subtasks by task
  Future<List<SubtaskModel>> getSubtasksByTask(String taskId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => SubtaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting subtasks: $e');
      return [];
    }
  }

  // Update subtask
  Future<void> updateSubtask({
    required String taskId,
    required String subtaskId,
    String? title,
    bool? isCompleted,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (isCompleted != null) updates['isCompleted'] = isCompleted;

      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subtaskId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  // Delete subtask
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subtaskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete subtask: $e');
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  // Add comment
  Future<String> addComment(CommentModel comment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tasks')
          .doc(comment.taskId)
          .collection('comments')
          .add(comment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments by task
  Future<List<CommentModel>> getCommentsByTask(String taskId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .orderBy('reportedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Delete comment
  Future<void> deleteComment(String taskId, String commentId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // ==================== TAG OPERATIONS ====================

  // Create tag
  Future<String> createTag(TagModel tag) async {
    try {
      DocumentReference docRef = await _firestore.collection('tags').add(tag.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  // Get all tags
  Future<List<TagModel>> getAllTags() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tags')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => TagModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }

  // Get tag by ID
  Future<TagModel?> getTagById(String tagId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('tags').doc(tagId).get();
      if (!doc.exists) return null;
      return TagModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting tag: $e');
      return null;
    }
  }

  // Update tag
  Future<void> updateTag({
    required String tagId,
    String? name,
    String? color,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (color != null) updates['color'] = color;

      await _firestore.collection('tags').doc(tagId).update(updates);
    } catch (e) {
      throw Exception('Failed to update tag: $e');
    }
  }

  // Delete tag
  Future<void> deleteTag(String tagId) async {
    try {
      await _firestore.collection('tags').doc(tagId).delete();
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  // Create notification
  Future<String> createNotification(NotificationModel notification) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(notification.userId)
          .collection('notifications')
          .add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get notifications by user
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ==================== ACTIVITY LOG ====================

  Future<void> _createActivityLog({
    required String taskId,
    required String userId,
    required String actionType,
    String? fieldName,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('activity')
          .add({
        'userId': userId,
        'actionType': actionType,
        'fieldName': fieldName,
        'oldValue': oldValue,
        'newValue': newValue,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating activity log: $e');
    }
  }

  // Get activity log
  Future<List<Map<String, dynamic>>> getActivityLog(String taskId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('activity')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'user_id': data['userId'],
          'action_type': data['actionType'],
          'field_name': data['fieldName'],
          'old_value': data['oldValue'],
          'new_value': data['newValue'],
          'created_at': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      print('Error getting activity log: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  // Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics(String userId) async {
    try {
      QuerySnapshot allTasks = await _firestore
          .collection('tasks')
          .where('assigneeId', isEqualTo: userId)
          .get();

      int total = allTasks.docs.length;
      int todo = 0;
      int inProgress = 0;
      int done = 0;
      double totalEstimatedHours = 0;

      for (var doc in allTasks.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'todo';

        if (status == 'todo') todo++;
        else if (status == 'in-progress') inProgress++;
        else if (status == 'done') done++;

        totalEstimatedHours += (data['estimatedHours'] ?? 0.0);
      }

      return {
        'total': total,
        'todo': todo,
        'in_progress': inProgress,
        'done': done,
        'completion_rate': total > 0 ? (done / total * 100).toStringAsFixed(1) : '0.0',
        'total_estimated_hours': totalEstimatedHours,
      };
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

  // ==================== INITIAL DATA SETUP ====================

  // Initialize default tags (call this after first user registration)
  Future<void> initializeDefaultTags() async {
    try {
      // Check if tags already exist
      QuerySnapshot existingTags = await _firestore.collection('tags').limit(1).get();
      if (existingTags.docs.isNotEmpty) {
        return; // Tags already initialized
      }

      // Create default academic tags
      List<Map<String, String>> defaultTags = [
        {'name': 'Assignment', 'color': '3b82f6'},
        {'name': 'Exam', 'color': 'ef4444'},
        {'name': 'Project', 'color': '8b5cf6'},
        {'name': 'Reading', 'color': '10b981'},
        {'name': 'Study Group', 'color': 'f59e0b'},
        {'name': 'Lab', 'color': '06b6d4'},
        {'name': 'Research', 'color': 'ec4899'},
        {'name': 'Presentation', 'color': '14b8a6'},
      ];

      for (var tag in defaultTags) {
        await _firestore.collection('tags').add(tag);
      }

      print('Default tags initialized successfully');
    } catch (e) {
      print('Error initializing default tags: $e');
    }
  }
}

