import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class DashboardHome extends StatefulWidget {
  final Map<String, dynamic> user;
  final ThemeService themeService;

  const DashboardHome({
    super.key,
    required this.user,
    required this.themeService,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorDialog('You are not logged in.');
        setState(() => _isLoading = false);
        return;
      }

      QuerySnapshot<Map<String, dynamic>> snapshot;

      if (widget.user['role'] == 'manager') {
        snapshot = await FirebaseFirestore.instance.collection('tasks').get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: currentUser.uid)
            .get();
      }

      final tasks = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

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

  Widget _buildModernStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  Future<void> _toggleTaskCompletion(Map<String, dynamic> task) async {
    try {
      final newStatus = task['status'] == 'done' ? 'todo' : 'done';
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task['id'])
          .update({'status': newStatus});

      _loadTasks(); // Reload to reflect change

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'done'
                  ? 'Task marked as complete'
                  : 'Task marked as incomplete',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error updating task: $e');
    }
  }

  Future<void> _deleteTask(String taskId) async {
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
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .delete();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Header Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.user['name'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (widget.user['student_id'] != null &&
                                      widget.user['student_id']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                      'ID: ${widget.user['student_id']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Stats in white cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernStatCard(
                                  '${_tasks.length}',
                                  'Total',
                                  Icons.task_alt,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernStatCard(
                                  '${_tasks.where((t) => t['status'] != 'done').length}',
                                  'Pending',
                                  Icons.pending_actions,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernStatCard(
                                  '${_tasks.where((t) => t['status'] == 'done').length}',
                                  'Done',
                                  Icons.check_circle_outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // My Tasks Header & Filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Task List
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredTasks.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(isDark))
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 6.0,
                        ),
                        child: _buildTaskCard(_filteredTasks[index], isDark),
                      );
                    }, childCount: _filteredTasks.length),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/schedule',
              arguments: widget.user,
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/focus',
              arguments: widget.user,
            );
          } else if (index == 3) {
            // Navigation to Settings/Profile
            Navigator.pushReplacementNamed(
              context,
              '/settings',
              arguments: widget.user,
            );
          }
        },
        onFabTap: () {}, // Handled by standard FAB
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setFilter(value),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primary.withValues(alpha: 0.1),
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.textLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.textLight.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isDark) {
    final priorityColor = AppTheme.getPriorityColor(task['priority']);
    final statusColor = AppTheme.getStatusColor(task['status']);
    final deadlineTimestamp = task['deadline'] as Timestamp?;
    final deadline = deadlineTimestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd').format(deadline);

    return Opacity(
      opacity: task['status'] == 'done' ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : AppTheme.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/task-detail',
                arguments: {'taskId': task['id'], 'user': widget.user},
              );
              if (result == true) {
                _loadTasks();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Simple completion checkbox
                      GestureDetector(
                        onTap: () => _toggleTaskCompletion(task),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task['status'] == 'done'
                                ? AppTheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: task['status'] == 'done'
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: task['status'] == 'done'
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'] ?? 'Untitled Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                            decoration: task['status'] == 'done'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppTheme.textLight,
                        onPressed: () => _deleteTask(task['id']),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppTheme.getStatusLabel(task['status']),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'todo':
        icon = Icons.check_circle_outline;
        message = 'No pending tasks';
        break;
      case 'in-progress':
        icon = Icons.hourglass_empty;
        message = 'No tasks in progress';
        break;
      case 'done':
        icon = Icons.task_alt;
        message = 'No completed tasks';
        break;
      default:
        icon = Icons.add_task;
        message = 'No tasks yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
