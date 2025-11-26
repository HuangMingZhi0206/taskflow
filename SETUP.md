# 🚀 SETUP INSTRUCTIONS - TaskFlow

## ⚡ IMPORTANT: Read This First!

The project is **100% complete** and ready to run. You just need to install dependencies.

---

## 🔧 Step-by-Step Setup (Android Studio)

### Step 1: Verify Project is Open
✅ You should see the project structure in the left panel  
✅ Files should be visible under `lib/`, `android/`, etc.

---

### Step 2: Install Dependencies (REQUIRED)

You'll see a yellow/blue banner at the top of the editor saying:
> **"Pub get has not been run"** or **"Packages get has not been run"**

**Click the "Get dependencies" or "Pub get" button in that banner.**

**What this does:**
- Downloads required packages (sqflite, path, intl)
- Configures the project
- Resolves all import errors

**Wait for it to complete** - you'll see in the bottom panel:
```
Running "flutter pub get" in taskflow...
Process finished with exit code 0
```

---

### Alternative: Manual Installation

If the banner doesn't appear, or you prefer terminal:

1. **Open Terminal in Android Studio**
   - Click `View` → `Tool Windows` → `Terminal`
   - Or press `Alt + F12`

2. **Run the command:**
   ```powershell
   flutter pub get
   ```

3. **Wait for completion** - you should see:
   ```
   Running "flutter pub get"...
   Resolving dependencies...
   Got dependencies!
   ```

---

### Step 3: Verify No Errors

After running `flutter pub get`:

1. Open `lib/main.dart`
2. Check that there are **NO red underlines**
3. All imports should be recognized
4. If you still see errors, try:
   - `File` → `Invalidate Caches / Restart`
   - Select "Invalidate and Restart"

---

### Step 4: Select a Device

In the toolbar, click the device dropdown (next to Run button):

**Option A: Use Android Emulator**
- If you see a device listed → Select it
- If no device: `Create Device` → Choose phone → Download system image → Finish

**Option B: Use Physical Device**
- Enable Developer Options on Android phone
- Enable USB Debugging
- Connect via USB
- Allow USB debugging when prompted
- Select device from dropdown

---

### Step 5: Run the Application

1. **Click the green Run button (▶️)** in the toolbar
2. Or press `Shift + F10`
3. Wait for build and installation (~1-2 minutes first time)
4. App launches automatically!

---

## 🎯 Quick Test After Launch

### Login Screen appears:

**Quick Test:**
1. Click **"Login as Manager"** button
2. You'll see the Dashboard with no tasks
3. Click the blue **"+ Add Task"** button
4. Fill in:
   - Title: "Test Task"
   - Description: "Testing the app"
   - Priority: Select any
   - Deadline: Select any date
   - Assign To: Select "Jane Staff"
5. Click **"Create Task"**
6. Task appears in dashboard! ✅

**App is working!** 🎉

---

## 🔍 Verifying Everything Works

### ✅ Checklist:
- [ ] No red errors in code files
- [ ] App builds successfully
- [ ] Login screen appears
- [ ] Can login with demo accounts
- [ ] Can navigate between screens
- [ ] Database operations work

### Test Each Feature:
1. **Login** - Try both manager and staff accounts
2. **Create Task** - As manager
3. **View Tasks** - See the created task
4. **Task Details** - Tap a task to open details
5. **Update Status** - As staff, start/complete a task
6. **Add Report** - Submit a progress update
7. **Filter** - Use filter chips (All, To Do, etc.)
8. **Delete** - Remove a task (manager only)

---

## ❌ Common Issues & Fixes

### Issue 1: "flutter command not found" in terminal
**This is OK!** Just use Android Studio's built-in tools:
- Click the "Pub get" banner
- Or use menu: `Tools` → `Flutter` → `Flutter Pub Get`

---

### Issue 2: Red errors after opening project
**Fix:** Run `flutter pub get`
- Either click the banner
- Or: `Tools` → `Flutter` → `Flutter Pub Get`

---

### Issue 3: "Target of URI doesn't exist" errors
**Cause:** Dependencies not installed  
**Fix:** Run `flutter pub get` (see Step 2)

---

### Issue 4: No devices available
**Fix for Emulator:**
1. Click device dropdown → `Create Device`
2. Select any phone model → Next
3. Download a system image (API 30+) → Next
4. Finish
5. Click play button next to device to start it

**Fix for Physical Device:**
1. Enable Developer Options on phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Go to Settings → Developer Options
3. Enable "USB Debugging"
4. Connect phone via USB
5. Allow debugging on phone when prompted

---

### Issue 5: Build fails
**Fix:**
1. `File` → `Invalidate Caches / Restart`
2. Select "Invalidate and Restart"
3. Wait for restart
4. Try running again

---

### Issue 6: Gradle sync issues
**Fix:**
1. `File` → `Sync Project with Gradle Files`
2. Wait for completion
3. Try again

---

## 📱 Expected First Run

### What happens:
1. **Build** (~60-90 seconds first time)
   - Gradle downloads dependencies
   - Flutter compiles app
   - Installs on device

2. **Database Initialization**
   - Creates `taskflow.db`
   - Creates 3 tables
   - Inserts demo users
   - All automatic!

3. **Login Screen Appears**
   - Ready to use!

---

## 🎓 Demo Accounts

Pre-configured accounts for testing:

| Role | Email | Password | Use Case |
|------|-------|----------|----------|
| Manager | manager@taskflow.com | manager123 | Create & manage tasks |
| Staff | staff@taskflow.com | staff123 | Work on assigned tasks |
| Staff | mike@taskflow.com | mike123 | Another team member |

---

## 🔄 If You Need to Start Fresh

### Reset Database:
1. Uninstall app from device
2. Run again from Android Studio
3. Database recreates with demo data

### Clean Build:
```bash
flutter clean
flutter pub get
flutter run
```

Or in Android Studio:
- `Build` → `Clean Project`
- `Build` → `Rebuild Project`

---

## 📂 File Check

Make sure these files exist:

```
✅ lib/main.dart
✅ lib/database/database_helper.dart
✅ lib/theme/app_theme.dart
✅ lib/screens/login_screen.dart
✅ lib/screens/dashboard_screen.dart
✅ lib/screens/add_task_screen.dart
✅ lib/screens/task_detail_screen.dart
✅ pubspec.yaml (with dependencies)
```

---

## 🎯 Success Indicators

### You'll know it's working when:
1. ✅ No compilation errors
2. ✅ App installs on device
3. ✅ Login screen appears
4. ✅ Can login with demo accounts
5. ✅ Dashboard loads
6. ✅ Can create and view tasks

---

## 💡 Pro Tips

### For Faster Development:
- **Hot Reload**: Press `Ctrl + \` or `Cmd + \` to update UI instantly
- **Hot Restart**: Press `Ctrl + Shift + \` for full restart
- **Save Auto-Reloads**: Changes apply automatically on save

### For Debugging:
- **View Logs**: `View` → `Tool Windows` → `Logcat`
- **Flutter Inspector**: `View` → `Tool Windows` → `Flutter Inspector`
- **Breakpoints**: Click left margin of code editor

---

## 📞 Need Help?

### Check these resources:
1. **PROJECT_SUMMARY.md** - Overview and status
2. **QUICKSTART.md** - Quick start guide
3. **README.md** - Full documentation
4. **API.md** - Database reference

### Common commands:
```bash
flutter doctor          # Check Flutter installation
flutter devices         # List available devices
flutter clean           # Clean build files
flutter pub get         # Get dependencies
flutter run             # Run the app
flutter build apk       # Build APK
```

---

## ✅ Final Checklist

Before running:
- [ ] Project opened in Android Studio
- [ ] `flutter pub get` completed successfully
- [ ] No red errors in files
- [ ] Device/emulator selected
- [ ] Ready to click Run!

After running:
- [ ] App installed successfully
- [ ] Login screen visible
- [ ] Can login with demo accounts
- [ ] Features work as expected

---

## 🎉 You're All Set!

The application is **complete and ready**. Just:
1. Install dependencies (`flutter pub get`)
2. Select device
3. Run!

**Enjoy exploring TaskFlow!** 🚀

---

**Need more details?** Check the other documentation files:
- Full features: `README.md`
- Quick demo: `QUICKSTART.md`
- Database info: `API.md`
- Deployment: `DEPLOYMENT.md`

