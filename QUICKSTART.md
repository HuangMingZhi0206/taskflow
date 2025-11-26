# TaskFlow - Quick Start Guide

Get up and running with TaskFlow in 5 minutes!

## 🚀 Quick Setup (Android Studio)

### Step 1: Open the Project
1. Open Android Studio
2. Click "Open an Existing Project"
3. Navigate to `C:\Users\ASUS\AndroidStudioProjects\taskflow`
4. Click "OK"

### Step 2: Install Dependencies
1. Wait for Android Studio to load the project
2. Look for the banner at the top saying "Pub get has not been run"
3. Click **"Get dependencies"** or **"Pub get"**
4. Wait for the process to complete (you'll see "Process finished" in the bottom panel)

### Step 3: Select a Device
1. Click the device dropdown in the toolbar (next to the Run button)
2. Options:
   - **Physical Device**: Enable USB debugging and connect via USB
   - **Emulator**: Click "Create Device" to set up an Android emulator

### Step 4: Run the App
1. Click the green **Run** button (▶️) in the toolbar
2. Or press `Shift + F10`
3. Wait for the app to build and install
4. The app will automatically open on your device/emulator

## 📱 First Time Usage

### Login with Demo Accounts

**Option 1: Quick Login (Recommended)**
- On the login screen, use the quick login buttons:
  - **"Login as Manager"** - Full access to create and manage tasks
  - **"Login as Staff"** - View assigned tasks and submit reports

**Option 2: Manual Login**

**Manager Account:**
```
Email: manager@taskflow.com
Password: manager123
```

**Staff Account:**
```
Email: staff@taskflow.com
Password: staff123
```

## 🎯 Quick Tour

### As a Manager:
1. **Dashboard**: View all tasks in the system
2. **Create Task**: Tap the floating "+" button
   - Fill in task details (title, description)
   - Select priority (Urgent/Medium/Low)
   - Choose a deadline
   - Assign to a team member
   - Tap "Create Task"
3. **View Details**: Tap any task card to see details
4. **Delete Task**: Tap the trash icon on a task card

### As a Staff Member:
1. **Dashboard**: View tasks assigned to you
2. **Filter Tasks**: Use the chips at the top (All, To Do, In Progress, Done)
3. **Update Status**: Open a task → Tap "Start Task" or "Complete"
4. **Add Progress Report**: Open a task → Type update → Tap send icon
5. **Pull to Refresh**: Swipe down to reload tasks

## ⚡ Common Actions

### Creating Your First Task (Manager)
1. Login as manager
2. Tap the blue "Add Task" floating button
3. Enter:
   - Title: "Test Task"
   - Description: "This is a test task"
   - Priority: Select "Medium"
   - Deadline: Select any future date
   - Assign to: Select "Jane Staff"
4. Tap "Create Task"
5. You'll see the task in the dashboard

### Updating Task Status (Staff)
1. Login as staff (staff@taskflow.com / staff123)
2. Tap on a task assigned to you
3. Tap "Start Task" button
4. The status changes to "In Progress"
5. Tap "Complete" when done
6. Status changes to "Done" ✓

### Adding a Progress Report (Staff)
1. Open a task you're assigned to
2. Scroll to "Progress Reports" section
3. Type your update in the text field
4. Tap the send icon (➤)
5. Your report appears below with timestamp

## 🔧 Troubleshooting Quick Fixes

### "Pub get has not been run"
**Fix**: Click "Get dependencies" in the yellow banner at the top

### App not installing
**Fix**: 
1. Go to `File → Invalidate Caches / Restart`
2. Select "Invalidate and Restart"
3. Try running again

### "No devices found"
**Fix for Emulator**:
1. Go to `Tools → Device Manager`
2. Click "Create Device"
3. Select a phone model → Next
4. Select a system image (API 30+) → Next
5. Click "Finish"
6. Click the play button next to your device

**Fix for Physical Device**:
1. Enable Developer Options on your Android phone
2. Enable USB Debugging
3. Connect via USB
4. Allow USB debugging when prompted
5. Device should appear in Android Studio

### "Target of URI doesn't exist: package:sqflite"
**Fix**: 
1. Open terminal in Android Studio (Alt + F12)
2. Run: `flutter pub get`
3. Wait for completion

### Database errors
**Fix**: 
1. Uninstall the app from device
2. Run again (database will be recreated)

## 📱 Testing Features

### Quick Test Scenario
1. **Login as Manager**
2. Create 3 tasks:
   - "Urgent Bug Fix" - Urgent priority → Assign to Jane Staff
   - "Feature Development" - Medium priority → Assign to Mike Developer
   - "Documentation" - Low priority → Assign to Jane Staff
3. **Logout** (tap logout icon)
4. **Login as Staff** (staff@taskflow.com)
5. See your 2 assigned tasks
6. Filter by "To Do"
7. Open "Urgent Bug Fix"
8. Tap "Start Task"
9. Add progress report: "Started investigating the issue"
10. Check the report appears
11. Tap "Complete"
12. **Pull down** to refresh
13. Filter by "Done" to see completed task

## 💡 Pro Tips

- **Quick Navigation**: Use the back button to return to dashboard
- **Pull to Refresh**: Swipe down on dashboard to reload tasks
- **Filter Smart**: Use filters to focus on specific task statuses
- **Clear Reports**: Progress reports show newest first
- **Visual Priority**: Red = Urgent, Orange = Medium, Green = Low
- **Status Colors**: Gray = To Do, Blue = In Progress, Green = Done

## 🎨 UI Navigation

```
Login Screen
    ↓
Dashboard (Main Screen)
    ├──> Add Task Screen (Managers only) ──> Dashboard
    └──> Task Detail Screen ──> Dashboard
            └──> Progress Reports Section
```

## 🔄 Reset to Default

If you want to start fresh:
1. Uninstall the app from your device
2. Reinstall by running from Android Studio
3. Database recreates with original demo data

## ❓ Need Help?

- Check the full [README.md](README.md) for detailed documentation
- Review the code comments for implementation details
- Test with demo accounts before creating new users

## 🎉 You're All Set!

You now know the basics of TaskFlow. Start creating and managing tasks!

**Enjoy using TaskFlow!** 🚀

