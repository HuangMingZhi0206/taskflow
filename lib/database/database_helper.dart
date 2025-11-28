import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table with student support
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        student_id TEXT UNIQUE,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('manager', 'staff', 'student')),
        avatar_path TEXT,
        position TEXT,
        contact_number TEXT,
        created_at TEXT
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        assignee_name TEXT NOT NULL,
        assignee_id INTEGER,
        priority TEXT NOT NULL CHECK(priority IN ('urgent', 'medium', 'low')),
        status TEXT NOT NULL CHECK(status IN ('todo', 'in-progress', 'done')),
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        estimated_hours REAL,
        category TEXT,
        FOREIGN KEY (assignee_id) REFERENCES users(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Create task reports table (renamed to comments)
    await db.execute('''
      CREATE TABLE task_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        comment_text TEXT NOT NULL,
        reported_by INTEGER NOT NULL,
        reported_at TEXT NOT NULL,
        comment_type TEXT DEFAULT 'text',
        attachment_path TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks(id),
        FOREIGN KEY (reported_by) REFERENCES users(id)
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        task_id INTEGER,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (task_id) REFERENCES tasks(id)
      )
    ''');

    // Create tags table
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // Create task_tags junction table
    await db.execute('''
      CREATE TABLE task_tags (
        task_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks(id),
        FOREIGN KEY (tag_id) REFERENCES tags(id)
      )
    ''');

    // Create subtasks table
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id)
      )
    ''');

    // Create activity_log table
    await db.execute('''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        action_type TEXT NOT NULL,
        field_name TEXT,
        old_value TEXT,
        new_value TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Insert default academic tags for students
    await db.insert('tags', {'name': 'Assignment', 'color': '3b82f6'});
    await db.insert('tags', {'name': 'Exam', 'color': 'ef4444'});
    await db.insert('tags', {'name': 'Project', 'color': '8b5cf6'});
    await db.insert('tags', {'name': 'Reading', 'color': '10b981'});
    await db.insert('tags', {'name': 'Study Group', 'color': 'f59e0b'});
    await db.insert('tags', {'name': 'Lab', 'color': '06b6d4'});
    await db.insert('tags', {'name': 'Research', 'color': 'ec4899'});
    await db.insert('tags', {'name': 'Presentation', 'color': '14b8a6'});
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Helper function to safely add column
    Future<void> safeAddColumn(String tableName, String columnDef) async {
      try {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnDef');
        print('✓ Added column to $tableName');
      } catch (e) {
        if (e.toString().contains('duplicate column')) {
          print('○ Column already exists in $tableName (skipping)');
        } else {
          print('✗ Error adding column to $tableName: $e');
          rethrow;
        }
      }
    }

    if (oldVersion < 2) {
      // Add new columns to users table (with error handling)
      await safeAddColumn('users', 'avatar_path TEXT');
      await safeAddColumn('users', 'position TEXT');
      await safeAddColumn('users', 'contact_number TEXT');

      // Add new columns to tasks table
      await safeAddColumn('tasks', 'estimated_hours REAL');
      await safeAddColumn('tasks', 'category TEXT');

      // Note: Complex migrations like RENAME are skipped if already done
      // The app will work with the current schema
    }
  }


  // User operations
  Future<Map<String, dynamic>?> loginUser(String emailOrStudentId, String password) async {
    final db = await database;
    // Try login with email first
    var result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [emailOrStudentId.toLowerCase(), password],
    );

    // If not found, try with student ID
    if (result.isEmpty) {
      result = await db.query(
        'users',
        where: 'student_id = ? AND password = ?',
        whereArgs: [emailOrStudentId, password],
      );
    }

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByStudentId(String studentId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getStaffUsers() async {
    final db = await database;
    return await db.query('users', where: 'role = ?', whereArgs: ['staff']);
  }

  // Task operations
  Future<int> createTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'assignee_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTasksByCreator(int creatorId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'created_by = ?',
      whereArgs: [creatorId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateTaskStatus(int taskId, String status) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> deleteTask(int taskId) async {
    final db = await database;
    // Delete associated data first
    await db.delete('task_comments', where: 'task_id = ?', whereArgs: [taskId]);
    await db.delete('task_tags', where: 'task_id = ?', whereArgs: [taskId]);
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
    await db.delete('activity_log', where: 'task_id = ?', whereArgs: [taskId]);
    // Delete the task
    return await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // Task comment operations (previously reports)
  Future<int> addTaskComment(Map<String, dynamic> comment) async {
    final db = await database;
    return await db.insert('task_comments', comment);
  }

  Future<List<Map<String, dynamic>>> getTaskComments(int taskId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tc.*, u.name as reporter_name
      FROM task_comments tc
      JOIN users u ON tc.reported_by = u.id
      WHERE tc.task_id = ?
      ORDER BY tc.reported_at DESC
    ''', [taskId]);
  }

  // Notification operations
  Future<int> createNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(int userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> markNotificationAsRead(int notificationId) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Tag operations
  Future<int> createTag(Map<String, dynamic> tag) async {
    final db = await database;
    return await db.insert('tags', tag);
  }

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return await db.query('tags');
  }

  Future<void> addTaskTag(int taskId, int tagId) async {
    final db = await database;
    await db.insert('task_tags', {'task_id': taskId, 'tag_id': tagId});
  }

  Future<void> removeTaskTag(int taskId, int tagId) async {
    final db = await database;
    await db.delete(
      'task_tags',
      where: 'task_id = ? AND tag_id = ?',
      whereArgs: [taskId, tagId],
    );
  }

  Future<List<Map<String, dynamic>>> getTaskTags(int taskId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.*
      FROM tags t
      JOIN task_tags tt ON t.id = tt.tag_id
      WHERE tt.task_id = ?
    ''', [taskId]);
  }

  Future<List<Map<String, dynamic>>> getTasksByTag(int tagId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.*
      FROM tasks t
      JOIN task_tags tt ON t.id = tt.task_id
      WHERE tt.tag_id = ?
      ORDER BY t.created_at DESC
    ''', [tagId]);
  }

  // Subtask operations
  Future<int> createSubtask(Map<String, dynamic> subtask) async {
    final db = await database;
    return await db.insert('subtasks', subtask);
  }

  Future<List<Map<String, dynamic>>> getSubtasks(int taskId) async {
    final db = await database;
    return await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'created_at ASC',
    );
  }

  Future<int> updateSubtask(int subtaskId, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'subtasks',
      data,
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  Future<int> deleteSubtask(int subtaskId) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [subtaskId]);
  }

  // Activity log operations
  Future<int> logActivity(Map<String, dynamic> activity) async {
    final db = await database;
    return await db.insert('activity_log', activity);
  }

  Future<List<Map<String, dynamic>>> getTaskActivityLog(int taskId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT al.*, u.name as user_name
      FROM activity_log al
      JOIN users u ON al.user_id = u.id
      WHERE al.task_id = ?
      ORDER BY al.created_at DESC
    ''', [taskId]);
  }

  // Profile operations
  Future<int> updateUserProfile(int userId, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  // Statistics operations
  Future<Map<String, int>> getTaskStatusCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM tasks
      GROUP BY status
    ''');

    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<Map<String, int>> getTaskPriorityCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT priority, COUNT(*) as count
      FROM tasks
      GROUP BY priority
    ''');

    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['priority'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<Map<String, int>> getUserTaskCounts(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM tasks
      WHERE assignee_id = ?
      GROUP BY status
    ''', [userId]);

    Map<String, int> counts = {'todo': 0, 'in-progress': 0, 'done': 0};
    for (var row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

