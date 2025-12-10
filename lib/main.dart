import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_home.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/focus_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Print app configuration
  AppConfig.printConfig();

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

  Route _buildFadeRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(
        milliseconds: 0,
      ), // Instant switch for "hover" feel
    );
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
            return _buildFadeRoute(
              AuthWrapper(themeService: _themeService),
              settings,
            );

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

          case '/dashboard':
            final user = settings.arguments as Map<String, dynamic>;
            return _buildFadeRoute(
              DashboardHome(user: user, themeService: _themeService),
              settings,
            );

          case '/add-task':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => AddTaskScreen(user: user));

          case '/task-detail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) =>
                  TaskDetailScreen(taskId: args['taskId'], user: args['user']),
            );

          case '/settings':
            final user = settings.arguments as Map<String, dynamic>;
            return _buildFadeRoute(
              SettingsScreen(
                user: user,
                themeService: _themeService,
                preferencesService: _preferencesService,
              ),
              settings,
            );

          case '/schedule':
            final user = settings.arguments as Map<String, dynamic>;
            return _buildFadeRoute(ScheduleScreen(user: user), settings);

          case '/courses':
            final user = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => CoursesScreen(user: user));

          case '/focus':
            final user = settings.arguments as Map<String, dynamic>;
            return _buildFadeRoute(FocusScreen(user: user), settings);

          default:
            return MaterialPageRoute(
              builder: (_) => LoginScreen(themeService: _themeService),
            );
        }
      },
    );
  }
}
