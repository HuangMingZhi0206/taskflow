// SQLite-based Group Service
import '../models/group_model.dart';
import '../database/database_helper.dart';

class GroupService {
  static final GroupService instance = GroupService._init();

  GroupService._init();

  // Create a new group
  Future<String> createGroup({
    required String groupName,
    required String description,
    required String createdBy,
    required String category,
    String? meetingLink,
    DateTime? deadline,
  }) async {
    final groupId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await DatabaseHelper.instance.database.then((db) => db.insert(
          'group_activities',
          {
            'id': groupId,
            'group_name': groupName,
            'description': description,
            'category': category,
            'created_by': createdBy,
            'created_at': now,
            'deadline': deadline?.toIso8601String(),
            'status': 'active',
            'meeting_link': meetingLink,
          },
        ));

    // Add creator as member
    await joinGroup(groupId: groupId, userId: createdBy, role: 'leader');

    return groupId;
  }

  // Get all groups (for discover tab)
  Future<List<GroupModel>> getAllGroups() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'group_activities',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'created_at DESC',
    );

    List<GroupModel> groups = [];
    for (var map in results) {
      final memberIds = await _getGroupMemberIds(map['id'] as String);
      groups.add(GroupModel.fromMap({...map, 'member_ids': memberIds}));
    }

    return groups;
  }

  // Get user's groups
  Future<List<GroupModel>> getUserGroups(String userId) async {
    final db = await DatabaseHelper.instance.database;

    // Get groups where user is a member
    final results = await db.rawQuery('''
      SELECT ga.* FROM group_activities ga
      INNER JOIN group_members gm ON ga.id = gm.group_id
      WHERE gm.user_id = ? AND ga.status = ?
      ORDER BY ga.created_at DESC
    ''', [userId, 'active']);

    List<GroupModel> groups = [];
    for (var map in results) {
      final memberIds = await _getGroupMemberIds(map['id'] as String);
      groups.add(GroupModel.fromMap({...map, 'member_ids': memberIds}));
    }

    return groups;
  }

  // Join a group
  Future<void> joinGroup({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    final db = await DatabaseHelper.instance.database;
    final memberId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('group_members', {
      'id': memberId,
      'group_id': groupId,
      'user_id': userId,
      'role': role,
      'joined_at': now,
    });
  }

  // Leave a group
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'group_members',
      where: 'group_id = ? AND user_id = ?',
      whereArgs: [groupId, userId],
    );
  }

  // Get group by ID
  Future<GroupModel?> getGroupById(String groupId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'group_activities',
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (results.isEmpty) return null;

    final memberIds = await _getGroupMemberIds(groupId);
    return GroupModel.fromMap({...results.first, 'member_ids': memberIds});
  }

  // Update group
  Future<void> updateGroup(String groupId, Map<String, dynamic> updates) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'group_activities',
      updates,
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }

  // Delete group
  Future<void> deleteGroup(String groupId) async {
    final db = await DatabaseHelper.instance.database;

    // Delete members first (cascade should handle this, but being explicit)
    await db.delete('group_members', where: 'group_id = ?', whereArgs: [groupId]);

    // Delete group
    await db.delete('group_activities', where: 'id = ?', whereArgs: [groupId]);
  }

  // Helper: Get member IDs for a group
  Future<List<String>> _getGroupMemberIds(String groupId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'group_members',
      columns: ['user_id'],
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    return results.map((r) => r['user_id'] as String).toList();
  }

  // Add member to group (alias for joinGroup)
  Future<void> addMemberToGroup(String groupId, String userId) async {
    await joinGroup(groupId: groupId, userId: userId);
  }

  // Remove member from group (alias for leaveGroup)
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    await leaveGroup(groupId: groupId, userId: userId);
  }

  // Group task methods (if needed)
  Future<String> createGroupTask(GroupTaskModel task) async {
    throw UnimplementedError('Group tasks not yet implemented');
  }

  Future<List<GroupTaskModel>> getGroupTasks(String groupId) async {
    throw UnimplementedError('Group tasks not yet implemented');
  }

  Future<void> updateGroupTaskStatus(String taskId, String status) async {
    throw UnimplementedError('Group tasks not yet implemented');
  }

  Future<void> deleteGroupTask(String taskId) async {
    throw UnimplementedError('Group tasks not yet implemented');
  }
}

