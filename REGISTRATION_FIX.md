# Registration Error Fix - Student Role Support

## Issue
When trying to register a new student account, the app showed an error:
```
Database Exception/CHECK constraint failed: role IN ('manager', 'staff')
```

This occurred because the existing database on your device was created with an older schema that only allowed `'manager'` or `'staff'` roles, but the new student edition requires `'student'` role support.

## Root Cause
- The database version 3 upgrade added the `student_id` column but **did not update the CHECK constraint** on the `role` column
- SQLite does not support modifying CHECK constraints directly via ALTER TABLE
- Existing databases on devices had the old constraint that blocked student registration

## Solution Implemented

### 1. Database Version Bump
Updated database version from **3 to 4** to trigger migration:

```dart
version: 4,  // Changed from 3
```

### 2. Users Table Recreation (Version 4 Migration)
Added migration logic that:
1. Creates a new `users_new` table with correct CHECK constraint:
   ```sql
   CHECK(role IN ('manager', 'staff', 'student'))
   ```
2. Copies all existing data from old table to new table
3. Drops the old `users` table
4. Renames `users_new` to `users`

This is the only way to modify CHECK constraints in SQLite.

### 3. Changes Made to Files

#### `lib/database/database_helper.dart`
- **Line 22**: Changed version from `3` to `4`
- **Lines 258-289**: Added version 4 migration logic to recreate users table

## How to Apply This Fix

### Option 1: Automatic Migration (Recommended)
1. Simply restart the app after pulling these changes
2. The database will automatically upgrade from version 3 to 4
3. All existing data will be preserved
4. Student registration will now work

### Option 2: Fresh Database (For Testing)
If you want to start completely fresh:

```bash
# For Android
flutter run
# Then in app, uninstall and reinstall

# For testing, you can also manually clear app data:
adb shell pm clear kej.com.taskflow
```

## Verification Steps

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Go to Register screen**

3. **Fill in the form with:**
   - Full Name: Test Student
   - Student ID: STU12345
   - Email: test@university.edu
   - Password: test123
   - Confirm Password: test123

4. **Click Register**

5. **Expected Result**: ✅ Account created successfully

## Technical Notes

### Why SQLite Requires Table Recreation
SQLite's ALTER TABLE only supports:
- Adding columns
- Renaming columns (SQLite 3.25.0+)
- Renaming tables

It does NOT support:
- Modifying CHECK constraints
- Adding UNIQUE constraints to existing columns
- Changing column types

Therefore, modifying the CHECK constraint requires the full "create-copy-drop-rename" pattern.

### Data Preservation
The migration preserves all columns:
- id, name, student_id, email, password, role
- avatar_path, position, contact_number, created_at

### Foreign Key Safety
The migration happens within a transaction, so all foreign key relationships (tasks, notifications, etc.) remain intact.

## Benefits for Student Edition

With this fix, students can now:
- ✅ Register with student ID and email
- ✅ Use role: 'student' for academic-focused features
- ✅ Login with either student ID or email
- ✅ Access student-specific dashboard views
- ✅ Use academic tags (Assignment, Exam, Project, etc.)

## Next Steps

After verifying registration works:
1. Test login with both student ID and email
2. Verify student dashboard shows academic features
3. Test task creation with academic tags
4. Consider adding academic-specific validation (e.g., university email domains)

## Related Files
- `lib/database/database_helper.dart` - Database schema and migrations
- `lib/screens/register_screen.dart` - Registration UI (already correct)
- `lib/screens/login_screen.dart` - Login with student ID support (already correct)

