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
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_timer',
          'Pomodoro Timer',
          channelDescription: 'Notifications for Pomodoro',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      888, // Fixed ID for timer
      'Timer Complete!',
      message,
      details,
    );
  }
}
