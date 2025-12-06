import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/custom_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class FocusScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FocusScreen({super.key, required this.user});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int focusTime = 25 * 60;
  int shortBreakTime = 5 * 60;
  int longBreakTime = 15 * 60;

  int _completedIntervals = 0;
  int targetIntervals = 4;
  String _currentTask = '';

  late int _totalTime;
  late int _remainingTime;
  Timer? _timer;
  bool _isRunning = false;
  String _currentMode = 'focus'; // focus, short, long

  @override
  void initState() {
    super.initState();
    _totalTime = focusTime;
    _remainingTime = focusTime;
    NotificationService.instance.requestPermissions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _handleTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remainingTime = _totalTime;
    });
  }

  void _switchMode(String mode) {
    _pauseTimer();
    setState(() {
      _currentMode = mode;
      if (mode == 'focus') {
        _totalTime = focusTime;
      } else if (mode == 'short') {
        _totalTime = shortBreakTime;
      } else {
        _totalTime = longBreakTime;
      }
      _remainingTime = _totalTime;
    });
  }

  void _handleTimerComplete() {
    _pauseTimer();

    String message;
    String nextMode;

    // Logic for next mode
    if (_currentMode == 'focus') {
      setState(() {
        _completedIntervals++;
      });

      if (_completedIntervals >= targetIntervals) {
        nextMode = 'long';
        message = 'Great job! Time for a Long Break.';
        setState(() => _completedIntervals = 0); // Reset cycle
      } else {
        nextMode = 'short';
        message = 'Break time! Take a breather.';
      }
    } else {
      // If returning from break
      nextMode = 'focus';
      message = 'Break over! Ready to focus?';
    }

    // Initialize next mode
    _switchMode(nextMode);

    // Auto-start timer (Continuous Flow)
    _startTimer();

    NotificationService.instance.sendPomodoroNotification(message);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  String _formatTime() {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _remainingTime / _totalTime;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pomodoro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Mode Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton('Focus', 'focus', isDark),
              const SizedBox(width: 12),
              _buildModeButton('Short Break', 'short', isDark),
              const SizedBox(width: 12),
              _buildModeButton('Long Break', 'long', isDark),
            ],
          ),
          const SizedBox(height: 30),
          // Task Label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: InkWell(
              onTap: _showTaskDialog,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _currentTask.isNotEmpty
                        ? AppTheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 18,
                      color: _currentTask.isNotEmpty
                          ? AppTheme.primary
                          : AppTheme.textLight,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _currentTask.isNotEmpty
                            ? _currentTask
                            : 'What are you working on?',
                        style: TextStyle(
                          color: _currentTask.isNotEmpty
                              ? (isDark ? Colors.white : AppTheme.textPrimary)
                              : AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppTheme.textLight.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Timer Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _currentMode == 'focus'
                        ? AppTheme.primary
                        : AppTheme.urgent,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRunning ? 'RUNNING' : 'PAUSED',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Interval Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(targetIntervals, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _completedIntervals
                      ? AppTheme.primary
                      : AppTheme.textLight.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const Spacer(),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: _isRunning ? 'Pause' : 'Start',
                color: AppTheme.primary,
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                isLarge: true,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                color: isDark ? Colors.white : AppTheme.textPrimary,
                onPressed: _resetTimer,
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              arguments: widget.user,
            );
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/schedule',
              arguments: widget.user,
            );
          } else if (index == 3) {
            Navigator.pushReplacementNamed(
              context,
              '/settings',
              arguments: widget.user,
            );
          }
        },
        onFabTap: () {},
        showFab: false, // Hide FAB in Focus Mode
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, bool isDark) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () => _switchMode(mode),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.textLight.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? Colors.white : AppTheme.textPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: isLarge ? 80 : 60,
            height: isLarge ? 80 : 60,
            decoration: BoxDecoration(
              color: isLarge ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: isLarge ? null : Border.all(color: color, width: 2),
              boxShadow: isLarge ? AppTheme.softShadow : null,
            ),
            child: Icon(
              icon,
              size: isLarge ? 40 : 30,
              color: isLarge ? Colors.white : color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    final focusController = TextEditingController(
      text: (focusTime ~/ 60).toString(),
    );
    final shortController = TextEditingController(
      text: (shortBreakTime ~/ 60).toString(),
    );
    final longController = TextEditingController(
      text: (longBreakTime ~/ 60).toString(),
    );
    final intervalsController = TextEditingController(
      text: targetIntervals.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The Pomodoro Technique uses a timer to break down work into intervals, separated by short breaks.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: focusController,
              decoration: const InputDecoration(
                labelText: 'Focus Duration (min)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: shortController,
              decoration: const InputDecoration(labelText: 'Short Break (min)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: longController,
              decoration: const InputDecoration(labelText: 'Long Break (min)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: intervalsController,
              decoration: const InputDecoration(
                labelText: 'Sections (Intervals)',
                helperText: 'Sessions before Long Break',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final f = int.tryParse(focusController.text) ?? 25;
                final s = int.tryParse(shortController.text) ?? 5;
                final l = int.tryParse(longController.text) ?? 15;
                final i = int.tryParse(intervalsController.text) ?? 4;
                focusTime = f * 60;
                shortBreakTime = s * 60;
                longBreakTime = l * 60;
                targetIntervals = i;

                // Update totalTime immediately based on current mode
                if (_currentMode == 'focus') {
                  _totalTime = focusTime;
                } else if (_currentMode == 'short') {
                  _totalTime = shortBreakTime;
                } else {
                  _totalTime = longBreakTime;
                }
                _resetTimer();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog() {
    final controller = TextEditingController(text: _currentTask);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Focus Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Write Article, Study Math',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentTask = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Set Task'),
          ),
        ],
      ),
    );
  }
}
