import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
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
  final _linkController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmittingReport = false;
  String _commentType = 'text'; // text, file, link
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _reportController.dispose();
    _linkController.dispose();
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
    // If trying to complete task, check if staff has uploaded file or link
    if (newStatus == 'done') {
      // Check if there are any file or link comments
      final hasFileOrLink = _reports.any((report) =>
        report['comment_type'] == 'file' || report['comment_type'] == 'link'
      );

      if (!hasFileOrLink) {
        _showErrorDialog(
          'You must upload a file or share a link before completing this task.\n\n'
          'Please add:\n'
          '• 📎 A file attachment (document, image, etc.), or\n'
          '• 🔗 A relevant link\n\n'
          'Then try completing the task again.'
        );
        return;
      }
    }

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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          _commentType = 'file';
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking file: $e');
    }
  }

  void _clearAttachment() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _commentType = 'text';
    });
  }

  Future<void> _submitReport() async {
    final commentText = _reportController.text.trim();
    final linkUrl = _linkController.text.trim();

    if (commentText.isEmpty && _selectedFilePath == null && linkUrl.isEmpty) {
      _showErrorDialog('Please enter a comment, add a file, or provide a link');
      return;
    }

    setState(() => _isSubmittingReport = true);

    try {
      final report = {
        'task_id': widget.taskId,
        'comment_text': commentText.isNotEmpty ? commentText : (_commentType == 'file' ? 'Attached: $_selectedFileName' : 'Link: $linkUrl'),
        'reported_by': widget.user['id'],
        'reported_at': DateTime.now().toIso8601String(),
        'comment_type': _commentType,
        'attachment_path': _selectedFilePath ?? (_commentType == 'link' ? linkUrl : null),
      };

      await DatabaseHelper.instance.addTaskComment(report);
      _reportController.clear();
      _linkController.clear();
      _clearAttachment();
      _loadTaskDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment submitted successfully')),
        );
      }
    } catch (e) {
      _showErrorDialog('Error submitting comment: $e');
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
                    // Comment Type Selector
                    Row(
                      children: [
                        _buildCommentTypeChip('text', 'Text', Icons.text_fields),
                        const SizedBox(width: 8),
                        _buildCommentTypeChip('link', 'Link', Icons.link),
                        const SizedBox(width: 8),
                        _buildCommentTypeChip('file', 'File', Icons.attach_file),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Text Input
                    if (_commentType == 'text') ...[
                      TextField(
                        controller: _reportController,
                        decoration: InputDecoration(
                          hintText: 'Add a progress update...',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _pickFile,
                                tooltip: 'Attach file',
                              ),
                              IconButton(
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
                            ],
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],

                    // Link Input
                    if (_commentType == 'link') ...[
                      TextField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          hintText: 'Enter URL (e.g., https://...)',
                          prefixIcon: const Icon(Icons.link),
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
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reportController,
                        decoration: const InputDecoration(
                          hintText: 'Add description (optional)...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                    ],

                    // File Upload
                    if (_commentType == 'file') ...[
                      if (_selectedFilePath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primary),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFileName!,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearAttachment,
                                color: AppTheme.urgent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reportController,
                          decoration: const InputDecoration(
                            hintText: 'Add description (optional)...',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isSubmittingReport ? null : _submitReport,
                          icon: _isSubmittingReport
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: const Text('Submit'),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose File'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported: PDF, DOC, DOCX, TXT, JPG, PNG, XLSX, XLS',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],

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

  Widget _buildCommentTypeChip(String type, String label, IconData icon) {
    final isSelected = _commentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _commentType = type;
          if (type != 'file') {
            _clearAttachment();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.textLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
    final commentType = report['comment_type'] ?? 'text';
    final attachmentPath = report['attachment_path'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
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
              // Comment type indicator
              if (commentType == 'file')
                const Icon(Icons.attach_file, size: 18, color: AppTheme.primary)
              else if (commentType == 'link')
                const Icon(Icons.link, size: 18, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report['comment_text'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),

          // File/Link attachment display
          if (attachmentPath != null && attachmentPath.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (commentType == 'file')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        attachmentPath.split('/').last,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else if (commentType == 'link')
              InkWell(
                onTap: () {
                  // URL will be opened here in future (requires url_launcher)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Link: $attachmentPath')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 16, color: AppTheme.secondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          attachmentPath,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondary,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 12, color: AppTheme.secondary),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

