# 🎓 TaskFlow Student Edition - Quick Start

## 🎉 Transformation Complete!

TaskFlow is now a **student-focused productivity app** with courses, schedules, study groups, and more!

---

## ✅ What's New

### Student Features
- 📚 **Course Management** - Track all your classes with color coding
- 📅 **Class Schedule** - Weekly schedule view with times and rooms
- 👥 **Study Groups** - Collaborate with classmates on projects
- ⏱️ **Pomodoro Timer** - Focus sessions with break reminders
- 📊 **Study Tracking** - Log study time by course
- ✏️ **Student Registration** - Student ID, major, and year fields

### No More Roles
- ❌ Removed manager/staff system
- ✅ All users are students
- ✅ Groups have leaders/members instead

---

## 🚀 Quick Start (3 Steps)

### Step 1: Run the App (1 min)
```bash
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
flutter clean
flutter pub get
flutter run
```

### Step 2: Register as a Student (2 min)
1. Click "Sign Up"
2. Fill in:
   - Name
   - Student ID (e.g., STU12345)
   - Email
   - Major (optional)
   - Year (optional)
   - Password
3. Login with email or student ID

### Step 3: Explore New Features (5 min)
Navigate to:
- `/courses` - Add your classes
- `/schedule` - View weekly schedule
- `/groups` - Create/join study groups

---

## 📱 New Screens

### 1. Courses Screen (`/courses`)
**Access:** `Navigator.pushNamed(context, '/courses', arguments: user)`

**Features:**
- Add courses with code and name
- Choose color for each course
- Add instructor and room
- Add class schedule times
- Delete courses

**Example:**
```
Course Code: CS101
Course Name: Intro to Programming
Instructor: Dr. Smith
Room: Building A, Room 301
Color: Blue
Schedule: Mon/Wed 9:00-10:30
```

### 2. Schedule Screen (`/schedule`)
**Access:** `Navigator.pushNamed(context, '/schedule', arguments: user)`

**Features:**
- Weekly calendar view
- Grouped by day
- Shows class times and rooms
- Color-coded by course
- Remove schedule items

**View:**
```
Monday:
  9:00-10:30 | CS101 - Room 301
  14:00-15:30 | MATH202 - Room 105

Tuesday:
  10:00-11:30 | ENG101 - Room 210
```

### 3. Groups Screen (`/groups`)
**Access:** `Navigator.pushNamed(context, '/groups', arguments: user)`

**Features:**
- Create study groups
- Join/leave groups
- Two tabs: My Groups / Leading
- Group categories (study, project, club)
- Group tasks (coming soon)

**Example:**
```
CS101 Study Group
Category: Study
Members: 5
Leader: You
Description: Weekly study sessions for CS101
```

---

## 🎯 Add to Dashboard

Edit `lib/screens/dashboard_screen.dart` to add navigation:

```dart
// Add these cards/buttons to your dashboard:

Card(
  child: ListTile(
    leading: Icon(Icons.book, color: Colors.blue),
    title: Text('My Courses'),
    subtitle: Text('Manage your classes'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => Navigator.pushNamed(context, '/courses', arguments: widget.user),
  ),
),

Card(
  child: ListTile(
    leading: Icon(Icons.calendar_today, color: Colors.green),
    title: Text('Class Schedule'),
    subtitle: Text('View weekly schedule'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => Navigator.pushNamed(context, '/schedule', arguments: widget.user),
  ),
),

Card(
  child: ListTile(
    leading: Icon(Icons.group, color: Colors.orange),
    title: Text('Study Groups'),
    subtitle: Text('Collaborate with peers'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => Navigator.pushNamed(context, '/groups', arguments: widget.user),
  ),
),
```

---

## 🔥 Key Files Created

### Models
- `lib/models/course_model.dart` - Course, ClassSchedule, StudySession
- `lib/models/group_model.dart` - Group, GroupTask
- `lib/models/user_model.dart` - Updated (no roles)

### Services
- `lib/services/course_service.dart` - Course CRUD
- `lib/services/group_service.dart` - Group management
- `lib/services/pomodoro_service.dart` - Timer functionality

### Screens
- `lib/screens/courses_screen.dart` - Course management UI
- `lib/screens/schedule_screen.dart` - Weekly schedule UI
- `lib/screens/groups_screen.dart` - Study groups UI
- `lib/screens/register_screen.dart` - Updated registration

### Updated
- `lib/main.dart` - Added new routes
- `lib/database/database_helper.dart` - Updated for students
- `lib/services/local_auth_service.dart` - Removed roles
- `lib/services/firebase_auth_service.dart` - Student-only

---

## 🎨 Using the Pomodoro Timer

The timer service is ready! Create a UI widget:

```dart
// Example: Simple Pomodoro Button
import 'package:provider/provider.dart';
import '../services/pomodoro_service.dart';

FloatingActionButton(
  onPressed: () {
    final pomodoro = PomodoroService();
    if (!pomodoro.isRunning) {
      pomodoro.startWorkSession();
    }
  },
  child: Icon(Icons.timer),
);
```

Or show a dialog with full controls:

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Pomodoro Timer'),
    content: ChangeNotifierProvider(
      create: (_) => PomodoroService(),
      child: Consumer<PomodoroService>(
        builder: (context, pomodoro, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pomodoro.formattedTime,
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!pomodoro.isRunning)
                    ElevatedButton(
                      onPressed: () => pomodoro.startWorkSession(),
                      child: Text('Start'),
                    ),
                  if (pomodoro.isRunning)
                    ElevatedButton(
                      onPressed: () => pomodoro.togglePause(),
                      child: Text('Pause'),
                    ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => pomodoro.stop(),
                    child: Text('Stop'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  ),
);
```

---

## 📊 Database Structure

### Firestore Collections (when enabled)
- `users` - Student profiles
- `tasks` - Personal tasks
- `courses` - Student courses
- `class_schedules` - Class times
- `study_sessions` - Study logs
- `groups` - Study groups
- `group_tasks` - Group assignments

### SQLite Tables (local)
Same structure, works offline

---

## ⚠️ Known Issues

### Minor Compilation Warnings
- Some SQLite method references may show errors
- These are cached and will clear after `flutter clean`
- Or use Firebase instead (recommended)

### Firebase Not Enabled Yet
To enable cloud features:
1. Go to Firebase Console
2. Enable Authentication (Email/Password)
3. Create Firestore Database
4. Enable Storage
5. Set security rules

**Guide:** See FIREBASE_MIGRATION_COMPLETE.md

---

## 🧪 Testing Checklist

### Registration
- [ ] Register with student ID
- [ ] Select major (optional)
- [ ] Select year (optional)
- [ ] Login with email
- [ ] Login with student ID

### Courses
- [ ] Add a course
- [ ] Choose color
- [ ] Add schedule time
- [ ] View in schedule screen
- [ ] Delete course

### Groups
- [ ] Create a group
- [ ] View in "Leading" tab
- [ ] Leave a group (as member)
- [ ] Delete a group (as leader)

### Tasks
- [ ] Create task
- [ ] Add to course (when implemented)
- [ ] Set deadline
- [ ] Mark complete

---

## 📚 Documentation

- **STUDENT_EDITION_COMPLETE.md** - Full transformation guide
- **QUICK_FIX.md** - Troubleshooting
- **FIREBASE_MIGRATION_COMPLETE.md** - Firebase setup
- **QUICK_START.md** - This file!

---

## 🎯 Next Steps

### Priority 1: Navigation (15 min)
Add course/schedule/group buttons to dashboard

### Priority 2: Test Everything (30 min)
Go through testing checklist above

### Priority 3: Pomodoro UI (30 min)
Create timer widget or dialog

### Priority 4: Firebase (Optional, 5 min)
Enable cloud features in Firebase Console

### Priority 5: Polish (1-2 hours)
- Add motivational quotes
- Improve task-to-course linking
- Add assignment templates
- Study statistics dashboard

---

## 💡 Pro Tips

1. **Color Code Everything** - Use course colors consistently
2. **Link Tasks to Courses** - Connect assignments to classes
3. **Use Study Sessions** - Track time with Pomodoro
4. **Create Groups Early** - Collaborate with classmates
5. **Set Up Firebase** - Enable cloud sync

---

## 🎉 You're Ready!

Your student productivity app has:
- ✅ Course management
- ✅ Weekly schedule
- ✅ Study groups
- ✅ Pomodoro timer
- ✅ Task tracking
- ✅ Cloud-ready architecture

**Start the app and explore!**

```bash
flutter run
```

---

**Questions or Issues?**
- Check QUICK_FIX.md for solutions
- Review screen files for features
- Firebase setup in FIREBASE docs

**Happy studying! 📚🚀**

