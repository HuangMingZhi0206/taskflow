import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final ThemeService themeService;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.themeService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> tasks;

      if (widget.user['role'] == 'manager') {
        tasks = await DatabaseHelper.instance.getAllTasks();
      } else {
        tasks = await DatabaseHelper.instance.getTasksByUserId(widget.user['id']);
      }

      setState(() {
        _tasks = tasks;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading tasks: $e');
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredTasks = _tasks;
    } else {
      _filteredTasks = _tasks
          .where((task) => task['status'] == _selectedFilter)
          .toList();
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  String _getRoleDisplay() {
    switch (widget.user['role']) {
      case 'student':
        return widget.user['student_id'] != null
          ? '🎓 Student ID: ${widget.user['student_id']}'
          : '🎓 Student';
      case 'manager':
        return '👔 Manager';
      case 'staff':
        return '👤 Staff Member';
      default:
        return '🎓 Student';
    }
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.deleteTask(taskId);
        _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
        }
      } catch (e) {
        _showErrorDialog('Error deleting task: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
                arguments: widget.user,
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${widget.user['name']}! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRoleDisplay(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Task Stats
                Row(
                  children: [
                    _buildStatChip(
                      '📋 ${_tasks.length}',
                      'Total Tasks',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      '⏳ ${_tasks.where((t) => t['status'] != 'done').length}',
                      'Pending',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      '✅ ${_tasks.where((t) => t['status'] == 'done').length}',
                      'Completed',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Access Menu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAccessCard(
                      icon: Icons.calendar_month,
                      label: 'Schedule',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/schedule',
                        arguments: widget.user,
                      ),
                    ),
                    _buildQuickAccessCard(
                      icon: Icons.menu_book,
                      label: 'Courses',
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/courses',
                        arguments: widget.user,
                      ),
                    ),
                    _buildQuickAccessCard(
                      icon: Icons.groups,
                      label: 'Groups',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/groups',
                        arguments: widget.user,
                      ),
                    ),
                    _buildQuickAccessCard(
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/settings',
                        arguments: widget.user,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('To Do', 'todo'),
                      const SizedBox(width: 8),
                      _buildFilterChip('In Progress', 'in-progress'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Done', 'done'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskCard(_filteredTasks[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/add-task',
            arguments: widget.user,
          );
          if (result == true) {
            _loadTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setFilter(value),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primary : AppTheme.textLight.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final priorityColor = AppTheme.getPriorityColor(task['priority']);
    final statusColor = AppTheme.getStatusColor(task['status']);
    final deadline = DateTime.parse(task['deadline']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(deadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/task-detail',
            arguments: {
              'taskId': task['id'],
              'user': widget.user,
            },
          );
          if (result == true) {
            _loadTasks();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: priorityColor),
                    ),
                    child: Text(
                      task['priority'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      AppTheme.getStatusLabel(task['status']),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.user['role'] == 'manager')
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.urgent,
                      onPressed: () => _deleteTask(task['id']),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task['assignee_name'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message, submessage;
    IconData icon;

    switch (_selectedFilter) {
      case 'todo':
        icon = Icons.check_circle_outline;
        message = 'No pending tasks! 🎉';
        submessage = "You're all caught up!";
        break;
      case 'in-progress':
        icon = Icons.hourglass_empty;
        message = 'No tasks in progress';
        submessage = 'Start working on a task to see it here';
        break;
      case 'done':
        icon = Icons.task_alt;
        message = 'No completed tasks yet';
        submessage = 'Complete tasks to see them here';
        break;
      default:
        icon = Icons.add_task;
        message = 'No tasks yet! 📚';
        submessage = 'Tap the + button below to create your first task';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            submessage,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

