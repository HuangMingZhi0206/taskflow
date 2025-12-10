import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/pomodoro_service.dart';

class FocusScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FocusScreen({super.key, required this.user});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final PomodoroService _pomodoroService = PomodoroService.instance;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
    _taskController.text = _pomodoroService.currentTask;

    // Listen to pomodoro service changes
    _pomodoroService.addListener(_onPomodoroUpdate);
  }

  @override
  void dispose() {
    _pomodoroService.removeListener(_onPomodoroUpdate);
    _taskController.dispose();
    super.dispose();
  }

  void _onPomodoroUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _pomodoroService.getProgress();

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
          // Test notification button (for debugging)
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              await NotificationService.instance.sendTestNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent! Check your notification panel.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Test Notification',
          ),
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
                    color: _pomodoroService.currentTask.isNotEmpty
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
                      color: _pomodoroService.currentTask.isNotEmpty
                          ? AppTheme.primary
                          : AppTheme.textLight,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _pomodoroService.currentTask.isNotEmpty
                            ? _pomodoroService.currentTask
                            : 'What are you working on?',
                        style: TextStyle(
                          color: _pomodoroService.currentTask.isNotEmpty
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
          // Timer Circle with Quick Edit
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: 1 - progress,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _pomodoroService.currentMode == 'focus'
                        ? AppTheme.primary
                        : AppTheme.urgent,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick add/subtract time buttons
                  if (!_pomodoroService.isRunning)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            _pomodoroService.adjustTime(-5);
                          },
                          color: AppTheme.textLight,
                          iconSize: 28,
                          tooltip: '-5 min',
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            _pomodoroService.adjustTime(5);
                          },
                          color: AppTheme.primary,
                          iconSize: 28,
                          tooltip: '+5 min',
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: !_pomodoroService.isRunning ? _showQuickTimeEdit : null,
                    child: Text(
                      _pomodoroService.formatTime(_pomodoroService.remainingTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pomodoroService.isRunning ? 'RUNNING' : 'PAUSED',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_pomodoroService.isRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tap time to edit',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight.withValues(alpha: 0.7),
                        ),
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
            children: List.generate(_pomodoroService.targetIntervals, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pomodoroService.completedIntervals
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
                icon: _pomodoroService.isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: _pomodoroService.isRunning ? 'Pause' : 'Start',
                color: AppTheme.primary,
                onPressed: _pomodoroService.isRunning
                    ? () => _pomodoroService.pauseTimer()
                    : () => _pomodoroService.startTimer(),
                isLarge: true,
              ),
              const SizedBox(width: 20),
              _buildControlButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                color: isDark ? Colors.white : AppTheme.textPrimary,
                onPressed: () => _pomodoroService.resetTimer(),
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
        showFab: false,
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, bool isDark) {
    final isSelected = _pomodoroService.currentMode == mode;
    return InkWell(
      onTap: () => _pomodoroService.switchMode(mode),
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
      text: (_pomodoroService.focusTime ~/ 60).toString(),
    );
    final shortController = TextEditingController(
      text: (_pomodoroService.shortBreakTime ~/ 60).toString(),
    );
    final longController = TextEditingController(
      text: (_pomodoroService.longBreakTime ~/ 60).toString(),
    );
    final intervalsController = TextEditingController(
      text: _pomodoroService.targetIntervals.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timer,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Timer Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customize your Pomodoro intervals for optimal productivity',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Focus Duration
                _buildSettingCard(
                  icon: Icons.access_time,
                  iconColor: AppTheme.primary,
                  title: 'Focus Duration',
                  description: 'Deep work session',
                  controller: focusController,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Short Break
                _buildSettingCard(
                  icon: Icons.coffee,
                  iconColor: Colors.orange,
                  title: 'Short Break',
                  description: 'Quick rest',
                  controller: shortController,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Long Break
                _buildSettingCard(
                  icon: Icons.weekend,
                  iconColor: Colors.green,
                  title: 'Long Break',
                  description: 'Extended rest',
                  controller: longController,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Intervals
                _buildSettingCard(
                  icon: Icons.repeat,
                  iconColor: Colors.purple,
                  title: 'Intervals',
                  description: 'Sessions before long break',
                  controller: intervalsController,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textLight,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final f = int.tryParse(focusController.text) ?? 25;
                final s = int.tryParse(shortController.text) ?? 5;
                final l = int.tryParse(longController.text) ?? 15;
                final i = int.tryParse(intervalsController.text) ?? 4;

                _pomodoroService.updateSettings(
                  newFocusTime: f,
                  newShortBreakTime: s,
                  newLongBreakTime: l,
                  newTargetIntervals: i,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Settings saved successfully!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
              decoration: InputDecoration(
                suffixText: 'min',
                suffixStyle: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: iconColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: iconColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Focus Task'),
        content: TextField(
          controller: _taskController,
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
              _pomodoroService.setTask(_taskController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Set Task'),
          ),
        ],
      ),
    );
  }

  void _showQuickTimeEdit() {
    final controller = TextEditingController(
      text: (_pomodoroService.remainingTime ~/ 60).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                suffixText: 'min',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickTimeChip(5, controller),
                _buildQuickTimeChip(10, controller),
                _buildQuickTimeChip(15, controller),
                _buildQuickTimeChip(25, controller),
                _buildQuickTimeChip(30, controller),
                _buildQuickTimeChip(45, controller),
                _buildQuickTimeChip(60, controller),
              ],
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
              final minutes = int.tryParse(controller.text) ?? 25;
              _pomodoroService.setTime(minutes);
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeChip(int minutes, TextEditingController controller) {
    return ActionChip(
      label: Text('$minutes'),
      onPressed: () {
        controller.text = minutes.toString();
      },
      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: AppTheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

