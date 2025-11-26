import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final Map<String, dynamic> user;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.user,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? _task;
  List<Map<String, dynamic>> _reports = [];
  final _reportController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmittingReport = false;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    setState(() => _isLoading = true);

    try {
      final task = await DatabaseHelper.instance.getTaskById(widget.taskId);
      final reports = await DatabaseHelper.instance.getTaskComments(widget.taskId);

      setState(() {
        _task = task;
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading task details: $e');
    }
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

  Future<void> _updateStatus(String newStatus) async {
    try {
      await DatabaseHelper.instance.updateTaskStatus(widget.taskId, newStatus);
      _loadTaskDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${AppTheme.getStatusLabel(newStatus)}')),
        );
      }
    } catch (e) {
      _showErrorDialog('Error updating status: $e');
    }
  }

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a progress report');
      return;
    }

    setState(() => _isSubmittingReport = true);

    try {
      final report = {
        'task_id': widget.taskId,
        'comment_text': _reportController.text.trim(),
        'reported_by': widget.user['id'],
        'reported_at': DateTime.now().toIso8601String(),
        'comment_type': 'text',
      };

      await DatabaseHelper.instance.addTaskComment(report);
      _reportController.clear();
      _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress report submitted')),
        );
      }
    } catch (e) {
      _showErrorDialog('Error submitting report: $e');
    } finally {
      setState(() => _isSubmittingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found')),
      );
    }

    final priorityColor = AppTheme.getPriorityColor(_task!['priority']);
    final statusColor = AppTheme.getStatusColor(_task!['status']);
    final deadline = DateTime.parse(_task!['deadline']);
    final createdAt = DateTime.parse(_task!['created_at']);
    final isAssignee = widget.user['id'] == _task!['assignee_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Task Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                          _task!['priority'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          AppTheme.getStatusLabel(_task!['status']),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _task!['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _task!['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Assigned To',
                    _task!['assignee_name'],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Deadline',
                    DateFormat('MMMM dd, yyyy').format(deadline),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time,
                    'Created',
                    DateFormat('MMM dd, yyyy').format(createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Update Buttons (only for assignee)
          if (isAssignee && _task!['status'] != 'done')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_task!['status'] == 'todo')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus('in-progress'),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Task'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.statusInProgress,
                              ),
                            ),
                          ),
                        if (_task!['status'] == 'in-progress') ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus('done'),
                              icon: const Icon(Icons.check),
                              label: const Text('Complete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.statusDone,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (isAssignee && _task!['status'] != 'done')
            const SizedBox(height: 16),

          // Progress Reports Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Report (only for assignee)
                  if (isAssignee) ...[
                    TextField(
                      controller: _reportController,
                      decoration: InputDecoration(
                        hintText: 'Add a progress update...',
                        suffixIcon: IconButton(
                          icon: _isSubmittingReport
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isSubmittingReport ? null : _submitReport,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Reports List
                  if (_reports.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No progress reports yet',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._reports.map((report) => _buildReportItem(report)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final reportedAt = DateTime.parse(report['reported_at']);
    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(reportedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                child: Text(
                  report['reporter_name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['reporter_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report['report_text'],
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

