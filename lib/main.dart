import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/preferences_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

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

          default:
            return MaterialPageRoute(
              builder: (_) => LoginScreen(themeService: _themeService),
            );
        }
      },
    );
  }
}
