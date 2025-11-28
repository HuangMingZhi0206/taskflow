import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

class GroupService {
  static final GroupService instance = GroupService._init();

  GroupService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== GROUP OPERATIONS ====================

  /// Create a new group
  Future<String> createGroup({
    required String groupName,
    required String description,
    required String category,
    required String createdBy,
    String? meetingLink,
    DateTime? deadline,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('groups').add({
        'groupName': groupName,
        'description': description,
        'category': category,
        'createdBy': createdBy,
        'createdAt': Timestamp.now(),
        'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
        'status': 'active',
        'meetingLink': meetingLink,
        'memberIds': [createdBy], // Creator is first member
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  /// Get all groups where user is a member
  Future<List<GroupModel>> getUserGroups(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user groups: $e');
      return [];
    }
  }

  /// Get a specific group by ID
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting group: $e');
      return null;
    }
  }

  /// Update group details
  Future<void> updateGroup(String groupId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('groups').doc(groupId).update(updates);
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete all tasks associated with the group
      QuerySnapshot tasks = await _firestore
          .collection('group_tasks')
          .where('groupId', isEqualTo: groupId)
          .get();

      for (var doc in tasks.docs) {
        await doc.reference.delete();
      }

      // Delete the group
      await _firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  /// Add member to group
  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  // ==================== GROUP TASK OPERATIONS ====================

  /// Create a group task
  Future<String> createGroupTask({
    required String groupId,
    required String title,
    required String description,
    required DateTime deadline,
    required String createdBy,
    String? assignedToId,
    String? assignedToName,
    String priority = 'medium',
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('group_tasks').add({
        'groupId': groupId,
        'title': title,
        'description': description,
        'assignedToId': assignedToId,
        'assignedToName': assignedToName,
        'priority': priority,
        'status': 'todo',
        'deadline': Timestamp.fromDate(deadline),
        'createdAt': Timestamp.now(),
        'createdBy': createdBy,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group task: $e');
    }
  }

  /// Get tasks for a group
  Future<List<GroupTaskModel>> getGroupTasks(String groupId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('group_tasks')
          .where('groupId', isEqualTo: groupId)
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => GroupTaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting group tasks: $e');
      return [];
    }
  }

  /// Update group task status
  Future<void> updateGroupTaskStatus(String taskId, String status) async {
    try {
      await _firestore.collection('group_tasks').doc(taskId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  /// Update group task
  Future<void> updateGroupTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('group_tasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete group task
  Future<void> deleteGroupTask(String taskId) async {
    try {
      await _firestore.collection('group_tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Get tasks assigned to a specific user in a group
  Future<List<GroupTaskModel>> getUserGroupTasks(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('group_tasks')
          .where('assignedToId', isEqualTo: userId)
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => GroupTaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user group tasks: $e');
      return [];
    }
  }
}

