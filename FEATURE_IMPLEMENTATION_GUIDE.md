# TaskFlow - Feature Implementation Guide

## 📋 Overview
This guide outlines the implementation of 10 new features for TaskFlow application.

## 🎯 Features to Implement

### 1. 📅 Notifikasi dan Pengingat (Notifications & Reminders)
**Status**: Ready to implement
**Priority**: High
**Dependencies**: `flutter_local_notifications`, `timezone`

**Implementation Details**:
- **Deadline Reminders**: Send notification 24 hours before deadline for tasks in To Do or In Progress
- **Status Update Notifications**: Notify Manager when Staff changes task status or adds reports
- **New Task Assignment**: Notify Staff immediately when Manager assigns a new task

**Database Changes**: Add `notifications` table
**Files to Create/Modify**:
- Create `lib/services/notification_service.dart`
- Modify `database_helper.dart` - add notifications table
- Modify `add_task_screen.dart` - schedule notification on task creation
- Modify `task_detail_screen.dart` - send notifications on status updates

---

### 2. 💬 Komentar dan Diskusi Tugas (Task Comments & Discussion)
**Status**: Ready to implement
**Priority**: High
**Dependencies**: None (built-in)

**Implementation Details**:
- **Comment Thread**: Two-way communication between Manager and Staff
- **File Attachments**: Allow attaching images/documents (using `image_picker`, `file_picker`)
- **User Mentions**: @mention system for tagging team members

**Database Changes**: Rename `task_reports` to `task_comments`, add `comment_type` and `attachment_path` columns
**Files to Create/Modify**:
- Modify `database_helper.dart` - update table structure
- Modify `task_detail_screen.dart` - enhance comment UI with attachments
- Create `lib/widgets/comment_widget.dart`
- Create `lib/services/file_service.dart`

---

### 3. 👤 Manajemen Profil Pengguna (Simple User Profile Management)
**Status**: Ready to implement
**Priority**: Medium
**Dependencies**: `image_picker`

**Implementation Details**:
- **Profile Photo/Avatar**: Upload or set profile picture
- **Contact Information**: Display position, contact number
- **Task Summary**: Show counts of To Do, In Progress, Done tasks

**Database Changes**: Add columns to `users` table: `avatar_path`, `position`, `contact_number`
**Files to Create/Modify**:
- Modify `database_helper.dart` - update users table
- Create `lib/screens/profile_screen.dart`
- Create `lib/screens/edit_profile_screen.dart`
- Modify `dashboard_screen.dart` - add profile navigation

---

### 4. 📈 Tampilan Laporan dan Statistik (Reporting & Statistics Dashboard)
**Status**: Ready to implement
**Priority**: High
**Dependencies**: `fl_chart`

**Implementation Details**:
- **Summary Charts**: Bar/Donut charts for task status and priority distribution
- **Date and Project Filters**: Filter tasks by date range or category
- **Performance Metrics**: Team performance overview for managers

**Database Changes**: None (uses existing data)
**Files to Create/Modify**:
- Create `lib/screens/statistics_screen.dart`
- Create `lib/widgets/chart_widgets.dart`
- Modify `dashboard_screen.dart` - add statistics navigation
- Add methods to `database_helper.dart` for aggregated data

---

### 5. 🏷️ Tagging Tugas atau Kategori Proyek (Task Tagging / Project Categories)
**Status**: Ready to implement
**Priority**: Medium
**Dependencies**: None (built-in)

**Implementation Details**:
- **Tag System**: Add multiple tags per task (e.g., "Marketing Campaign", "Bug Fix")
- **Filter by Tags**: Filter task list by selected tags
- **Tag Management**: Create and manage project categories

**Database Changes**: Create `tags` and `task_tags` junction table
**Files to Create/Modify**:
- Modify `database_helper.dart` - add tags tables
- Modify `add_task_screen.dart` - add tag selection
- Create `lib/widgets/tag_chip_widget.dart`
- Modify `dashboard_screen.dart` - add tag filtering

---

### 6. 🔄 Sub-Tugas (Subtasks / Checklist)
**Status**: Ready to implement
**Priority**: Medium
**Dependencies**: None (built-in)

**Implementation Details**:
- **Checklist**: Add sub-tasks within a main task
- **Progress Tracking**: Auto-calculate completion percentage
- **Status Suggestion**: Suggest status change when all subtasks are completed

**Database Changes**: Create `subtasks` table
**Files to Create/Modify**:
- Modify `database_helper.dart` - add subtasks table
- Modify `task_detail_screen.dart` - add subtask UI
- Create `lib/widgets/subtask_item.dart`

---

### 7. 🔒 Audit Log dan Histori Aktivitas (Audit Log / Activity History)
**Status**: Ready to implement
**Priority**: Medium
**Dependencies**: None (built-in)

**Implementation Details**:
- **Change Logging**: Record all task modifications (title, description, priority, assignment)
- **Timeline Display**: Show activity history as timeline in task details
- **User Attribution**: Track who made each change

**Database Changes**: Create `activity_log` table
**Files to Create/Modify**:
- Modify `database_helper.dart` - add activity_log table
- Create `lib/services/audit_service.dart`
- Modify `task_detail_screen.dart` - display activity timeline
- Create `lib/widgets/activity_timeline.dart`

---

### 8. 🕰️ Estimasi Waktu (Time Estimation)
**Status**: Ready to implement
**Priority**: Low
**Dependencies**: None (built-in)

**Implementation Details**:
- **Time Input**: Manager inputs estimated time during task creation
- **Display**: Staff sees time estimate to prioritize work
- **Time Tracking**: Optional manual time tracking feature

**Database Changes**: Add `estimated_hours` column to `tasks` table
**Files to Create/Modify**:
- Modify `database_helper.dart` - update tasks table
- Modify `add_task_screen.dart` - add time estimation input
- Modify `task_detail_screen.dart` - display time estimate

---

### 9. 📤 Ekspor Tugas (Task Export)
**Status**: Ready to implement
**Priority**: Low
**Dependencies**: `csv`, `pdf`

**Implementation Details**:
- **Export Data**: Export task list to CSV or PDF format
- **Filtering**: Export filtered data (by status, user, date range)
- **Sharing**: Share exported file via email or other apps

**Database Changes**: None (uses existing data)
**Files to Create/Modify**:
- Create `lib/services/export_service.dart`
- Modify `dashboard_screen.dart` - add export button
- Add dependencies: `csv`, `pdf`, `path_provider`, `share_plus`

---

### 10. 🎨 Tema Kustom (Custom Theme / Dark Mode)
**Status**: Ready to implement
**Priority**: Medium
**Dependencies**: `shared_preferences`

**Implementation Details**:
- **Dark Mode**: Implement dark theme toggle
- **Theme Persistence**: Save theme preference
- **Accessibility**: Add text size adjustment options
- **Custom Colors**: Allow theme customization

**Database Changes**: None (uses shared_preferences)
**Files to Create/Modify**:
- Modify `app_theme.dart` - add dark theme
- Create `lib/services/theme_service.dart`
- Modify `main.dart` - implement theme switching
- Create `lib/screens/settings_screen.dart`

---

## 📦 Required Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Existing dependencies
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0
  path: ^1.8.3
  intl: ^0.20.2
  
  # New dependencies
  flutter_local_notifications: ^18.0.1  # For notifications
  timezone: ^0.10.0                      # For scheduling notifications
  fl_chart: ^0.70.1                      # For charts/graphs
  image_picker: ^1.1.2                   # For profile pictures & attachments
  file_picker: ^8.1.4                    # For file attachments
  shared_preferences: ^2.3.3             # For theme preferences
  csv: ^6.0.0                            # For CSV export
  pdf: ^3.11.1                           # For PDF export
  path_provider: ^2.1.5                  # For file storage
  share_plus: ^10.1.2                    # For sharing files
  permission_handler: ^11.3.1            # For permissions
```

---

## 🗂️ Database Schema Updates

### New Tables to Create:

#### 1. Notifications Table
```sql
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
```

#### 2. Tags Table
```sql
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  color TEXT NOT NULL
)

CREATE TABLE task_tags (
  task_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (task_id, tag_id),
  FOREIGN KEY (task_id) REFERENCES tasks(id),
  FOREIGN KEY (tag_id) REFERENCES tags(id)
)
```

#### 3. Subtasks Table
```sql
CREATE TABLE subtasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  is_completed INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (task_id) REFERENCES tasks(id)
)
```

#### 4. Activity Log Table
```sql
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
```

### Table Modifications:

#### Update Users Table
```sql
ALTER TABLE users ADD COLUMN avatar_path TEXT;
ALTER TABLE users ADD COLUMN position TEXT;
ALTER TABLE users ADD COLUMN contact_number TEXT;
```

#### Update Tasks Table
```sql
ALTER TABLE tasks ADD COLUMN estimated_hours REAL;
ALTER TABLE tasks ADD COLUMN category TEXT;
```

#### Update Task Reports (rename to Comments)
```sql
ALTER TABLE task_reports RENAME TO task_comments;
ALTER TABLE task_comments ADD COLUMN comment_type TEXT DEFAULT 'text';
ALTER TABLE task_comments ADD COLUMN attachment_path TEXT;
```

---

## 📱 Implementation Order (Recommended)

### Phase 1: Core Enhancements (Week 1)
1. ✅ Dark Mode & Theme System (Feature 10)
2. ✅ User Profile Management (Feature 3)
3. ✅ Time Estimation (Feature 8)

### Phase 2: Communication (Week 2)
4. ✅ Task Comments & Discussion (Feature 2)
5. ✅ Notifications & Reminders (Feature 1)

### Phase 3: Organization (Week 3)
6. ✅ Task Tagging & Categories (Feature 5)
7. ✅ Subtasks & Checklists (Feature 6)

### Phase 4: Analytics & Tracking (Week 4)
8. ✅ Statistics & Reporting Dashboard (Feature 4)
9. ✅ Audit Log & Activity History (Feature 7)
10. ✅ Task Export (Feature 9)

---

## 🚀 Getting Started

### Step 1: Update Dependencies
```bash
flutter pub add flutter_local_notifications timezone fl_chart image_picker file_picker shared_preferences csv pdf path_provider share_plus permission_handler
```

### Step 2: Update Database Schema
Run database migration to update to version 2 with all new tables and columns.

### Step 3: Implement Features
Follow the implementation order above, testing each feature before moving to the next.

---

## ✅ Testing Checklist

For each feature:
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] UI/UX tested on Android
- [ ] Database migrations working
- [ ] No breaking changes to existing features
- [ ] Documentation updated

---

## 📝 Notes

- All features maintain backward compatibility
- Existing demo data will work with new schema
- Features are modular and can be implemented independently
- Consider performance impact of notifications and large datasets

---

**Last Updated**: November 25, 2025
**Version**: 2.0.0
**Status**: Implementation Ready

