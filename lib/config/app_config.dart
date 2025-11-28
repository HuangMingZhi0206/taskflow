/// App Configuration
///
/// Central configuration for TaskFlow app
/// Set USE_FIREBASE to false to use SQLite only (offline mode)

class AppConfig {
  // ==================== DATABASE MODE ====================

  /// Use Firebase/Firestore for cloud storage
  /// Set to false to use SQLite only (offline mode)
  static const bool USE_FIREBASE = false;

  /// Use local SQLite database
  /// Always true for offline mode or as backup
  static const bool USE_SQLITE = true;

  // ==================== FEATURE FLAGS ====================

  /// Enable offline mode features
  static const bool OFFLINE_MODE = !USE_FIREBASE;

  /// Enable cloud sync (requires Firebase)
  static const bool ENABLE_CLOUD_SYNC = USE_FIREBASE;

  /// Enable push notifications (requires Firebase)
  static const bool ENABLE_PUSH_NOTIFICATIONS = USE_FIREBASE;

  // ==================== APP INFO ====================

  static const String APP_NAME = 'TaskFlow';
  static const String APP_VERSION = '2.1.1';
  static const String APP_MODE = USE_FIREBASE ? 'Online' : 'Offline (SQLite)';

  // ==================== DATABASE ====================

  static const String SQLITE_DB_NAME = 'taskflow.db';
  static const int SQLITE_DB_VERSION = 1;

  // ==================== STORAGE ====================

  /// Max file size for attachments (in MB)
  static const int MAX_FILE_SIZE_MB = 10;

  /// Allowed file extensions
  static const List<String> ALLOWED_FILE_EXTENSIONS = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx',
    'jpg', 'jpeg', 'png', 'gif',
    'txt', 'zip', 'rar'
  ];

  // ==================== UI ====================

  /// Show mode indicator in UI
  static const bool SHOW_MODE_INDICATOR = true;

  /// Theme mode
  static const String DEFAULT_THEME = 'light';

  // ==================== DEBUG ====================

  /// Enable debug logging
  static const bool DEBUG_MODE = true;

  /// Print SQL queries
  static const bool LOG_SQL_QUERIES = false;

  // ==================== HELPERS ====================

  static String get databaseMode => USE_FIREBASE ? 'Firebase/Firestore' : 'SQLite';

  static void printConfig() {
    print('========================================');
    print('$APP_NAME v$APP_VERSION');
    print('Mode: $APP_MODE');
    print('Database: $databaseMode');
    print('Offline Mode: $OFFLINE_MODE');
    print('Cloud Sync: ${ENABLE_CLOUD_SYNC ? 'Enabled' : 'Disabled'}');
    print('========================================');
  }
}

