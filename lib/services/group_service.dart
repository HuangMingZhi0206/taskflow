// Firebase disabled - SQLite only mode
// This is a stub file to prevent import errors

import '../models/group_model.dart';

class GroupService {
  static final GroupService instance = GroupService._init();

  GroupService._init();

  // All Firebase methods are disabled in SQLite-only mode
  // Use local database methods instead

  Future<String> createGroup({
    required String groupName,
    required String description,
    required String createdBy,
    required String category,
    String? meetingLink,
    DateTime? deadline,
  }) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<List<GroupModel>> getUserGroups(String userId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<GroupModel?> getGroupById(String groupId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> updates) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> deleteGroup(String groupId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> addMemberToGroup(String groupId, String userId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<String> createGroupTask(GroupTaskModel task) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<List<GroupTaskModel>> getGroupTasks(String groupId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> updateGroupTaskStatus(String taskId, String status) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<void> deleteGroupTask(String taskId) async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }

  Future<List<GroupModel>> getAllGroups() async {
    throw UnimplementedError('Firebase is disabled. Use SQLite database instead.');
  }
}

