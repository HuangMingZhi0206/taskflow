# TaskFlow 

**TaskFlow** is a comprehensive productivity application built with Flutter, designed to help you organize tasks, manage your schedule, and stay focused using the Pomodoro technique.

## Key Features

### Smart Pomodoro Timer
- **Continuous Flow**: Automatically switches between Focus, Short Break, and Long Break modes.
- **Customizable**: Adjust durations and the number of intervals ("sections") before a long break.
- **Background Notifications**: Get notified with sound and alerts even when the app is in the background.
- **Visual Tracking**: Track your progress with visual interval dots (● ● ○ ○).
- **Task Labeling**: Set a specific task intention for each focus session.

### Task Management
- Create, Read, Update, and Delete tasks.
- Categorize tasks with tags and priority.
- Track completion status.

### Schedule & Calendar
- View your tasks in a Daily, Weekly, or Monthly calendar view.
- Plan your day effectively with a clear timeline.

### Dashboard & Stats
- Overview of your pending and completed tasks.
- Visual statistics (using FL Chart) to monitor productivity.

## Tech Stack

- **Framework**: Flutter (Dart)
- **Backend Service**: Firebase (Firestore, Auth)
- **Local Storage**: Shared Preferences
- **Notifications**: Flutter Local Notifications
- **Charts**: FL Chart

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/HuangMingZhi0206/taskflow.git
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**:
    -   Ensure you have your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) in the respective `android/app` or `ios/Runner` directories.

4.  **Run the App**:
    ```bash
    flutter run
    ```

## Screenshots

| Home | Pomodoro | Schedule |
|------|----------|----------|
| ![Home](assets/home.png) | ![Pomodoro](assets/pomodoro.png) | ![Schedule](assets/schedule.png) |

*(Note: Add screenshot files to your assets folder to view them here)*
    
## Flutter Build App

To turn your code into an app you can share:

1.  **Analyze dependencies**
    ```bash
    flutter pub get
    ```

2.  **Build the APK**
    // turbo
    ```bash
    flutter build apk --release
    ```
    *This might take a few minutes.*

3.  **Rename the File**
    Run this command to naming it nicely:
    ```bash
    Move-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "build\app\outputs\flutter-apk\Taskflow.apk" -Force
    ```

4.  **Find the File**
    Go to: `build\app\outputs\flutter-apk\`
    Look for: `Taskflow.apk`

5.  **Share**
    Send that file to your friend's phone. They can install it directly.