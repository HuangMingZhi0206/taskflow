import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'config/app_config.dart';
import 'database/database_helper.dart';
import 'database/sqlite_database_helper.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/preferences_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/group_activities_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print app configuration
  AppConfig.printConfig();

  // RESET DATABASE (Enable only if you need fresh start)
  // This will delete the old database and create a new one with correct schema
  print('⚠️  Resetting database for courses table fix...');
  try {
    // Delete using DatabaseHelper to ensure we're deleting the right database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taskflow.db');
    await deleteDatabase(path);
    print('✓ Database deleted successfully');
  } catch (e) {
    print('⚠️  Database delete error (might not exist): $e');
  }

  // Initialize database - this will create version 5 with courses table
  try {
    final db = await DatabaseHelper.instance.database;
    print('✓ Database initialized successfully with version 5');

    // Verify courses table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='courses'"
    );
    if (tables.isNotEmpty) {
      print('✅ VERIFIED: courses table exists!');
    } else {
      print('❌ ERROR: courses table NOT found!');
    }
  } catch (e) {
    print('✗ Error initializing database: $e');
    print('💡 Try clearing app data manually');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(() {
      setState(() {});
    });
    _preferencesService.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeService.dispose();
    _preferencesService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        primaryColor: _themeService.accentColor,
        colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
          primary: _themeService.accentColor,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        primaryColor: _themeService.accentColor,
        colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
          primary: _themeService.accentColor,
        ),
      ),
      themeMode: _themeService.themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(themeService: _themeService),
            );

          case '/register':
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
            );

          case '/dashboard':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(
                user: user,
                themeService: _themeService,
              ),
            );

          case '/add-task':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AddTaskScreen(user: user),
            );

          case '/task-detail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => TaskDetailScreen(
                taskId: args['taskId'],
                user: args['user'],
              ),
            );

          case '/settings':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SettingsScreen(
                user: user,
                themeService: _themeService,
                preferencesService: _preferencesService,
              ),
            );

          case '/schedule':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ScheduleScreen(user: user),
            );

          case '/courses':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CoursesScreen(user: user),
            );

          case '/groups':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => GroupActivitiesScreen(user: user),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => LoginScreen(themeService: _themeService),
            );
        }
      },
    );
  }
}
