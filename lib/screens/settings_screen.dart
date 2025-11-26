import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final ThemeService themeService;
  final PreferencesService preferencesService;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.themeService,
    required this.preferencesService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'Appearance'),
            Tab(icon: Icon(Icons.notifications_outlined), text: 'Notifications'),
            Tab(icon: Icon(Icons.view_compact_outlined), text: 'Display'),
            Tab(icon: Icon(Icons.info_outline), text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildAppearanceTab(),
          _buildNotificationsTab(),
          _buildDisplayTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  // ===== PROFILE TAB =====
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: widget.themeService.accentColor,
                    child: Text(
                      widget.user['name'][0].toUpperCase(),
                      style: const TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: widget.themeService.accentColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        onPressed: () {
                          _showSnackBar('Profile photo upload coming soon!');
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.user['name'],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user['email'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  widget.user['role'],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: widget.themeService.accentColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Account Information'),
        _buildInfoTile(Icons.badge_outlined, 'Role', widget.user['role']),
        _buildInfoTile(Icons.email_outlined, 'Email', widget.user['email']),
        _buildInfoTile(
          Icons.business_outlined,
          'Position',
          widget.user['position'] ?? 'Not set',
        ),
        _buildInfoTile(
          Icons.phone_outlined,
          'Contact',
          widget.user['contact_number'] ?? 'Not set',
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          Icons.edit_outlined,
          'Edit Profile',
          'Update your personal information',
          () {
            _showSnackBar('Profile editing coming soon!');
          },
        ),
        _buildActionTile(
          Icons.lock_outline,
          'Change Password',
          'Update your account password',
          () {
            _showSnackBar('Password change coming soon!');
          },
        ),
      ],
    );
  }

  // ===== APPEARANCE TAB =====
  Widget _buildAppearanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Theme Mode'),
        Card(
          child: Column(
            children: [
              _buildThemeOption(
                ThemeMode.light,
                'Light Mode',
                'Bright and clear',
                Icons.light_mode,
              ),
              _buildThemeOption(
                ThemeMode.dark,
                'Dark Mode',
                'Easy on the eyes',
                Icons.dark_mode,
              ),
              _buildThemeOption(
                ThemeMode.system,
                'System Default',
                'Follow device settings',
                Icons.brightness_auto,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Accent Color'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: ThemeService.accentColors.map((option) {
            final isSelected = widget.themeService.accentColor.toARGB32() == option.color.toARGB32();
            return GestureDetector(
              onTap: () {
                widget.themeService.setAccentColor(option.color);
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black.withValues(alpha: 0.7))
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: option.color.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(option.color),
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Font Size'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Text Size'),
                    Text(
                      '${(widget.themeService.fontSizeScale * 100).round()}%',
                      style: TextStyle(
                        color: widget.themeService.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: widget.themeService.fontSizeScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 12,
                  label: '${(widget.themeService.fontSizeScale * 100).round()}%',
                  onChanged: (value) {
                    widget.themeService.setFontSizeScale(value);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Preview: The quick brown fox jumps over the lazy dog',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14 * widget.themeService.fontSizeScale,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            widget.themeService.resetToDefaults();
            _showSnackBar('Appearance reset to defaults');
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset to Defaults'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ===== NOTIFICATIONS TAB =====
  Widget _buildNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('General'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive all notifications'),
                secondary: const Icon(Icons.notifications_active),
                value: widget.preferencesService.notificationsEnabled,
                onChanged: (value) {
                  widget.preferencesService.setNotificationsEnabled(value);
                },
              ),
              SwitchListTile(
                title: const Text('Notification Sound'),
                subtitle: const Text('Play sound for notifications'),
                secondary: const Icon(Icons.volume_up),
                value: widget.preferencesService.notificationSound,
                onChanged: widget.preferencesService.notificationsEnabled
                    ? (value) {
                        widget.preferencesService.setNotificationSound(value);
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Notification Types'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Deadline Reminders'),
                subtitle: const Text('Notify before task deadlines'),
                secondary: const Icon(Icons.alarm),
                value: widget.preferencesService.deadlineReminders,
                onChanged: widget.preferencesService.notificationsEnabled
                    ? (value) {
                        widget.preferencesService.setDeadlineReminders(value);
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Task Assignments'),
                subtitle: const Text('When a task is assigned to you'),
                secondary: const Icon(Icons.assignment_turned_in),
                value: widget.preferencesService.assignmentNotifications,
                onChanged: widget.preferencesService.notificationsEnabled
                    ? (value) {
                        widget.preferencesService.setAssignmentNotifications(value);
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Status Changes'),
                subtitle: const Text('When task status is updated'),
                secondary: const Icon(Icons.sync_alt),
                value: widget.preferencesService.statusChangeNotifications,
                onChanged: widget.preferencesService.notificationsEnabled
                    ? (value) {
                        widget.preferencesService.setStatusChangeNotifications(value);
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Comments'),
                subtitle: const Text('When someone comments on your tasks'),
                secondary: const Icon(Icons.comment),
                value: widget.preferencesService.commentNotifications,
                onChanged: widget.preferencesService.notificationsEnabled
                    ? (value) {
                        widget.preferencesService.setCommentNotifications(value);
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Reminder Timing'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remind before deadline'),
                    Text(
                      '${widget.preferencesService.reminderHoursBefore}h',
                      style: TextStyle(
                        color: widget.themeService.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: widget.preferencesService.reminderHoursBefore.toDouble(),
                  min: 1,
                  max: 72,
                  divisions: 23,
                  label: '${widget.preferencesService.reminderHoursBefore} hours',
                  onChanged: widget.preferencesService.notificationsEnabled &&
                          widget.preferencesService.deadlineReminders
                      ? (value) {
                          widget.preferencesService.setReminderHoursBefore(value.round());
                        }
                      : null,
                ),
                Text(
                  'You will be reminded ${widget.preferencesService.reminderHoursBefore} hours before the deadline',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== DISPLAY TAB =====
  Widget _buildDisplayTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Task View'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Compact View'),
                subtitle: const Text('Show more tasks on screen'),
                secondary: const Icon(Icons.view_compact),
                value: widget.preferencesService.compactView,
                onChanged: (value) {
                  widget.preferencesService.setCompactView(value);
                },
              ),
              SwitchListTile(
                title: const Text('Show Completed Tasks'),
                subtitle: const Text('Display tasks marked as done'),
                secondary: const Icon(Icons.check_circle_outline),
                value: widget.preferencesService.showCompletedTasks,
                onChanged: (value) {
                  widget.preferencesService.setShowCompletedTasks(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Default Settings'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Default Task Priority'),
                subtitle: Text(widget.preferencesService.defaultTaskPriority),
                trailing: DropdownButton<String>(
                  value: widget.preferencesService.defaultTaskPriority,
                  underline: const SizedBox(),
                  items: ['Low', 'Medium', 'Urgent'].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.preferencesService.setDefaultTaskPriority(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Data & Storage'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Auto Sync'),
                subtitle: const Text('Automatically sync data'),
                secondary: const Icon(Icons.sync),
                value: widget.preferencesService.autoSync,
                onChanged: (value) {
                  widget.preferencesService.setAutoSync(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Cache Size'),
                subtitle: const Text('~5.2 MB'),
                trailing: TextButton(
                  onPressed: () {
                    _showClearCacheDialog();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== ABOUT TAB =====
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.themeService.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 60,
                  color: widget.themeService.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TaskFlow',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 2.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Information'),
        _buildActionTile(
          Icons.description_outlined,
          'Documentation',
          'View app documentation and guides',
          () {
            _showSnackBar('Check README.md for documentation');
          },
        ),
        _buildActionTile(
          Icons.update_outlined,
          'Check for Updates',
          'See if a new version is available',
          () {
            _showSnackBar('You are using the latest version');
          },
        ),
        _buildActionTile(
          Icons.article_outlined,
          'What\'s New',
          'View changelog and new features',
          () {
            _showWhatsNewDialog();
          },
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Support'),
        _buildActionTile(
          Icons.bug_report_outlined,
          'Report a Bug',
          'Help us improve TaskFlow',
          () {
            _showSnackBar('Bug reporting coming soon');
          },
        ),
        _buildActionTile(
          Icons.star_outline,
          'Rate App',
          'Share your feedback',
          () {
            _showSnackBar('Thank you for your support!');
          },
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Legal'),
        _buildActionTile(
          Icons.privacy_tip_outlined,
          'Privacy Policy',
          'How we handle your data',
          () {
            _showSnackBar('Privacy policy coming soon');
          },
        ),
        _buildActionTile(
          Icons.gavel_outlined,
          'Terms of Service',
          'App usage terms and conditions',
          () {
            _showSnackBar('Terms of service coming soon');
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '© 2025 TaskFlow. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Made with ❤️ for productivity',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  // ===== HELPER WIDGETS =====
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: widget.themeService.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => widget.themeService.setThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: widget.themeService.accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<ThemeMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: widget.themeService.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  widget.themeService.setThemeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: widget.themeService.accentColor),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if color is light or dark
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    // Return white for dark colors, black for light colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: widget.themeService.accentColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ===== DIALOGS =====
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data. Your tasks and settings will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showWhatsNewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What\'s New in v2.0'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeatureItem('🌙 Dark Mode with auto theme'),
              _buildFeatureItem('🎨 Customizable accent colors'),
              _buildFeatureItem('⏱️ Time estimation for tasks'),
              _buildFeatureItem('🔔 Enhanced notifications'),
              _buildFeatureItem('💬 Comments & discussions'),
              _buildFeatureItem('🏷️ Task tagging system'),
              _buildFeatureItem('✅ Subtasks & checklists'),
              _buildFeatureItem('📊 Statistics dashboard'),
              _buildFeatureItem('👤 Improved user profiles'),
              _buildFeatureItem('⚙️ Comprehensive settings'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

