import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app-wide user preferences
class PreferencesService extends ChangeNotifier {
  // Keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationSoundKey = 'notification_sound';
  static const String _deadlineRemindersKey = 'deadline_reminders';
  static const String _statusChangeNotificationsKey = 'status_change_notifications';
  static const String _assignmentNotificationsKey = 'assignment_notifications';
  static const String _commentNotificationsKey = 'comment_notifications';
  static const String _reminderHoursBeforeKey = 'reminder_hours_before';
  static const String _compactViewKey = 'compact_view';
  static const String _showCompletedTasksKey = 'show_completed_tasks';
  static const String _defaultTaskPriorityKey = 'default_task_priority';
  static const String _autoSyncKey = 'auto_sync';

  // Notification Settings
  bool _notificationsEnabled = true;
  bool _notificationSound = true;
  bool _deadlineReminders = true;
  bool _statusChangeNotifications = true;
  bool _assignmentNotifications = true;
  bool _commentNotifications = true;
  int _reminderHoursBefore = 24;

  // Display Settings
  bool _compactView = false;
  bool _showCompletedTasks = true;
  String _defaultTaskPriority = 'Medium';

  // Data Settings
  bool _autoSync = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationSound => _notificationSound;
  bool get deadlineReminders => _deadlineReminders;
  bool get statusChangeNotifications => _statusChangeNotifications;
  bool get assignmentNotifications => _assignmentNotifications;
  bool get commentNotifications => _commentNotifications;
  int get reminderHoursBefore => _reminderHoursBefore;
  bool get compactView => _compactView;
  bool get showCompletedTasks => _showCompletedTasks;
  String get defaultTaskPriority => _defaultTaskPriority;
  bool get autoSync => _autoSync;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _notificationSound = prefs.getBool(_notificationSoundKey) ?? true;
    _deadlineReminders = prefs.getBool(_deadlineRemindersKey) ?? true;
    _statusChangeNotifications = prefs.getBool(_statusChangeNotificationsKey) ?? true;
    _assignmentNotifications = prefs.getBool(_assignmentNotificationsKey) ?? true;
    _commentNotifications = prefs.getBool(_commentNotificationsKey) ?? true;
    _reminderHoursBefore = prefs.getInt(_reminderHoursBeforeKey) ?? 24;
    _compactView = prefs.getBool(_compactViewKey) ?? false;
    _showCompletedTasks = prefs.getBool(_showCompletedTasksKey) ?? true;
    _defaultTaskPriority = prefs.getString(_defaultTaskPriorityKey) ?? 'Medium';
    _autoSync = prefs.getBool(_autoSyncKey) ?? true;

    notifyListeners();
  }

  // Notification setters
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
    notifyListeners();
  }

  Future<void> setNotificationSound(bool value) async {
    _notificationSound = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationSoundKey, value);
    notifyListeners();
  }

  Future<void> setDeadlineReminders(bool value) async {
    _deadlineReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deadlineRemindersKey, value);
    notifyListeners();
  }

  Future<void> setStatusChangeNotifications(bool value) async {
    _statusChangeNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_statusChangeNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setAssignmentNotifications(bool value) async {
    _assignmentNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_assignmentNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setCommentNotifications(bool value) async {
    _commentNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_commentNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setReminderHoursBefore(int hours) async {
    _reminderHoursBefore = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHoursBeforeKey, hours);
    notifyListeners();
  }

  // Display setters
  Future<void> setCompactView(bool value) async {
    _compactView = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_compactViewKey, value);
    notifyListeners();
  }

  Future<void> setShowCompletedTasks(bool value) async {
    _showCompletedTasks = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCompletedTasksKey, value);
    notifyListeners();
  }

  Future<void> setDefaultTaskPriority(String priority) async {
    _defaultTaskPriority = priority;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultTaskPriorityKey, priority);
    notifyListeners();
  }

  // Data setters
  Future<void> setAutoSync(bool value) async {
    _autoSync = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncKey, value);
    notifyListeners();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _notificationSound = true;
    _deadlineReminders = true;
    _statusChangeNotifications = true;
    _assignmentNotifications = true;
    _commentNotifications = true;
    _reminderHoursBefore = 24;
    _compactView = false;
    _showCompletedTasks = true;
    _defaultTaskPriority = 'Medium';
    _autoSync = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}

