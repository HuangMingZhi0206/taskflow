# Firebase Quick Setup - TaskFlow

## 🚀 Quick Start (3 Steps)

### Step 1: Download Firebase Config
1. Go to: https://console.firebase.google.com/project/taskflow-49dbe/settings/general
2. Scroll to "Your apps" section
3. If you don't see an Android app:
   - Click "Add app" → Android icon
   - Enter package name: `kej.com.taskflow`
   - Click "Register app"
4. Download `google-services.json`
5. Copy it to: `android/app/google-services.json`

### Step 2: Enable Firebase Services
1. Go to Firebase Console: https://console.firebase.google.com/project/taskflow-49dbe
2. Enable these services:

**Authentication:**
- Click "Authentication" → "Get Started"
- Enable "Email/Password" method
- Click "Save"

**Firestore:**
- Click "Firestore Database" → "Create database"
- Select "Start in test mode"
- Choose location: "asia-southeast2 (Jakarta)"
- Click "Enable"

**Storage:**
- Click "Storage" → "Get Started"
- Select "Start in test mode"
- Click "Done"

### Step 3: Run the App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📦 What's Already Done

✅ Firebase packages added to pubspec.yaml
✅ Firebase services created (auth, firestore, storage)
✅ Data models created
✅ Build configuration updated
✅ Main.dart configured for Firebase initialization

---

## 🔐 Using FlutterFire CLI (Optional but Recommended)

This automates the configuration:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your project
flutterfire configure --project=taskflow-49dbe
```

This will:
- Generate proper `firebase_options.dart`
- Configure all platforms automatically
- Set up everything correctly

---

## 📝 Manual Alternative

If you don't want to use FlutterFire CLI:

1. Download `google-services.json` from Firebase Console
2. Extract the values and update `lib/firebase_options.dart`:
   - Find "api_key" → "current_key" → Copy to `apiKey`
   - Find "mobilesdk_app_id" → Copy to `appId`
3. Place `google-services.json` in `android/app/`

---

## ✅ Verification Checklist

After setup, verify:
- [ ] `google-services.json` is in `android/app/`
- [ ] Firebase Authentication is enabled
- [ ] Cloud Firestore is enabled
- [ ] Firebase Storage is enabled
- [ ] App builds without errors
- [ ] You can register a new account
- [ ] You can login
- [ ] You can create tasks

---

## 🐛 Common Issues

**Build Error: "Plugin project :firebase_core not found"**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

**Error: "No Firebase App '[DEFAULT]' has been created"**
- Make sure `google-services.json` is in the correct location
- Run `flutter clean && flutter pub get`
- Restart your IDE

**Error: "Please authenticate to access Firestore"**
- Check if Authentication is enabled in Firebase Console
- Make sure you're using Email/Password method

---

## 🎯 What You Can Do Now

Once setup is complete:
- ✅ Register with student ID or email
- ✅ Login with student ID or email  
- ✅ Create tasks with deadlines
- ✅ Add subtasks and checklists
- ✅ Upload attachments
- ✅ Tag tasks with academic categories
- ✅ Track estimated study hours
- ✅ View statistics dashboard
- ✅ Sync data across devices (coming soon!)

---

## 📊 Firebase Console Quick Links

- **Project Overview:** https://console.firebase.google.com/project/taskflow-49dbe
- **Authentication:** https://console.firebase.google.com/project/taskflow-49dbe/authentication
- **Firestore:** https://console.firebase.google.com/project/taskflow-49dbe/firestore
- **Storage:** https://console.firebase.google.com/project/taskflow-49dbe/storage
- **Settings:** https://console.firebase.google.com/project/taskflow-49dbe/settings/general

---

## 🆘 Need Help?

See detailed guide: `FIREBASE_MIGRATION_GUIDE.md`

**Quick command to check if Firebase is properly configured:**
```bash
flutter doctor -v
```

---

**Ready to go? Just complete the 3 steps above and you're all set! 🚀**

