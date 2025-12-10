import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class PomodoroService extends ChangeNotifier {
  static final PomodoroService _instance = PomodoroService._internal();
  static PomodoroService get instance => _instance;

  PomodoroService._internal() {
    // Initialize timer values
    _totalTime = focusTime;
    _remainingTime = focusTime;
  }

  // Timer settings
  int focusTime = 25 * 60; // 25 minutes
  int shortBreakTime = 5 * 60; // 5 minutes
  int longBreakTime = 15 * 60; // 15 minutes

  // State
  int _completedIntervals = 0;
  int targetIntervals = 4;
  String _currentTask = '';

  late int _totalTime;
  late int _remainingTime;
  Timer? _timer;
  bool _isRunning = false;
  String _currentMode = 'focus'; // focus, short, long

  // Getters
  int get completedIntervals => _completedIntervals;
  String get currentTask => _currentTask;
  int get totalTime => _totalTime;
  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  String get currentMode => _currentMode;

  // Initialize
  void initialize() {
    _totalTime = focusTime;
    _remainingTime = focusTime;
    _isRunning = false;
    _currentMode = 'focus';
    _completedIntervals = 0;
    _currentTask = '';
    notifyListeners();
  }

  void setTask(String task) {
    _currentTask = task;
    notifyListeners();
  }

  void startTimer() {
    if (_timer != null) return;
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    _remainingTime = _totalTime;
    notifyListeners();
  }

  void switchMode(String mode) {
    pauseTimer();
    _currentMode = mode;

    if (mode == 'focus') {
      _totalTime = focusTime;
    } else if (mode == 'short') {
      _totalTime = shortBreakTime;
    } else {
      _totalTime = longBreakTime;
    }

    _remainingTime = _totalTime;
    notifyListeners();
  }

  void _handleTimerComplete() {
    debugPrint('⏰⏰⏰ TIMER COMPLETE! Mode: $_currentMode at ${DateTime.now()}');
    pauseTimer();

    String message;
    String nextMode;

    if (_currentMode == 'focus') {
      _completedIntervals++;
      debugPrint('✅ Focus session completed. Intervals: $_completedIntervals/$targetIntervals');

      if (_completedIntervals >= targetIntervals) {
        nextMode = 'long';
        message = '🎉 Great job! Time for a Long Break (${longBreakTime ~/ 60} min).';
        _completedIntervals = 0;
      } else {
        nextMode = 'short';
        message = '✅ Focus completed! Take a Short Break (${shortBreakTime ~/ 60} min).';
      }
    } else {
      nextMode = 'focus';
      message = '⏰ Break over! Ready for next Focus session?';
      debugPrint('☕ Break completed. Switching to focus mode.');
    }

    // CRITICAL: Send notification IMMEDIATELY
    debugPrint('📢📢📢 SENDING NOTIFICATION NOW: $message');

    // Send notification synchronously (blocking)
    NotificationService.instance.sendPomodoroNotification(message).then((_) {
      debugPrint('✅✅✅ Notification sent successfully!');
    }).catchError((error) {
      debugPrint('❌❌❌ ERROR sending notification: $error');
    });

    // Send again after small delay (insurance)
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint('📢 Sending backup notification...');
      NotificationService.instance.sendPomodoroNotification(message);
    });

    // Send third time after 1 second (triple insurance)
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('📢 Sending third notification attempt...');
      NotificationService.instance.sendPomodoroNotification(message);
    });

    // Auto switch to next mode
    switchMode(nextMode);
    debugPrint('🔄 Switched to $nextMode mode');
  }

  void updateSettings({
    int? newFocusTime,
    int? newShortBreakTime,
    int? newLongBreakTime,
    int? newTargetIntervals,
  }) {
    if (newFocusTime != null) focusTime = newFocusTime * 60;
    if (newShortBreakTime != null) shortBreakTime = newShortBreakTime * 60;
    if (newLongBreakTime != null) longBreakTime = newLongBreakTime * 60;
    if (newTargetIntervals != null) targetIntervals = newTargetIntervals;

    // Update current mode time if not running
    if (!_isRunning) {
      if (_currentMode == 'focus') {
        _totalTime = focusTime;
      } else if (_currentMode == 'short') {
        _totalTime = shortBreakTime;
      } else {
        _totalTime = longBreakTime;
      }
      _remainingTime = _totalTime;
    }

    notifyListeners();
  }

  // Quick adjust time (add/subtract minutes)
  void adjustTime(int minutes) {
    if (_isRunning) return; // Can't adjust while running

    final adjustment = minutes * 60; // Convert to seconds
    _remainingTime += adjustment;
    _totalTime += adjustment;

    // Prevent negative time
    if (_remainingTime < 60) {
      _remainingTime = 60; // Minimum 1 minute
      _totalTime = 60;
    }

    // Update base time for current mode
    if (_currentMode == 'focus') {
      focusTime = _totalTime;
    } else if (_currentMode == 'short') {
      shortBreakTime = _totalTime;
    } else {
      longBreakTime = _totalTime;
    }

    notifyListeners();
  }

  // Set specific time in minutes
  void setTime(int minutes) {
    if (_isRunning) return;

    final seconds = minutes * 60;
    _remainingTime = seconds;
    _totalTime = seconds;

    // Update base time for current mode
    if (_currentMode == 'focus') {
      focusTime = seconds;
    } else if (_currentMode == 'short') {
      shortBreakTime = seconds;
    } else {
      longBreakTime = seconds;
    }

    notifyListeners();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double getProgress() {
    if (_totalTime == 0) return 0;
    return (_totalTime - _remainingTime) / _totalTime;
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

