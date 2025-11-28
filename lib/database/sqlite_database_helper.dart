/// SQLite Database Helper
///
/// Manages local SQLite database for TaskFlow app
/// All data stored locally on device

library;

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/local_storage_service.dart';

class SQLiteDatabaseHelper {
  static final SQLiteDatabaseHelper instance = SQLiteDatabaseHelper._init();
  static Database? _database;

  SQLiteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,  // Increased version to 3 to include courses table
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('📊 Upgrading database from version $oldVersion to $newVersion');

    // Upgrade from version 1 to 2: Add role and position columns
    if (oldVersion < 2) {
      try {
        // Add role column with default value
        await db.execute('ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT "student"');
        print('✓ Added role column to users table');
      } catch (e) {
        print('Column role might already exist: $e');
      }

      try {
        // Add position column (optional, for staff)
        await db.execute('ALTER TABLE users ADD COLUMN position TEXT');
        print('✓ Added position column to users table');
      } catch (e) {
        print('Column position might already exist: $e');
      }
    }

    // Upgrade from version 2 to 3: No schema changes, just version bump
    // All tables already exist in _createDB
    if (oldVersion < 3) {
      print('✓ Upgraded to version 3 (no schema changes needed)');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    print('📦 Creating database version $version with all tables...');

    // Users table - Support all user types
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'student',
        student_id TEXT UNIQUE,
        major TEXT,
        semester INTEGER,
        contact_number TEXT,
        avatar_url TEXT,
        position TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    print('✓ Created users table');

    // Tasks table - Personal tasks for students
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        user_id TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL,
        estimated_hours REAL,
        category TEXT,
        course_code TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✓ Created tasks table');

    // Courses table - Schedule courses
    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        course_code TEXT NOT NULL,
        course_name TEXT NOT NULL,
        lecturer TEXT,
        room TEXT,
        day_of_week INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        color TEXT NOT NULL,
        semester TEXT,
        credits INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✓ Created courses table');

    // Group Activities table
    await db.execute('''
      CREATE TABLE group_activities(
        id TEXT PRIMARY KEY,
        group_name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        deadline TEXT,
        status TEXT NOT NULL,
        meeting_link TEXT,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');
    print('✓ Created group_activities table');

    // Group Members table
    await db.execute('''
      CREATE TABLE group_members(
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES group_activities (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print('✓ Created group_members table');

    // Study Sessions table - Pomodoro tracking
    await db.execute('''
      CREATE TABLE study_sessions(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        task_id TEXT,
        course_code TEXT,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        duration_minutes INTEGER,
        session_type TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (task_id) REFERENCES tasks (id)
      )
    ''');
    print('✓ Created study_sessions table');

    // Subtasks table
    await db.execute('''
      CREATE TABLE subtasks(
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
    print('✓ Created subtasks table');

    // Comments table
    await db.execute('''
      CREATE TABLE comments(
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        comment_text TEXT NOT NULL,
        reported_by TEXT NOT NULL,
        reported_at TEXT NOT NULL,
        comment_type TEXT NOT NULL,
        attachment_url TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (reported_by) REFERENCES users (id)
      )
    ''');
    print('✓ Created comments table');

    // Tags table
    await db.execute('''
      CREATE TABLE tags(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL
      )
    ''');
    print('✓ Created tags table');

    // Task_Tags junction table
    await db.execute('''
      CREATE TABLE task_tags(
        task_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');
    print('✓ Created task_tags table');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        task_id TEXT,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
    print('✓ Created notifications table');

    // Activity logs table
    await db.execute('''
      CREATE TABLE activity_logs(
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        action TEXT NOT NULL,
        performed_by TEXT NOT NULL,
        performed_by_name TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        details TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (performed_by) REFERENCES users (id)
      )
    ''');
    print('✓ Created activity_logs table');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_tasks_user ON tasks(user_id)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_tasks_deadline ON tasks(deadline)');
    await db.execute('CREATE INDEX idx_comments_task ON comments(task_id)');
    await db.execute('CREATE INDEX idx_subtasks_task ON subtasks(task_id)');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_activity_logs_task ON activity_logs(task_id)');
    print('✓ Created database indexes');

    print('✅ Database creation complete! All tables created successfully.');
  }

  // ==================== USER OPERATIONS ====================

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByStudentId(String studentId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUser(String userId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== TASK OPERATIONS ====================

  Future<String> createTask(Map<String, dynamic> task) async {
    final db = await database;
    final taskId = task['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    task['id'] = taskId;
    await db.insert('tasks', task);
    return taskId;
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'deadline ASC');
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(String userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );
  }

  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateTask(String taskId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      'tasks',
      updates,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final db = await database;
    await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> deleteTask(String taskId) async {
    final db = await database;

    // Delete associated files
    final task = await getTaskById(taskId);
    if (task != null && task['created_by'] != null) {
      await LocalStorageService.instance.deleteTaskAttachments(
        taskId: taskId,
        userId: task['created_by'],
      );
    }

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ==================== SUBTASK OPERATIONS ====================

  Future<String> insertSubtask(Map<String, dynamic> subtask) async {
    final db = await database;
    final subtaskId = subtask['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    subtask['id'] = subtaskId;
    await db.insert('subtasks', subtask);
    return subtaskId;
  }

  Future<List<Map<String, dynamic>>> getSubtasksByTask(String taskId) async {
    final db = await database;
    return await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at ASC',
    );
  }

  Future<int> updateSubtask(String subtaskId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      'subtasks',
      updates,
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  Future<int> deleteSubtask(String subtaskId) async {
    final db = await database;
    return await db.delete(
      'subtasks',
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  // ==================== COMMENT OPERATIONS ====================

  Future<String> insertComment(Map<String, dynamic> comment) async {
    final db = await database;
    final commentId = comment['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    comment['id'] = commentId;
    await db.insert('comments', comment);
    return commentId;
  }

  Future<void> addTaskComment(Map<String, dynamic> comment) async {
    await insertComment(comment);
  }

  Future<List<Map<String, dynamic>>> getCommentsByTask(String taskId) async {
    final db = await database;
    return await db.query(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'reported_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskComments(String taskId) async {
    return await getCommentsByTask(taskId);
  }

  Future<int> deleteComment(String commentId) async {
    final db = await database;

    // Get comment to delete associated file
    final comments = await db.query(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );

    if (comments.isNotEmpty) {
      final comment = comments.first;
      if (comment['attachment_url'] != null) {
        await LocalStorageService.instance.deleteFile(comment['attachment_url'] as String);
      }
    }

    return await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  // ==================== TAG OPERATIONS ====================

  Future<String> insertTag(Map<String, dynamic> tag) async {
    final db = await database;
    final tagId = tag['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    tag['id'] = tagId;
    await db.insert('tags', tag);
    return tagId;
  }

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return await db.query('tags', orderBy: 'name ASC');
  }

  Future<void> addTaskTag(String taskId, String tagId) async {
    final db = await database;
    await db.insert('task_tags', {
      'task_id': taskId,
      'tag_id': tagId,
    });
  }

  Future<List<Map<String, dynamic>>> getTagsByTask(String taskId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT tags.* FROM tags
      INNER JOIN task_tags ON tags.id = task_tags.tag_id
      WHERE task_tags.task_id = ?
    ''', [taskId]);
    return results;
  }

  Future<int> removeTaskTag(String taskId, String tagId) async {
    final db = await database;
    return await db.delete(
      'task_tags',
      where: 'task_id = ? AND tag_id = ?',
      whereArgs: [taskId, tagId],
    );
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  Future<String> createNotification(Map<String, dynamic> notification) async {
    final db = await database;
    final notificationId = notification['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    notification['id'] = notificationId;
    await db.insert('notifications', notification);
    return notificationId;
  }

  Future<List<Map<String, dynamic>>> getNotificationsByUser(String userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> markNotificationAsRead(String notificationId) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM notifications
      WHERE user_id = ? AND is_read = 0
    ''', [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== ACTIVITY LOG ====================

  Future<void> addActivityLog(Map<String, dynamic> log) async {
    final db = await database;
    final logId = log['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    log['id'] = logId;
    await db.insert('activity_logs', log);
  }

  Future<List<Map<String, dynamic>>> getActivityLog(String taskId) async {
    final db = await database;
    return await db.query(
      'activity_logs',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'timestamp DESC',
    );
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getTaskStatistics(String userId) async {

    final tasks = await getTasksByUserId(userId);
    final total = tasks.length;
    final todo = tasks.where((t) => t['status'] == 'todo').length;
    final inProgress = tasks.where((t) => t['status'] == 'in_progress').length;
    final done = tasks.where((t) => t['status'] == 'done').length;

    final completionRate = total > 0 ? (done / total * 100).toStringAsFixed(1) : '0.0';

    double totalEstimatedHours = 0;
    for (var task in tasks) {
      if (task['estimated_hours'] != null) {
        totalEstimatedHours += (task['estimated_hours'] as num).toDouble();
      }
    }

    return {
      'total': total,
      'todo': todo,
      'in_progress': inProgress,
      'done': done,
      'completion_rate': completionRate,
      'total_estimated_hours': totalEstimatedHours,
    };
  }

  // ==================== UTILITY ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taskflow.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

