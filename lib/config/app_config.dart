import 'package:flutter/foundation.dart';

/// App Configuration
///
/// Central configuration for TaskFlow app
/// Set USE_FIREBASE to false to use SQLite only (offline mode)
class AppConfig {
  // ==================== DATABASE MODE ====================

  /// Use Firebase/Firestore for cloud storage
  /// Set to false to use SQLite only (offline mode)
  static const bool useFirebase = false;

  /// Use local SQLite database
  /// Always true for offline mode or as backup
  static const bool useSqlite = true;

  // ==================== FEATURE FLAGS ====================

  /// Enable offline mode features
  static const bool offlineMode = !useFirebase;

  /// Enable cloud sync (requires Firebase)
  static const bool enableCloudSync = useFirebase;

  /// Enable push notifications (requires Firebase)
  static const bool enablePushNotifications = useFirebase;

  // ==================== APP INFO ====================

  static const String appName = 'TaskFlow';
  static const String appVersion = '2.1.1';
  static const String appMode = useFirebase ? 'Online' : 'Offline (SQLite)';

  // ==================== DATABASE ====================

  static const String sqliteDbName = 'taskflow.db';
  static const int sqliteDbVersion = 1;

  // ==================== STORAGE ====================

  /// Max file size for attachments (in MB)
  static const int maxFileSizeMb = 10;

  /// Allowed file extensions
  static const List<String> allowedFileExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'txt',
    'zip',
    'rar',
  ];

  // ==================== UI ====================

  /// Show mode indicator in UI
  static const bool showModeIndicator = true;

  /// Theme mode
  static const String defaultTheme = 'light';

  // ==================== DEBUG ====================

  /// Enable debug logging
  static const bool debugMode = true;

  /// Print SQL queries
  static const bool logSqlQueries = false;

  // ==================== HELPERS ====================

  static String get databaseMode =>
      useFirebase ? 'Firebase/Firestore' : 'SQLite';

  static void printConfig() {
    debugPrint('========================================');
    debugPrint('$appName v$appVersion');
    debugPrint('Mode: $appMode');
    debugPrint('Database: $databaseMode');
    debugPrint('Offline Mode: $offlineMode');
    debugPrint('Cloud Sync: ${enableCloudSync ? 'Enabled' : 'Disabled'}');
    debugPrint('========================================');
  }
}
