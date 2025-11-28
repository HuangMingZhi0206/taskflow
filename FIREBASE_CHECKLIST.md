# ✅ Firebase Setup Checklist - Quick Reference

Print this and check off as you complete each step!

---

## 📥 STEP 1: Download Config File

**URL:** https://console.firebase.google.com/project/taskflow-49dbe/settings/general

- [ ] Opened Firebase Console
- [ ] Clicked "Add app" → Android (if needed)
- [ ] Entered package name: `kej.com.taskflow`
- [ ] Downloaded `google-services.json`
- [ ] Placed file at: `android\app\google-services.json`

**Verify:** File exists at correct location with correct name (no .txt extension!)

---

## 🔐 STEP 2: Enable Authentication

**URL:** https://console.firebase.google.com/project/taskflow-49dbe/authentication

- [ ] Clicked "Authentication" in sidebar
- [ ] Clicked "Get started"
- [ ] Selected "Email/Password"
- [ ] Toggled "Enable" switch
- [ ] Clicked "Save"

**Verify:** Email/Password shows as "Enabled" in sign-in methods

---

## 💾 STEP 3: Enable Firestore

**URL:** https://console.firebase.google.com/project/taskflow-49dbe/firestore

- [ ] Clicked "Firestore Database" in sidebar
- [ ] Clicked "Create database"
- [ ] Selected "Start in test mode"
- [ ] Selected location: "asia-southeast2 (Jakarta)"
- [ ] Clicked "Enable"

**Verify:** Can see "Cloud Firestore" page with empty collections

---

## 📁 STEP 4: Enable Storage

**URL:** https://console.firebase.google.com/project/taskflow-49dbe/storage

- [ ] Clicked "Storage" in sidebar
- [ ] Clicked "Get started"
- [ ] Selected "Start in test mode"
- [ ] Clicked "Done"

**Verify:** Can see empty storage bucket

---

## ⚙️ STEP 5: Configure (OPTIONAL)

**In PowerShell:**

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --project=taskflow-49dbe
```

- [ ] Ran first command
- [ ] Ran second command
- [ ] Selected platforms (Android)
- [ ] Configuration completed

**Verify:** `firebase_options.dart` updated with real API keys

---

## 🏗️ STEP 6: Build & Run

**In PowerShell:**

```powershell
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
flutter clean
flutter pub get
flutter run
```

- [ ] Ran flutter clean
- [ ] Ran flutter pub get (no errors)
- [ ] Ran flutter run
- [ ] App launched successfully

**Verify:** App opens to login screen

---

## 🧪 STEP 7: Test Features

- [ ] **Register:** Created new account with student ID
- [ ] **Login:** Logged in with email
- [ ] **Login:** Logged in with student ID
- [ ] **Task:** Created new task
- [ ] **Task:** Updated task status
- [ ] **Task:** Deleted task
- [ ] **Subtask:** Added subtask
- [ ] **Tag:** Added tag to task
- [ ] **Logout:** Logged out successfully

**Verify:** All features work without errors

---

## 🔒 STEP 8: Check Firebase Console

- [ ] **Firestore:** Can see tasks in `/tasks` collection
- [ ] **Firestore:** Can see user in `/users` collection
- [ ] **Firestore:** Can see tags in `/tags` collection
- [ ] **Auth:** Can see registered user in Authentication > Users
- [ ] **Usage:** No errors in console

**Verify:** Data appears in Firebase Console

---

## 📊 TROUBLESHOOTING

### ❌ Build fails with "Plugin not found"
```powershell
flutter clean
flutter pub get
```

### ❌ "No Firebase App" error
- Check: `google-services.json` in `android\app\` (not `android\`)
- Run: `flutter clean && flutter pub get`

### ❌ "Permission denied" in Firestore
- Check: Rules are in "test mode"
- Check: User is logged in before accessing data

### ❌ Build takes forever
```powershell
cd android
./gradlew --stop
cd ..
flutter clean
flutter pub get
```

---

## ✅ SUCCESS CRITERIA

You're done when:
- ✅ App builds without errors
- ✅ Can register new account
- ✅ Can login with email or student ID
- ✅ Can create and view tasks
- ✅ Data appears in Firebase Console
- ✅ No errors in app or console

---

## 📞 NEED HELP?

**Documentation:**
- Detailed guide: `FIREBASE_MIGRATION_GUIDE.md`
- Quick setup: `FIREBASE_QUICK_SETUP.md`
- Summary: `FIREBASE_SUMMARY.md`

**Firebase Console:**
- Project: https://console.firebase.google.com/project/taskflow-49dbe

**Error?** Tell me:
1. Which step you're on
2. Exact error message
3. What you've tried

---

## ⏱️ TIME TRACKING

- Step 1-4: _____ minutes (estimate: 10 min)
- Step 5: _____ minutes (estimate: 3 min)
- Step 6: _____ minutes (estimate: 2 min)
- Step 7-8: _____ minutes (estimate: 5 min)

**Total: ~20 minutes**

---

## 📝 NOTES

Problems encountered:
_________________________________
_________________________________
_________________________________

Solutions applied:
_________________________________
_________________________________
_________________________________

---

**Date completed:** _______________

**Tested by:** _______________

**Status:** ☐ Complete ☐ Issues ☐ Need help

---

**Next:** Update security rules before production (see `FIREBASE_MIGRATION_GUIDE.md`)

---

✨ **Print this checklist and check off each item as you complete it!** ✨

