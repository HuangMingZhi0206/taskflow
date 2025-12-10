import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    debugPrint('🔔 Initializing NotificationService...');
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    final initialized = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('NotificationService initialized: $initialized');

    // Create notification channels
    await _createNotificationChannels();

    // Request notification permission for Android 13+ (API 33+)
    await _requestPermissions();

    debugPrint('✅ NotificationService setup complete');
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Pomodoro Timer Channel
      const pomodoroChannel = AndroidNotificationChannel(
        'pomodoro_timer',
        'Pomodoro Timer',
        description: 'Notifications for Pomodoro Timer completion',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      // Test Channel
      const testChannel = AndroidNotificationChannel(
        'test_channel',
        'Test Notifications',
        description: 'Test notifications for debugging',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(pomodoroChannel);
      await androidImplementation.createNotificationChannel(testChannel);

      debugPrint('✅ Notification channels created');
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request exact alarm permission (Android 12+)
      await androidImplementation.requestExactAlarmsPermission();

      // Request notification permission (Android 13+)
      final granted = await androidImplementation.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to task detail
    // Note: Navigation logic to task detail can be implemented here using global navigator key
  }

  // Schedule deadline reminder (24 hours before)
  Future<void> scheduleDeadlineReminder({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
    required String userId,
  }) async {
    final reminderTime = deadline.subtract(const Duration(hours: 24));

    // Only schedule if reminder time is in the future
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'deadline_reminders',
          'Deadline Reminders',
          channelDescription: 'Notifications for upcoming task deadlines',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      taskId, // Use task ID as notification ID
      'Task Deadline Reminder',
      'Task "$taskTitle" is due in 24 hours!',
      tz.TZDateTime.from(reminderTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task_$taskId',
    );

    // Store notification in database
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'title': 'Task Deadline Reminder',
      'message': 'Task "$taskTitle" is due in 24 hours!',
      'type': 'deadline_reminder',
      'task_id': taskId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Send instant notification for task assignment
  Future<void> sendTaskAssignmentNotification({
    required String taskId,
    required String taskTitle,
    required String userId,
    required String managerName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_assignments',
          'Task Assignments',
          channelDescription: 'Notifications for new task assignments',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      taskId.hashCode, // Use task ID hashcode as notification ID
      'New Task Assigned',
      '$managerName assigned you: "$taskTitle"',
      details,
      payload: 'task_$taskId',
    );

    // Store notification in database
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'title': 'New Task Assigned',
      'message': '$managerName assigned you: "$taskTitle"',
      'type': 'task_assignment',
      'task_id': taskId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Send notification for status change
  Future<void> sendStatusChangeNotification({
    required String taskId,
    required String taskTitle,
    required String managerId,
    required String staffName,
    required String newStatus,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'status_updates',
          'Status Updates',
          channelDescription: 'Notifications for task status changes',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      taskId.hashCode + 1, // Offset to avoid conflicts
      'Task Status Updated',
      '$staffName updated "$taskTitle" to $newStatus',
      details,
      payload: 'task_$taskId',
    );

    // Store notification in database
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': managerId,
      'title': 'Task Status Updated',
      'message': '$staffName updated "$taskTitle" to $newStatus',
      'type': 'status_change',
      'task_id': taskId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Send notification for new comment/report
  Future<void> sendNewCommentNotification({
    required String taskId,
    required String taskTitle,
    required String recipientUserId,
    required String commenterName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'comments',
          'Comments & Reports',
          channelDescription: 'Notifications for new comments and reports',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      taskId.hashCode + 2, // Offset to avoid conflicts
      'New Comment',
      '$commenterName added a comment on "$taskTitle"',
      details,
      payload: 'task_$taskId',
    );

    // Store notification in database
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': recipientUserId,
      'title': 'New Comment',
      'message': '$commenterName added a comment on "$taskTitle"',
      'type': 'new_comment',
      'task_id': taskId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Cancel notification
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Request permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // Send Pomodoro Notification
  Future<void> sendPomodoroNotification(String message) async {
    final timestamp = DateTime.now().toString();
    debugPrint('');
    debugPrint('🔔🔔🔔 === NOTIFICATION SERVICE CALLED ===');
    debugPrint('🔔 Time: $timestamp');
    debugPrint('🔔 Message: $message');

    // Use timestamp as ID to ensure each notification shows
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    debugPrint('🔔 Notification ID: $notificationId');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_timer',
          'Pomodoro Timer',
          channelDescription: 'Notifications for Pomodoro Timer completion',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          color: Color(0xFF3B82F6),
          icon: '@mipmap/ic_launcher',
          showWhen: true,
          ongoing: false,
          autoCancel: true,
          fullScreenIntent: true, // Show even when screen is off
          category: AndroidNotificationCategory.alarm,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      debugPrint('🔔 Calling _notifications.show()...');
      await _notifications.show(
        notificationId,
        '⏰ Pomodoro Timer',
        message,
        details,
      );
      debugPrint('✅✅✅ NOTIFICATION SENT SUCCESSFULLY!');
      debugPrint('✅ ID: $notificationId');
      debugPrint('✅ Should appear on phone NOW!');
      debugPrint('=================================');
      debugPrint('');

    } catch (e, stackTrace) {
      debugPrint('❌❌❌ CRITICAL ERROR sending notification!');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Stack: $stackTrace');
      debugPrint('=================================');
      debugPrint('');
      rethrow;
    }
  }

  // Test notification - for debugging
  Future<void> sendTestNotification() async {
    debugPrint('🧪 Sending test notification');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications for debugging',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.show(
        999,
        'Test Notification',
        'If you see this, notifications are working! 🎉',
        details,
      );
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }
}
