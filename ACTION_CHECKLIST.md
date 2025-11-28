# ✅ TaskFlow Student Edition - Action Checklist

## 🎯 What to Do Next

Use this checklist to complete your student productivity app!

---

## Phase 1: Get It Running (10 minutes)

### Step 1: Clean Build
```bash
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
flutter clean
flutter pub get
```
- [ ] Run commands
- [ ] Wait for completion
- [ ] No errors

### Step 2: Test Run
```bash
flutter run
```
- [ ] App launches
- [ ] Registration screen shows
- [ ] Can navigate to login

### Step 3: Test Registration
- [ ] Click "Sign Up"
- [ ] Fill form with:
  - Name: Test Student
  - Student ID: STU12345
  - Email: test@student.edu
  - Major: Computer Science (optional)
  - Year: Sophomore (optional)
  - Password: test123
- [ ] Registration succeeds
- [ ] Redirected to login

### Step 4: Test Login
- [ ] Login with email: test@student.edu
- [ ] Dashboard loads
- [ ] No crashes

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Phase 2: Add Dashboard Navigation (15 minutes)

### File to Edit: `lib/screens/dashboard_screen.dart`

### Add These Navigation Cards

Find the dashboard body and add:

```dart
// Around line 100-150, in the body of the Scaffold
// Add this after existing dashboard content:

Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '🎓 Student Tools',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      
      // Courses Card
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.book, color: Colors.white),
          ),
          title: const Text('My Courses'),
          subtitle: const Text('Manage your classes'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.pushNamed(
            context,
            '/courses',
            arguments: widget.user,
          ),
        ),
      ),
      const SizedBox(height: 8),
      
      // Schedule Card
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.calendar_today, color: Colors.white),
          ),
          title: const Text('Class Schedule'),
          subtitle: const Text('View weekly schedule'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.pushNamed(
            context,
            '/schedule',
            arguments: widget.user,
          ),
        ),
      ),
      const SizedBox(height: 8),
      
      // Groups Card
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.group, color: Colors.white),
          ),
          title: const Text('Study Groups'),
          subtitle: const Text('Collaborate with peers'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.pushNamed(
            context,
            '/groups',
            arguments: widget.user,
          ),
        ),
      ),
    ],
  ),
),
```

### Checklist
- [ ] Open `lib/screens/dashboard_screen.dart`
- [ ] Find the body section
- [ ] Add the navigation cards code
- [ ] Save file
- [ ] Hot reload app
- [ ] Test each navigation button
- [ ] Verify screens load correctly

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Phase 3: Test Core Features (20 minutes)

### Test Course Management
- [ ] Navigate to Courses screen
- [ ] Click FAB (+) button
- [ ] Add course:
  - Code: CS101
  - Name: Intro to Programming
  - Instructor: Dr. Smith
  - Color: Blue
- [ ] Course appears in list
- [ ] Click "Add Schedule"
- [ ] Add schedule:
  - Day: Monday
  - Start: 9:00 AM
  - End: 10:30 AM
- [ ] Save schedule
- [ ] Add another course (MATH202)
- [ ] Test delete course

### Test Schedule Screen
- [ ] Navigate to Schedule screen
- [ ] See Monday section
- [ ] CS101 class shows 9:00-10:30
- [ ] Color matches course
- [ ] Room info displays
- [ ] Can delete schedule item

### Test Study Groups
- [ ] Navigate to Groups screen
- [ ] Click FAB (+) button
- [ ] Create group:
  - Name: CS101 Study Group
  - Description: Weekly study sessions
  - Category: Study
- [ ] Group appears in "Leading" tab
- [ ] Switch to "My Groups" tab
- [ ] Group also appears there
- [ ] Click group to view details
- [ ] Test delete (as leader)

### Test Navigation
- [ ] All screens accessible from dashboard
- [ ] Back button works on each screen
- [ ] No crashes when navigating
- [ ] User data persists across screens

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete

---

## Phase 4: Optional - Firebase Setup (5 minutes)

### Only if you want cloud sync

### Step 1: Enable Authentication
1. Go to: https://console.firebase.google.com/project/taskflow-49dbe/authentication
2. Click "Get Started"
3. Select "Email/Password"
4. Toggle enable
5. Click "Save"

- [ ] Authentication enabled

### Step 2: Create Firestore
1. Go to: https://console.firebase.google.com/project/taskflow-49dbe/firestore
2. Click "Create database"
3. Choose "Production mode"
4. Region: asia-southeast1
5. Click "Enable"

- [ ] Firestore created

### Step 3: Set Firestore Rules
In Rules tab, paste:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Click "Publish"

- [ ] Rules set

### Step 4: Enable Storage
1. Go to: https://console.firebase.google.com/project/taskflow-49dbe/storage
2. Click "Get Started"
3. Production mode
4. Same region
5. Click "Done"

- [ ] Storage enabled

### Step 5: Set Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Click "Publish"

- [ ] Storage rules set

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete | ⬜ Skipped (using SQLite only)

---

## Phase 5: Polish & Enhancement (Optional, 1-2 hours)

### Pomodoro Timer Widget (30 min)
Create `lib/widgets/pomodoro_timer_widget.dart`

- [ ] Create file
- [ ] Implement timer UI
- [ ] Add to dashboard
- [ ] Test start/stop/pause

### Task-to-Course Linking (20 min)
Edit `lib/screens/add_task_screen.dart`

- [ ] Add course dropdown
- [ ] Load user's courses
- [ ] Save course link with task
- [ ] Display course in task list

### Assignment Templates (30 min)
- [ ] Add template selector to add task
- [ ] Templates: Essay, Lab, Exam Prep, Reading
- [ ] Pre-fill fields based on template
- [ ] Test each template

### Student Branding (20 min)
- [ ] Update app subtitle to "Student Productivity Hub"
- [ ] Add encouraging messages
- [ ] Add emoji to key sections
- [ ] Test dark/light themes

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete | ⬜ Planned for Later

---

## Phase 6: Deployment (Optional)

### Build Release APK
```bash
flutter build apk --release
```

- [ ] APK builds successfully
- [ ] Located at: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Test APK on device
- [ ] No crashes
- [ ] All features work

### Share with Friends
- [ ] Transfer APK to friends
- [ ] They can install and test
- [ ] Gather feedback
- [ ] Fix any reported issues

**Status:** ⬜ Not Started | ⏳ In Progress | ✅ Complete | ⬜ Planned for Later

---

## 🎯 Priority Order

### Must Do Now
1. ✅ Phase 1: Get It Running (10 min)
2. ✅ Phase 2: Dashboard Navigation (15 min)
3. ✅ Phase 3: Test Features (20 min)

### Do Soon
4. ⏳ Phase 4: Firebase Setup (5 min) - Optional but recommended

### Do Later
5. ⏳ Phase 5: Polish (1-2 hours) - When you have time
6. ⏳ Phase 6: Deployment - When ready to share

---

## 🆘 Troubleshooting

### App Won't Build
```bash
flutter clean
flutter pub get
flutter run
```

### Navigation Not Working
- Check `main.dart` has routes defined
- Verify arguments are passed correctly
- Check for typos in route names

### Screens Show Errors
- Verify Firebase config (if using Firebase)
- Check user object structure
- Look at console output for details

### SQLite Errors
- These are minor and can be ignored
- Or follow QUICK_FIX.md solutions
- Or use Firebase instead

---

## 📊 Progress Tracker

Track your completion:

- [ ] Phase 1: Get It Running
- [ ] Phase 2: Dashboard Navigation
- [ ] Phase 3: Test Features
- [ ] Phase 4: Firebase Setup (optional)
- [ ] Phase 5: Polish (optional)
- [ ] Phase 6: Deployment (optional)

### Estimated Time
- **Minimum:** 45 minutes (Phases 1-3)
- **Recommended:** 50 minutes (Phases 1-4)
- **Complete:** 2-3 hours (All phases)

---

## 🎉 When You're Done

You'll have:
- ✅ Working student productivity app
- ✅ Course management system
- ✅ Class schedule viewer
- ✅ Study group collaboration
- ✅ Task management
- ✅ Cloud sync (if Firebase enabled)

### Share Your Success! 🎓

Your app is now ready for real use by students!

---

## 📚 Reference Documents

- **QUICK_START.md** - Quick reference
- **STUDENT_EDITION_COMPLETE.md** - Full guide
- **QUICK_FIX.md** - Troubleshooting
- **This file** - Action checklist

---

**Start with Phase 1 now! ⬇️**

```bash
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
flutter clean
flutter pub get
flutter run
```

**Good luck! 🚀**

