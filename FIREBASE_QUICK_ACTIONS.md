# 🚀 Firebase Quick Actions

## ⚡ Quick Commands

### Build & Run
```bash
# Clean and run
flutter clean && flutter pub get && flutter run

# Build APK
flutter build apk --release

# Check for errors
flutter analyze

# View logs
flutter logs
```

### Gradle Commands
```bash
cd android
./gradlew clean
./gradlew :app:assembleDebug
cd ..
```

---

## 🔥 Firebase Console Quick Links

### Your Project
**Project ID:** `taskflow-49dbe`

### Direct Links (Login Required)
- **Console Home:** https://console.firebase.google.com/project/taskflow-49dbe
- **Authentication:** https://console.firebase.google.com/project/taskflow-49dbe/authentication/users
- **Firestore:** https://console.firebase.google.com/project/taskflow-49dbe/firestore
- **Storage:** https://console.firebase.google.com/project/taskflow-49dbe/storage
- **Analytics:** https://console.firebase.google.com/project/taskflow-49dbe/analytics

---

## 📋 Setup Checklist (Do Once)

### 1. Enable Firebase Authentication
1. Go to Authentication in Firebase Console
2. Click "Get Started"
3. Select "Email/Password" sign-in method
4. Enable it and save

### 2. Create Firestore Database
1. Go to Firestore Database
2. Click "Create Database"
3. Choose "Start in production mode"
4. Select nearest location (e.g., asia-southeast1)
5. Click "Enable"

### 3. Set Firestore Rules
Copy this to Rules tab:
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

### 4. Set Up Storage
1. Go to Storage
2. Click "Get Started"
3. Start in production mode
4. Use same location as Firestore

### 5. Set Storage Rules
Copy this to Rules tab:
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

---

## 🧪 Testing Flow

### 1. First Time Setup
```bash
# Make sure everything is clean
flutter clean
flutter pub get

# Run the app
flutter run
```

### 2. Register Test User
- Open app
- Click Register
- Fill in:
  - Name: "Test Student"
  - Email: "test@student.com"
  - Student ID: "2024001"
  - Password: "password123"

### 3. Verify in Firebase
- Open Firebase Console → Authentication
- You should see test@student.com listed

### 4. Create Test Task
- Login with test account
- Create a new task
- Add title, description, deadline
- Select priority

### 5. Verify in Firestore
- Open Firebase Console → Firestore
- Check "tasks" collection
- You should see your task

---

## 🐛 Common Issues & Fixes

### "Could not resolve firebase dependencies"
```bash
cd android
./gradlew --refresh-dependencies
cd ..
flutter clean
flutter pub get
```

### "No Firebase App '[DEFAULT]' has been created"
- Check `google-services.json` is in `android/app/`
- Verify package name matches
- Rebuild the app

### "Permission Denied" in Firestore
- Check Firestore Rules allow authenticated users
- Make sure user is logged in
- Check Firebase Console logs

### Build fails with "Duplicate class found"
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📊 View Your Data

### Firestore Collections Structure
```
users/
  {userId}/
    - name, email, studentId, role, etc.

tasks/
  {taskId}/
    - title, description, priority, status
    - subtasks/ (subcollection)
    - comments/ (subcollection)

tags/
  {tagId}/
    - name, color

notifications/
  {userId}/
    userNotifications/
      {notificationId}/
```

### How to View Data
1. Go to Firestore Console
2. Click on a collection name (e.g., "users")
3. Click on a document ID to see details
4. Expand subcollections to see nested data

---

## 🎯 Student Edition Features To Add

### Phase 1: Basic Student Features
- [ ] Add default course tags (CS101, MATH202, etc.)
- [ ] Customize dashboard for student view
- [ ] Add "Today's Tasks" quick view

### Phase 2: Study Tools
- [ ] Pomodoro timer integration
- [ ] Study session tracking
- [ ] Break reminders

### Phase 3: Analytics
- [ ] Hours per course visualization
- [ ] Deadline pressure chart
- [ ] Completion rate tracking

### Phase 4: Polish
- [ ] Motivational quotes
- [ ] Achievement badges
- [ ] Study streaks

---

## 🔐 Security Best Practices

### For Development
- Use test Firebase project
- Don't commit `google-services.json` to public repos
- Use simple rules for testing

### For Production
- Implement proper security rules
- Validate data on server side
- Use Firebase App Check
- Enable email verification
- Set up rate limiting

---

## 📱 Testing on Different Devices

### Emulator
```bash
# List emulators
flutter emulators

# Run specific emulator
flutter emulators --launch <emulator_id>

# Run app on emulator
flutter run
```

### Physical Device
```bash
# Enable USB debugging on phone
# Connect via USB
# Run
flutter run

# Or build APK and install manually
flutter build apk
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📈 Monitor Your App

### Firebase Console Monitoring
- **Authentication:** See user signups and logins
- **Firestore:** View database operations and data
- **Storage:** Check uploaded files
- **Analytics:** Track user engagement (auto-enabled)

### Flutter Logs
```bash
# View real-time logs
flutter logs

# Filter by tag
flutter logs | grep "Firebase"
```

---

## 🎓 Learn More

### Firebase Documentation
- [Get Started](https://firebase.google.com/docs/flutter/setup)
- [Authentication](https://firebase.google.com/docs/auth)
- [Firestore](https://firebase.google.com/docs/firestore)
- [Storage](https://firebase.google.com/docs/storage)

### Flutter + Firebase
- [FlutterFire](https://firebase.flutter.dev/)
- [Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)

---

**✨ You're all set! Start building amazing student productivity features!**

