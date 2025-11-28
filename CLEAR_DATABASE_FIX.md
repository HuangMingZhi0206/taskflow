# 🔧 QUICK FIX - Delete Old Database

The registration error persists because the old database (version 1) is still in use.

## ✅ SOLUTION: Clear App Data & Restart

### Step-by-Step (30 seconds):

#### Option 1: Clear in Emulator (Easiest)

1. **In the emulator**, press the **Home** button (●)
2. Open **Settings** (⚙️ gear icon)
3. Scroll to **Apps** → **TaskFlow**
4. Tap **Storage & cache**
5. Tap **Clear storage** (or **Clear data**)
6. Tap **OK** to confirm

#### Option 2: Reinstall App (Clean)

In your PowerShell terminal:
```powershell
# Press 'q' to quit the app
q

# Uninstall old app
flutter clean

# Run fresh install
flutter run
```

#### Option 3: ADB Command (Fast)

```powershell
# In a NEW PowerShell window:
adb shell pm clear kej.com.taskflow

# Then press 'R' in the Flutter terminal
```

---

## ⚠️ Why Hot Restart Doesn't Work

- **Hot Restart (`R`)** = Reloads Dart code only
- **Database upgrade** = Only triggers on FULL app restart when database file is opened
- The old database file (version 1) is still cached in memory

---

## ✅ After Clearing Data:

1. Open the app (it will auto-restart)
2. You'll see a fresh login screen
3. Click **"Create Account"**
4. Fill in the form:
   ```
   Name: Test User
   Student ID: STU001  
   Email: test@example.com
   Password: test123
   ```
5. Click **Register**

**Result:** ✅ User registered successfully!

---

## 🎯 What Will Happen:

When you clear app data and restart:
1. Old database deleted ✅
2. New database created with version 2 ✅
3. Schema includes `role` and `position` columns ✅
4. Registration will work perfectly ✅

---

**👉 CLEAR APP DATA NOW (Settings → Apps → TaskFlow → Storage → Clear Data)**

Then try registering again! 🚀

