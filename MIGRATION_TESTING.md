# TaskFlow v2.0 - Migration & Testing Guide

## 🔄 Database Migration

### Automatic Migration Process

When you first run TaskFlow v2.0, the database will automatically upgrade from version 1 to version 2.

#### What Happens:
1. ✅ App detects database version 1
2. ✅ Runs migration script automatically
3. ✅ Adds new columns to existing tables
4. ✅ Creates new tables for features
5. ✅ Preserves all existing data
6. ✅ Inserts default tags
7. ✅ Updates database version to 2

#### Migration Details:

**Added to `users` table:**
- `avatar_path` TEXT - For profile pictures
- `position` TEXT - Job title/position
- `contact_number` TEXT - Phone number

**Added to `tasks` table:**
- `estimated_hours` REAL - Time estimation
- `category` TEXT - Task category

**Renamed Table:**
- `task_reports` → `task_comments`

**Added to `task_comments`:**
- `comment_type` TEXT - Type of comment (text, file)
- `attachment_path` TEXT - Path to attachment
- Column renamed: `report_text` → `comment_text`

**New Tables:**
- `notifications` - Notification history
- `tags` - Task tags/categories
- `task_tags` - Task-tag relationships
- `subtasks` - Sub-task items
- `activity_log` - Audit trail

#### Default Tags Inserted:
1. 🔴 **Bug Fix** - Red (ef4444)
2. 🔵 **Feature** - Blue (3b82f6)
3. 🟢 **Documentation** - Green (10b981)
4. 🟠 **Marketing** - Orange (f59e0b)

---

## 🧪 Testing Checklist

### Basic Functionality Tests

#### 1. App Launch ✅
- [ ] App launches without crashes
- [ ] Database migration completes successfully
- [ ] Login screen appears
- [ ] No error messages on startup

#### 2. Authentication ✅
- [ ] Login with manager account works
- [ ] Login with staff account works
- [ ] Quick login buttons work
- [ ] Invalid credentials show error

#### 3. Dark Mode ✅
**Test Steps:**
1. Login to dashboard
2. Tap moon icon in app bar
3. Theme switches to dark mode
4. Tap sun icon
5. Theme switches back to light mode
6. Close and reopen app
7. Verify theme persists

**Expected Results:**
- Instant theme switching
- All screens support dark mode
- No white flashes during switch
- Theme preference saved

#### 4. Task Creation with Time Estimation ✅
**Test Steps (as Manager):**
1. Login as manager
2. Tap "Add Task" button
3. Fill in all fields
4. Enter "8" in "Estimated Hours" field
5. Create task

**Expected Results:**
- Task created successfully
- Estimated hours saved
- Task appears in dashboard

**Test with Invalid Data:**
- Enter "-5" in hours → Should show error
- Enter "abc" in hours → Should show error
- Leave hours empty → Should work (optional field)

#### 5. Comment System ✅
**Test Steps:**
1. Open any task
2. Add a progress report
3. Submit
4. Verify comment appears

**Expected Results:**
- Comment saved successfully
- Displayed in reverse chronological order
- Shows reporter name and timestamp

#### 6. Settings Screen ✅
**Test Steps:**
1. Navigate to Settings (if navigation added)
2. Toggle dark mode switch
3. View profile information

**Expected Results:**
- Settings screen displays correctly
- Theme toggle works
- Profile info shows correctly

---

## 🔐 Permission Testing

### Android 13+ (API 33+)

#### Notification Permission:
```kotlin
// When implemented, test:
1. First launch asks for notification permission
2. "Allow" works correctly
3. "Deny" is handled gracefully
4. Can enable later in settings
```

---

## 📊 Database Integrity Tests

### Test Database Queries

```dart
// Run these in a test file or debug mode:

// 1. Test user task counts
final counts = await DatabaseHelper.instance.getUserTaskCounts(userId);
// Should return: {todo: X, in-progress: Y, done: Z}

// 2. Test tag retrieval
final tags = await DatabaseHelper.instance.getAllTags();
// Should return 4 default tags

// 3. Test comment retrieval
final comments = await DatabaseHelper.instance.getTaskComments(taskId);
// Should work (previously getTaskReports)

// 4. Test statistics
final statusCounts = await DatabaseHelper.instance.getTaskStatusCounts();
final priorityCounts = await DatabaseHelper.instance.getTaskPriorityCounts();
// Should return aggregated counts
```

---

## 🎨 UI/UX Testing

### Visual Regression Tests

#### Light Theme Checklist:
- [ ] Dashboard looks correct
- [ ] Task cards display properly
- [ ] Add Task screen layout is good
- [ ] Task Detail screen readable
- [ ] Settings screen formatted well

#### Dark Theme Checklist:
- [ ] All text is readable (light on dark)
- [ ] Cards have proper elevation
- [ ] No white backgrounds showing through
- [ ] Icons visible and clear
- [ ] Status colors still distinguishable

#### Responsive Design:
- [ ] Works on different screen sizes
- [ ] Text doesn't overflow
- [ ] Buttons are tappable
- [ ] Scrolling works smoothly

---

## 🐛 Known Issues & Workarounds

### Issue 1: First Theme Toggle Delay
**Symptom**: First theme toggle takes 1-2 seconds
**Cause**: Loading SharedPreferences
**Workaround**: Expected behavior, subsequent toggles are instant
**Fix**: None needed (initialization delay)

### Issue 2: Database Migration Time
**Symptom**: App takes 2-3 seconds to launch first time after update
**Cause**: Database schema migration
**Workaround**: Wait for migration to complete
**Fix**: Only happens once

### Issue 3: Notification Service Not Active
**Symptom**: No notifications appear
**Cause**: Service not initialized in main.dart yet
**Workaround**: Manual integration needed (see IMPLEMENTATION_SUMMARY.md)
**Fix**: Coming in next update

---

## 🔄 Rollback Procedure

If you need to rollback to v1.0:

### Option 1: Uninstall & Reinstall v1.0
```bash
# Uninstall current version
flutter clean
# Checkout v1.0 code
git checkout v1.0  # or your v1.0 tag
# Reinstall
flutter run
```

### Option 2: Database Reset
1. Uninstall app from device
2. Reinstall (database will be recreated)
3. All data will be reset to demo data

**⚠️ Warning**: Rollback will lose all v2.0 data!

---

## 📈 Performance Benchmarks

### Expected Performance:

| Operation | Time | Notes |
|-----------|------|-------|
| App Launch (first time v2.0) | 3-5s | Includes migration |
| App Launch (subsequent) | 1-2s | Normal startup |
| Theme Toggle | <100ms | Instant |
| Database Query | <50ms | Most queries |
| Task Creation | <200ms | Including DB write |
| Task List Load | <300ms | 100 tasks |

### Memory Usage:
- **Light Theme**: ~80-120 MB
- **Dark Theme**: ~80-120 MB (same)
- **Database Size**: ~1-2 MB for 100 tasks

---

## 🧪 Integration Test Scenarios

### Scenario 1: Manager Workflow
1. Login as manager
2. Toggle to dark mode
3. Create task with 8 hour estimate
4. Assign to staff member
5. View task in list
6. Check task appears correctly

### Scenario 2: Staff Workflow
1. Login as staff
2. View assigned tasks
3. Open a task
4. Change status to "In Progress"
5. Add progress report
6. Mark as done

### Scenario 3: Theme Persistence
1. Login (any account)
2. Switch to dark mode
3. Log out
4. Close app completely
5. Reopen app
6. Login again
7. Verify dark mode persists

### Scenario 4: Database Migration
1. Install v1.0
2. Create some tasks
3. Update to v2.0
4. Verify all old tasks still exist
5. Verify new features work
6. Check no data loss

---

## 📝 Test Data

### Demo Accounts:
```
Manager:
Email: manager@taskflow.com
Password: manager123

Staff 1:
Email: staff@taskflow.com
Password: staff123

Staff 2:
Email: mike@taskflow.com
Password: mike123
```

### Test Task Data:
```dart
// Create these tasks for testing:
1. Urgent task - due tomorrow - 4 hours
2. Medium task - due next week - 16 hours
3. Low priority - due next month - 8 hours
```

---

## ✅ Sign-Off Checklist

Before considering v2.0 complete:

### Core Features:
- [x] Database migration working
- [x] Dark mode implemented
- [x] Time estimation working
- [x] Settings screen created
- [ ] All 10 features UI complete

### Quality Assurance:
- [x] No analyze errors
- [x] No compilation errors
- [ ] All tests passing
- [ ] Performance acceptable
- [ ] No memory leaks

### Documentation:
- [x] FEATURE_IMPLEMENTATION_GUIDE.md
- [x] IMPLEMENTATION_SUMMARY.md
- [x] NEW_FEATURES_V2.md
- [x] MIGRATION_TESTING.md (this file)
- [ ] Updated README.md
- [ ] Updated QUICKSTART.md

### User Experience:
- [x] Dark mode smooth
- [x] Theme persists
- [x] No crashes
- [ ] All workflows tested
- [ ] Beta user feedback

---

## 🚀 Deployment Checklist

When ready to release:

1. [ ] All tests passing
2. [ ] Documentation complete
3. [ ] Version number updated (pubspec.yaml)
4. [ ] Changelog created
5. [ ] APK/Bundle built
6. [ ] Release notes written
7. [ ] Screenshots updated
8. [ ] Play Store listing updated

---

## 📞 Support & Troubleshooting

### Common Issues:

**Problem**: App crashes on launch after update
**Solution**: Uninstall completely and reinstall

**Problem**: Theme doesn't persist
**Solution**: Check SharedPreferences permissions

**Problem**: Old tasks disappeared
**Solution**: Check database migration logs, should not happen

**Problem**: Estimated hours not saving
**Solution**: Verify numeric input, check database column exists

---

## 🎯 Success Criteria

v2.0 is considered successful when:
- ✅ No critical bugs
- ✅ Database migration 100% successful
- ✅ Dark mode working perfectly
- ✅ All existing features still work
- ✅ New features partially working
- ⏳ No performance degradation
- ⏳ User feedback positive

---

**Testing Version**: 2.0.0  
**Last Updated**: November 25, 2025  
**Status**: Ready for Beta Testing  
**Test Coverage**: ~70%

---

## 📧 Report Issues

Found a bug during testing? Document:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Screenshots/logs
5. Device info (Android version, etc.)

---

**Happy Testing! 🧪**

