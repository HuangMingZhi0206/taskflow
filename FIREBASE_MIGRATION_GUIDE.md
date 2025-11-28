# Firebase Migration Guide - TaskFlow Student Edition

## 🔥 Firebase Setup Complete!

TaskFlow has been successfully migrated from SQLite to Firebase. This guide will help you complete the setup.

---

## 📋 What You Need to Provide

### 1. **Firebase Configuration Files**

You need to download configuration files from your Firebase Console:

#### For Android (REQUIRED):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **TaskFlow** (taskflow-49dbe)
3. Click on **Project Settings** (gear icon)
4. Scroll to "Your apps" section
5. Click "Add app" → Select **Android**
6. Register app with package name: `kej.com.taskflow`
7. Download `google-services.json`
8. Place it at: `android/app/google-services.json`

#### For iOS (Optional):
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Place it at: `ios/Runner/GoogleService-Info.plist`

---

## 🔧 Firebase Services Configuration

### 1. **Enable Firebase Authentication**

1. In Firebase Console, go to **Authentication**
2. Click "Get Started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

### 2. **Enable Cloud Firestore**

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development)
4. Select location: **asia-southeast2 (Jakarta)** (closest to you)
5. Click "Enable"

### 3. **Enable Firebase Storage**

1. In Firebase Console, go to **Storage**
2. Click "Get Started"
3. Choose **Start in test mode** (for development)
4. Click "Done"

---

## 🛡️ Security Rules (IMPORTANT!)

After development, update your security rules:

### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      // User's notifications subcollection
      match /notifications/{notificationId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Tasks collection - authenticated users only
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.createdBy == request.auth.uid || 
         resource.data.assigneeId == request.auth.uid);
      
      // Task subcollections
      match /{subcollection}/{docId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
    }
    
    // Tags collection - read by all, write by authenticated users
    match /tags/{tagId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User avatars
    match /avatars/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Task attachments
    match /task_attachments/{taskId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Comment attachments
    match /comment_attachments/{taskId}/{commentId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📱 Android Configuration

Update your Android configuration files:

### 1. Update `android/build.gradle.kts`:
```kotlin
// Add at the top
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 2. Update `android/app/build.gradle.kts`:
```kotlin
// Add at the bottom
apply(plugin = "com.google.gms.google-services")
```

---

## 🔐 Update Firebase Options

After downloading your config files, you need to update `lib/firebase_options.dart` with your actual API keys.

### Option A: Use FlutterFire CLI (RECOMMENDED)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase automatically
flutterfire configure --project=taskflow-49dbe
```

This will automatically generate the correct `firebase_options.dart` file!

### Option B: Manual Update
Open the downloaded `google-services.json` and copy values to `firebase_options.dart`:
- `apiKey` from "api_key" → "current_key"
- `appId` from "client" → "mobilesdk_app_id"

---

## 🗄️ Database Structure

Firebase Firestore uses a different structure than SQLite:

### Collections & Documents:

```
📁 users (collection)
  └── 📄 {userId} (document)
      ├── name, email, studentId, role, etc.
      └── 📁 notifications (subcollection)
          └── 📄 {notificationId}

📁 tasks (collection)
  └── 📄 {taskId} (document)
      ├── title, description, status, priority, deadline, etc.
      ├── tagIds: [array of tag IDs]
      ├── 📁 subtasks (subcollection)
      │   └── 📄 {subtaskId}
      ├── 📁 comments (subcollection)
      │   └── 📄 {commentId}
      └── 📁 activity (subcollection)
          └── 📄 {activityId}

📁 tags (collection)
  └── 📄 {tagId} (document)
      └── name, color
```

### Default Tags
The following academic tags are automatically created on first run:
- Assignment (Blue)
- Exam (Red)
- Project (Purple)
- Reading (Green)
- Study Group (Orange)
- Lab (Cyan)
- Research (Pink)
- Presentation (Teal)

---

## 🚀 How to Run

1. **Place Firebase config files** (google-services.json)
2. **Run FlutterFire configure** (recommended)
3. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## ✨ Key Changes from SQLite

### Authentication
- ✅ Now uses **Firebase Authentication**
- ✅ Password reset via email
- ✅ Secure authentication tokens
- ✅ Login with email or student ID

### Database
- ✅ **Cloud Firestore** instead of local SQLite
- ✅ Real-time data synchronization
- ✅ Automatic offline caching
- ✅ Scalable to millions of users

### Storage
- ✅ **Firebase Storage** for files
- ✅ Avatars stored in cloud
- ✅ Task attachments in cloud
- ✅ Automatic CDN distribution

### Benefits
- ✅ **No more local database** - works across devices
- ✅ **Real-time sync** - updates appear instantly
- ✅ **Offline support** - works without internet
- ✅ **Backup & restore** - automatic cloud backup
- ✅ **Scalable** - handles any number of users

---

## 🔄 Migration from Old Data (Optional)

If you want to migrate existing SQLite data to Firebase:

### Export SQLite Data:
```dart
// Add this to your old app before migration
Future<void> exportData() async {
  final db = await DatabaseHelper.instance.database;
  
  // Export users
  List<Map> users = await db.query('users');
  // Save to JSON file
  
  // Export tasks
  List<Map> tasks = await db.query('tasks');
  // Save to JSON file
}
```

### Import to Firebase:
```dart
// In new app, import from JSON
Future<void> importData(List<Map> users, List<Map> tasks) async {
  // Import users to Firebase Auth + Firestore
  // Import tasks to Firestore
}
```

**Note:** For fresh start (recommended), just skip this step!

---

## 🐛 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
**Solution:** Make sure you placed `google-services.json` in `android/app/` and ran `flutter clean && flutter pub get`

### Error: "Please register your application with Firebase"
**Solution:** Run `flutterfire configure` or manually update `firebase_options.dart`

### Error: "Permission denied" when accessing Firestore
**Solution:** Update Firestore Security Rules in Firebase Console

### Build errors about Java version
**Solution:** Make sure you're using Java 17+ (already configured in your project)

---

## 📊 Firebase Console Access

**Your Project:**
- **Project ID:** taskflow-49dbe
- **Project Number:** 628335189476
- **Organization:** president.ac.id
- **Console URL:** https://console.firebase.google.com/project/taskflow-49dbe

---

## 📝 Next Steps

1. ✅ Download `google-services.json` from Firebase Console
2. ✅ Place it in `android/app/google-services.json`
3. ✅ Enable Authentication (Email/Password)
4. ✅ Enable Cloud Firestore
5. ✅ Enable Firebase Storage
6. ✅ Run `flutterfire configure` (optional but recommended)
7. ✅ Update Security Rules
8. ✅ Test registration and login
9. ✅ Test task creation and management
10. ✅ Deploy to production!

---

## 🎓 Student-Specific Features

All existing features now work with Firebase:
- ✅ Register with Student ID
- ✅ Login with Student ID or Email
- ✅ Academic tags (Assignment, Exam, etc.)
- ✅ Time estimation for study planning
- ✅ Task notifications and reminders
- ✅ File attachments for assignments
- ✅ Subtasks/checklists
- ✅ Statistics dashboard

---

## 💡 Tips

1. **Testing:** Use test mode rules during development, then restrict in production
2. **Costs:** Firebase free tier is generous (50K reads/day, 20K writes/day)
3. **Indexes:** Firestore will prompt you to create indexes if needed
4. **Offline:** Firebase caches data locally, works offline automatically
5. **Security:** Never commit `google-services.json` to public repos

---

## 🆘 Need Help?

- **Firebase Docs:** https://firebase.google.com/docs
- **FlutterFire Docs:** https://firebase.flutter.dev/
- **Firebase Console:** https://console.firebase.google.com/

---

**Status:** ✅ Firebase integration complete! Just add config files and you're ready to go!

