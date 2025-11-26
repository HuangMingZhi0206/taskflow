# TaskFlow - Team Task Management Application

A modern, intuitive Flutter mobile application for managing team tasks and tracking progress.

## 📚 Documentation Index

- **[SETUP.md](SETUP.md)** - ⚡ Start here! Step-by-step setup instructions
- **[QUICKSTART.md](QUICKSTART.md)** - 🚀 Get running in 5 minutes
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - 📋 Complete project overview
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - 🏗️ Technical architecture & diagrams
- **[API.md](API.md)** - 💾 Database API reference
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - 📦 Build & deployment guide
- **[README.md](README.md)** - 📖 This file - Complete documentation

## ⚡ Quick Start

```bash
# 1. Install dependencies (in Android Studio or terminal)
flutter pub get

# 2. Run the app
flutter run

# 3. Login with demo accounts
Manager: manager@taskflow.com / manager123
Staff: staff@taskflow.com / staff123
```

## 📱 Features

- **Role-Based Authentication**: Separate access for Managers and Staff members
- **Task Management**: Create, assign, and track tasks with priorities
- **Status Tracking**: Monitor task progress (To Do, In Progress, Done)
- **Priority Levels**: Urgent, Medium, and Low priority categorization
- **Progress Reporting**: Team members can submit progress updates
- **Real-time Updates**: Pull-to-refresh for latest data
- **Clean UI**: Modern, minimalist design with intuitive navigation

## 🎨 Design Highlights

- **Color Palette**: Professional indigo primary with semantic colors
- **Responsive Layouts**: Optimized for various screen sizes
- **Smooth Navigation**: Intuitive screen transitions
- **Visual Feedback**: Clear status indicators and loading states

## 🛠️ Technology Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart
- **Database**: SQLite (via sqflite package)
- **State Management**: StatefulWidget with local state
- **Date Formatting**: intl package

## 📋 Prerequisites

- Flutter SDK 3.10 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development (macOS only)

## 🚀 Getting Started

### 1. Clone or Open the Project

```bash
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
```

### 2. Install Dependencies

In Android Studio:
- Open the project
- Wait for the IDE to detect the `pubspec.yaml`
- Click "Pub get" when prompted, or manually run:

Alternatively, use the terminal (if Flutter is in PATH):
```bash
flutter pub get
```

### 3. Run the Application

**Using Android Studio:**
- Select a device/emulator
- Click the Run button (green play icon)

**Using Terminal:**
```bash
flutter run
```

## 🔐 Demo Accounts

The app comes with pre-configured demo accounts:

### Manager Account
- **Email**: manager@taskflow.com
- **Password**: manager123
- **Capabilities**: Create tasks, assign to team, view all tasks, delete tasks

### Staff Account 1
- **Email**: staff@taskflow.com
- **Password**: staff123
- **Capabilities**: View assigned tasks, update status, submit progress reports

### Staff Account 2
- **Email**: mike@taskflow.com
- **Password**: mike123
- **Capabilities**: View assigned tasks, update status, submit progress reports

## 📱 Application Screens

### 1. Login Screen
- Email and password authentication
- Quick login buttons for demo accounts
- Password visibility toggle

### 2. Dashboard
- View all tasks (Manager) or assigned tasks (Staff)
- Filter by status (All, To Do, In Progress, Done)
- Pull-to-refresh functionality
- Task cards with priority and status indicators

### 3. Add Task Screen (Manager Only)
- Task title and description input
- Priority selection (Urgent, Medium, Low)
- Deadline picker
- Team member assignment
- Form validation

### 4. Task Detail Screen
- Complete task information
- Status update buttons (for assignees)
- Progress reporting section
- Chronological report history

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point & routing
├── database/
│   └── database_helper.dart  # SQLite database operations
├── theme/
│   └── app_theme.dart        # Design system & theming
└── screens/
    ├── login_screen.dart         # Authentication
    ├── dashboard_screen.dart     # Task list & overview
    ├── add_task_screen.dart      # Task creation form
    └── task_detail_screen.dart   # Task details & reports
```

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK(role IN ('manager', 'staff'))
);
```

### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  assignee_name TEXT NOT NULL,
  assignee_id INTEGER,
  priority TEXT NOT NULL CHECK(priority IN ('urgent', 'medium', 'low')),
  status TEXT NOT NULL CHECK(status IN ('todo', 'in-progress', 'done')),
  deadline TEXT NOT NULL,
  created_at TEXT NOT NULL,
  created_by INTEGER NOT NULL,
  FOREIGN KEY (assignee_id) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);
```

### Task Reports Table
```sql
CREATE TABLE task_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL,
  report_text TEXT NOT NULL,
  reported_by INTEGER NOT NULL,
  reported_at TEXT NOT NULL,
  FOREIGN KEY (task_id) REFERENCES tasks(id),
  FOREIGN KEY (reported_by) REFERENCES users(id)
);
```

## ✅ Requirements Fulfillment

### Project Requirements Checklist

- ✅ **Multiple Activities/Screens**: Login, Dashboard, Add Task, Task Detail
- ✅ **Intent Navigation**: Proper routing with arguments passing
- ✅ **Text Input**: Task title, description, email, password
- ✅ **Password Input**: Secure text entry with visibility toggle
- ✅ **Selection/Picker**: Priority selection, date picker, assignee selection
- ✅ **Radio Buttons**: Status selection, priority cards
- ✅ **Buttons**: Login, submit, status update, filter chips
- ✅ **SQLite Database**: Full CRUD operations with 3 tables
- ✅ **Modern Design**: Minimalist, clean UI with consistent styling

## 🎯 Key Features Implementation

### Form Components
- **Text Fields**: Title, description, email, password with validation
- **Multi-line Input**: Task description, progress reports
- **Date Picker**: Deadline selection with calendar UI
- **Custom Selection**: Visual card-based selection for priority & assignees
- **Secure Input**: Password field with show/hide toggle

### Database Operations
- **Create**: New users, tasks, and reports
- **Read**: Query tasks by user, status, priority
- **Update**: Modify task status
- **Delete**: Remove tasks and cascade delete reports
- **Joins**: Complex queries with user information

### Navigation Flow
```
Login → Dashboard → Add Task (Manager)
              ↓
         Task Detail → Progress Reports
```

## 🧪 Testing

### Manual Test Cases

1. **Login**: Test with valid/invalid credentials
2. **Task Creation**: Create task with all fields
3. **Task Assignment**: Assign to different team members
4. **Status Update**: Change status from To Do → In Progress → Done
5. **Progress Reports**: Add multiple reports
6. **Filtering**: Test all filter options
7. **Delete Task**: Remove task and verify cascade delete
8. **Pull to Refresh**: Update data from database

### Test Devices
- Android Emulator (API 30+)
- Physical Android device (Android 8.0+)

## 🔮 Future Enhancements

- [ ] Push notifications for task assignments
- [ ] Task deadline reminders
- [ ] Search and sort functionality
- [ ] Task categories/tags
- [ ] File attachments
- [ ] Calendar view
- [ ] Analytics dashboard
- [ ] Cloud sync (Firebase)
- [ ] Dark mode
- [ ] Multi-language support

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Target of URI doesn't exist" errors
**Solution**: Run `flutter pub get` to install dependencies

**Issue**: Database not initializing
**Solution**: Clear app data and reinstall

**Issue**: Navigation not working
**Solution**: Check that user object is being passed correctly

## 📄 License

This project is created for educational purposes as part of the Wireless and Mobile Programming course.

## 👥 Team Members

| Name | Role | Contribution |
|------|------|-------------|
| [Your Name] | Project Lead | Architecture, Database, UI Implementation |
| [Team Member 2] | Developer | Screens, Navigation, Testing |
| [Team Member 3] | Developer | Documentation, Design, Integration |

## 📚 References

- [Flutter Documentation](https://flutter.dev/docs)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Material Design Guidelines](https://material.io/design)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 📞 Support

For questions or issues, please contact the development team or refer to the project documentation.

---

**Built with Flutter** 💙

