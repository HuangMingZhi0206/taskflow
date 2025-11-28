import 'dart:async';
import 'package:flutter/foundation.dart';

enum PomodoroState {
  idle,
  working,
  shortBreak,
  longBreak,
}

class PomodoroService extends ChangeNotifier {
  // Timer settings (in minutes)
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _sessionsUntilLongBreak = 4;

  // Current state
  PomodoroState _state = PomodoroState.idle;
  int _remainingSeconds = 0;
  int _completedSessions = 0;
  Timer? _timer;
  bool _isRunning = false;

  // Getters
  PomodoroState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get completedSessions => _completedSessions;
  bool get isRunning => _isRunning;
  int get workDuration => _workDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    int totalSeconds;
    switch (_state) {
      case PomodoroState.working:
        totalSeconds = _workDuration * 60;
        break;
      case PomodoroState.shortBreak:
        totalSeconds = _shortBreakDuration * 60;
        break;
      case PomodoroState.longBreak:
        totalSeconds = _longBreakDuration * 60;
        break;
      default:
        return 0.0;
    }
    return (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  // Start a work session
  void startWorkSession() {
    _state = PomodoroState.working;
    _remainingSeconds = _workDuration * 60;
    _startTimer();
    notifyListeners();
  }

  // Start a break
  void startBreak() {
    if (_completedSessions % _sessionsUntilLongBreak == 0 && _completedSessions > 0) {
      _state = PomodoroState.longBreak;
      _remainingSeconds = _longBreakDuration * 60;
    } else {
      _state = PomodoroState.shortBreak;
      _remainingSeconds = _shortBreakDuration * 60;
    }
    _startTimer();
    notifyListeners();
  }

  // Pause/Resume timer
  void togglePause() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    } else {
      _startTimer();
    }
    notifyListeners();
  }

  // Stop/Reset timer
  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _state = PomodoroState.idle;
    _remainingSeconds = 0;
    notifyListeners();
  }

  // Skip to next session
  void skip() {
    _timer?.cancel();
    _isRunning = false;

    if (_state == PomodoroState.working) {
      _completedSessions++;
      startBreak();
    } else {
      startWorkSession();
    }
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Session completed
        _onSessionComplete();
      }
    });
  }

  void _onSessionComplete() {
    _timer?.cancel();
    _isRunning = false;

    if (_state == PomodoroState.working) {
      _completedSessions++;
      // Auto-start break or wait for user
      notifyListeners();
      // Optionally: startBreak(); for auto-start
    } else {
      // Break completed, back to idle
      _state = PomodoroState.idle;
      notifyListeners();
    }
  }

  // Update settings
  void updateSettings({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
  }) {
    if (workDuration != null) _workDuration = workDuration;
    if (shortBreakDuration != null) _shortBreakDuration = shortBreakDuration;
    if (longBreakDuration != null) _longBreakDuration = longBreakDuration;
    if (sessionsUntilLongBreak != null) _sessionsUntilLongBreak = sessionsUntilLongBreak;
    notifyListeners();
  }

  // Reset session count
  void resetSessions() {
    _completedSessions = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

