# TaskFlow - Database API Documentation

Complete reference for all database operations in TaskFlow.

## 📊 Database Overview

**Database Name**: `taskflow.db`  
**Engine**: SQLite 3  
**ORM**: sqflite package  
**Location**: Application documents directory

---

## 📋 Tables

### 1. Users Table

Stores user accounts with role-based access.

**Schema**:
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK(role IN ('manager', 'staff'))
);
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique user identifier |
| name | TEXT | NOT NULL | User's full name |
| email | TEXT | NOT NULL, UNIQUE | User's email (login) |
| password | TEXT | NOT NULL | User's password (plain text - demo only) |
| role | TEXT | NOT NULL, CHECK | User role: 'manager' or 'staff' |

**Indexes**: 
- Primary key on `id`
- Unique index on `email`

---

### 2. Tasks Table

Stores all tasks with assignment and status information.

**Schema**:
```sql
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
  FOREIGN KEY (assignee_id) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique task identifier |
| title | TEXT | NOT NULL | Task title/name |
| description | TEXT | NOT NULL | Detailed task description |
| assignee_name | TEXT | NOT NULL | Name of assigned user (denormalized) |
| assignee_id | INTEGER | FOREIGN KEY → users(id) | ID of assigned user |
| priority | TEXT | NOT NULL, CHECK | Priority: 'urgent', 'medium', or 'low' |
| status | TEXT | NOT NULL, CHECK | Status: 'todo', 'in-progress', or 'done' |
| deadline | TEXT | NOT NULL | Deadline in ISO 8601 format |
| created_at | TEXT | NOT NULL | Creation timestamp in ISO 8601 |
| created_by | INTEGER | NOT NULL, FOREIGN KEY → users(id) | ID of creator (manager) |

**Relationships**:
- Many-to-One with Users (assignee_id)
- Many-to-One with Users (created_by)
- One-to-Many with Task Reports

---

### 3. Task Reports Table

Stores progress reports submitted by task assignees.

**Schema**:
```sql
CREATE TABLE task_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL,
  report_text TEXT NOT NULL,
  reported_by INTEGER NOT NULL,
  reported_at TEXT NOT NULL,
  FOREIGN KEY (task_id) REFERENCES tasks(id),
  FOREIGN KEY (reported_by) REFERENCES users(id)
);
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique report identifier |
| task_id | INTEGER | NOT NULL, FOREIGN KEY → tasks(id) | Associated task ID |
| report_text | TEXT | NOT NULL | Progress report content |
| reported_by | INTEGER | NOT NULL, FOREIGN KEY → users(id) | ID of reporter |
| reported_at | TEXT | NOT NULL | Report timestamp in ISO 8601 |

**Relationships**:
- Many-to-One with Tasks
- Many-to-One with Users

---

## 🔧 Database Helper API

**Class**: `DatabaseHelper`  
**Location**: `lib/database/database_helper.dart`  
**Pattern**: Singleton

### Initialization

#### `DatabaseHelper.instance`
Get singleton instance of database helper.

**Usage**:
```dart
final db = DatabaseHelper.instance;
```

---

#### `database`
Get or initialize database connection.

**Signature**:
```dart
Future<Database> get database async
```

**Returns**: `Future<Database>` - Database connection

**Usage**:
```dart
final db = await DatabaseHelper.instance.database;
```

---

## 👤 User Operations

### `loginUser()`
Authenticate user with email and password.

**Signature**:
```dart
Future<Map<String, dynamic>?> loginUser(String email, String password)
```

**Parameters**:
- `email`: User's email address
- `password`: User's password

**Returns**: 
- User object if credentials valid
- `null` if invalid

**Example**:
```dart
final user = await DatabaseHelper.instance.loginUser(
  'manager@taskflow.com',
  'manager123',
);

if (user != null) {
  print('Welcome ${user['name']}');
  print('Role: ${user['role']}');
}
```

**SQL Query**:
```sql
SELECT * FROM users 
WHERE email = ? AND password = ?
```

---

### `getAllUsers()`
Retrieve all users in the system.

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getAllUsers()
```

**Returns**: List of all user objects

**Example**:
```dart
final users = await DatabaseHelper.instance.getAllUsers();
for (var user in users) {
  print('${user['name']} - ${user['email']}');
}
```

**SQL Query**:
```sql
SELECT * FROM users
```

---

### `getStaffUsers()`
Retrieve only staff members (excludes managers).

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getStaffUsers()
```

**Returns**: List of staff user objects

**Example**:
```dart
final staff = await DatabaseHelper.instance.getStaffUsers();
// Use for assignee selection
```

**SQL Query**:
```sql
SELECT * FROM users WHERE role = 'staff'
```

---

## 📝 Task Operations

### `createTask()`
Create a new task.

**Signature**:
```dart
Future<int> createTask(Map<String, dynamic> task)
```

**Parameters**:
- `task`: Map containing task data

**Required Fields**:
```dart
{
  'title': String,
  'description': String,
  'assignee_name': String,
  'assignee_id': int,
  'priority': String,  // 'urgent', 'medium', or 'low'
  'status': String,    // 'todo', 'in-progress', or 'done'
  'deadline': String,  // ISO 8601 format
  'created_at': String, // ISO 8601 format
  'created_by': int,
}
```

**Returns**: Task ID of created task

**Example**:
```dart
final taskId = await DatabaseHelper.instance.createTask({
  'title': 'Fix login bug',
  'description': 'Users cannot login with correct credentials',
  'assignee_name': 'Jane Staff',
  'assignee_id': 2,
  'priority': 'urgent',
  'status': 'todo',
  'deadline': DateTime.now().add(Duration(days: 2)).toIso8601String(),
  'created_at': DateTime.now().toIso8601String(),
  'created_by': 1,
});

print('Task created with ID: $taskId');
```

---

### `getAllTasks()`
Retrieve all tasks in the system.

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getAllTasks()
```

**Returns**: List of all tasks, ordered by creation date (newest first)

**Example**:
```dart
final tasks = await DatabaseHelper.instance.getAllTasks();
for (var task in tasks) {
  print('${task['title']} - ${task['status']}');
}
```

**SQL Query**:
```sql
SELECT * FROM tasks 
ORDER BY created_at DESC
```

---

### `getTasksByUserId()`
Retrieve tasks assigned to a specific user.

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getTasksByUserId(int userId)
```

**Parameters**:
- `userId`: ID of the assigned user

**Returns**: List of tasks assigned to the user

**Example**:
```dart
final myTasks = await DatabaseHelper.instance.getTasksByUserId(userId);
print('You have ${myTasks.length} assigned tasks');
```

**SQL Query**:
```sql
SELECT * FROM tasks 
WHERE assignee_id = ? 
ORDER BY created_at DESC
```

---

### `getTasksByCreator()`
Retrieve tasks created by a specific user (manager).

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getTasksByCreator(int creatorId)
```

**Parameters**:
- `creatorId`: ID of the creator

**Returns**: List of tasks created by the user

**Example**:
```dart
final createdTasks = await DatabaseHelper.instance.getTasksByCreator(managerId);
```

**SQL Query**:
```sql
SELECT * FROM tasks 
WHERE created_by = ? 
ORDER BY created_at DESC
```

---

### `getTaskById()`
Retrieve a specific task by ID.

**Signature**:
```dart
Future<Map<String, dynamic>?> getTaskById(int id)
```

**Parameters**:
- `id`: Task ID

**Returns**: 
- Task object if found
- `null` if not found

**Example**:
```dart
final task = await DatabaseHelper.instance.getTaskById(5);
if (task != null) {
  print('Task: ${task['title']}');
  print('Status: ${task['status']}');
}
```

**SQL Query**:
```sql
SELECT * FROM tasks WHERE id = ?
```

---

### `updateTaskStatus()`
Update the status of a task.

**Signature**:
```dart
Future<int> updateTaskStatus(int taskId, String status)
```

**Parameters**:
- `taskId`: ID of task to update
- `status`: New status ('todo', 'in-progress', or 'done')

**Returns**: Number of rows affected (should be 1)

**Example**:
```dart
await DatabaseHelper.instance.updateTaskStatus(taskId, 'in-progress');
print('Task status updated');
```

**SQL Query**:
```sql
UPDATE tasks 
SET status = ? 
WHERE id = ?
```

---

### `deleteTask()`
Delete a task and its associated reports.

**Signature**:
```dart
Future<int> deleteTask(int taskId)
```

**Parameters**:
- `taskId`: ID of task to delete

**Returns**: Number of rows deleted

**Example**:
```dart
await DatabaseHelper.instance.deleteTask(taskId);
print('Task deleted');
```

**SQL Queries**:
```sql
-- First delete associated reports
DELETE FROM task_reports WHERE task_id = ?

-- Then delete the task
DELETE FROM tasks WHERE id = ?
```

**Note**: Uses cascade delete pattern manually since SQLite doesn't enforce foreign key constraints by default.

---

## 📊 Task Report Operations

### `addTaskReport()`
Add a progress report to a task.

**Signature**:
```dart
Future<int> addTaskReport(Map<String, dynamic> report)
```

**Parameters**:
- `report`: Map containing report data

**Required Fields**:
```dart
{
  'task_id': int,
  'report_text': String,
  'reported_by': int,
  'reported_at': String,  // ISO 8601 format
}
```

**Returns**: Report ID of created report

**Example**:
```dart
final reportId = await DatabaseHelper.instance.addTaskReport({
  'task_id': 5,
  'report_text': 'Completed initial analysis, starting implementation',
  'reported_by': 2,
  'reported_at': DateTime.now().toIso8601String(),
});

print('Report added with ID: $reportId');
```

---

### `getTaskReports()`
Retrieve all reports for a specific task with reporter information.

**Signature**:
```dart
Future<List<Map<String, dynamic>>> getTaskReports(int taskId)
```

**Parameters**:
- `taskId`: ID of the task

**Returns**: List of reports with reporter names, ordered by date (newest first)

**Example**:
```dart
final reports = await DatabaseHelper.instance.getTaskReports(taskId);
for (var report in reports) {
  print('${report['reporter_name']}: ${report['report_text']}');
  print('Time: ${report['reported_at']}');
}
```

**SQL Query**:
```sql
SELECT tr.*, u.name as reporter_name
FROM task_reports tr
JOIN users u ON tr.reported_by = u.id
WHERE tr.task_id = ?
ORDER BY tr.reported_at DESC
```

---

## 🔒 Database Management

### `close()`
Close database connection.

**Signature**:
```dart
Future<void> close()
```

**Usage**:
```dart
await DatabaseHelper.instance.close();
```

**Note**: Generally not needed as Flutter manages connections, but useful for testing.

---

## 📅 Date Format

All timestamps use **ISO 8601** format for consistency:

```dart
// Creating timestamp
final timestamp = DateTime.now().toIso8601String();
// Example: "2024-11-25T10:30:45.123456"

// Parsing timestamp
final dateTime = DateTime.parse(task['created_at']);

// Formatting for display
import 'package:intl/intl.dart';
final formatted = DateFormat('MMM dd, yyyy').format(dateTime);
// Example: "Nov 25, 2024"
```

---

## 🔄 Transaction Support

For operations requiring multiple queries, use transactions:

```dart
final db = await DatabaseHelper.instance.database;

await db.transaction((txn) async {
  // Create task
  final taskId = await txn.insert('tasks', taskData);
  
  // Add initial report
  await txn.insert('task_reports', {
    'task_id': taskId,
    'report_text': 'Task created',
    'reported_by': userId,
    'reported_at': DateTime.now().toIso8601String(),
  });
});
```

---

## 📈 Query Performance

### Indexes
- Primary keys automatically indexed
- Email field has unique index
- Foreign keys benefit from parent table indexes

### Optimization Tips
1. **Use specific queries**: Fetch only needed columns
2. **Limit results**: Add `LIMIT` for large datasets
3. **Index frequently queried fields**: Consider adding index on `status`
4. **Avoid SELECT ***: Specify columns when possible

---

## 🧪 Testing Database Operations

### Example Test Flow

```dart
// 1. Login
final user = await db.loginUser('staff@taskflow.com', 'staff123');
assert(user != null);

// 2. Get assigned tasks
final tasks = await db.getTasksByUserId(user!['id']);
print('${tasks.length} tasks found');

// 3. Update task status
if (tasks.isNotEmpty) {
  final taskId = tasks.first['id'];
  await db.updateTaskStatus(taskId, 'in-progress');
  
  // 4. Add report
  await db.addTaskReport({
    'task_id': taskId,
    'report_text': 'Started working on this task',
    'reported_by': user['id'],
    'reported_at': DateTime.now().toIso8601String(),
  });
  
  // 5. Verify report added
  final reports = await db.getTaskReports(taskId);
  assert(reports.isNotEmpty);
}
```

---

## 🛡️ Security Considerations

### Current Implementation
⚠️ **For Demo Purposes Only**:
- Passwords stored in plain text
- No SQL injection protection (using parameterized queries helps)
- No encryption at rest

### Production Recommendations
1. **Hash Passwords**: Use bcrypt or similar
   ```dart
   import 'package:crypto/crypto.dart';
   final hash = sha256.convert(utf8.encode(password));
   ```

2. **Encrypt Database**: Use `sqflite_sqlcipher`
   ```dart
   await openDatabase(
     path,
     password: "your-secure-password",
   );
   ```

3. **Parameterized Queries**: Already implemented
   ```dart
   db.query('users', where: 'email = ?', whereArgs: [email]);
   ```

4. **Input Validation**: Sanitize all user inputs
5. **Access Control**: Verify user permissions before operations

---

## 📞 Support

For database-related issues:
- Check SQLite documentation: https://www.sqlite.org/docs.html
- sqflite package: https://pub.dev/packages/sqflite
- Flutter database guide: https://flutter.dev/docs/cookbook/persistence/sqlite

---

**Happy Coding!** 💾

