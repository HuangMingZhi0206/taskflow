import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> user;

  const TaskDetailScreen({super.key, required this.taskId, required this.user});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _reportController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isSubmittingReport = false;
  String _commentType = 'text'; // text, file, link
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void dispose() {
    _reportController.dispose();
    _linkController.dispose();
    super.dispose();
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

  Future<void> _updateStatus(
    String newStatus,
    List<Map<String, dynamic>> reports,
  ) async {
    
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated to ${AppTheme.getStatusLabel(newStatus)}',
            ),
            backgroundColor: AppTheme.secondary,
          ),
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
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'xlsx',
          'xls',
        ],
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog('You must be logged in to comment.');
      return;
    }

    final commentText = _reportController.text.trim();
    final linkUrl = _linkController.text.trim();

    if (commentText.isEmpty && _selectedFilePath == null && linkUrl.isEmpty) {
      _showErrorDialog('Please enter a comment, add a file, or provide a link');
      return;
    }

    setState(() => _isSubmittingReport = true);

    try {
      String? attachmentUrl;
      if (_selectedFilePath != null) {
        final fileName =
            '${currentUser.uid}-${DateTime.now().millisecondsSinceEpoch}-${path.basename(_selectedFilePath!)}';
        final ref = FirebaseStorage.instance.ref(
          'task_attachments/${widget.taskId}/$fileName',
        );
        final uploadTask = await ref.putFile(File(_selectedFilePath!));
        attachmentUrl = await uploadTask.ref.getDownloadURL();
      }

      final report = {
        'comment_text': commentText.isNotEmpty
            ? commentText
            : (_commentType == 'file'
                  ? 'Attached: $_selectedFileName'
                  : 'Link: $linkUrl'),
        'reported_by': currentUser.uid,
        'reporter_name': widget.user['name'] ?? 'Anonymous',
        'reported_at': FieldValue.serverTimestamp(),
        'comment_type': _commentType,
        'attachment_path':
            attachmentUrl ?? (_commentType == 'link' ? linkUrl : null),
      };

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .collection('comments')
          .add(report);

      _reportController.clear();
      _linkController.clear();
      _clearAttachment();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment submitted successfully'),
            backgroundColor: AppTheme.secondary,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .snapshots(),
      builder: (context, taskSnapshot) {
        if (taskSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!taskSnapshot.hasData || taskSnapshot.data!.data() == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Task Details'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
            ),
            body: const Center(child: Text('Task not found')),
          );
        }

        final task = taskSnapshot.data!.data()!;
        final priorityColor = AppTheme.getPriorityColor(task['priority']);
        final statusColor = AppTheme.getStatusColor(task['status']);
        final deadline = (task['deadline'] as Timestamp).toDate();
        final createdAt = (task['created_at'] as Timestamp).toDate();
        final isAssignee = widget.user['id'] == task['userId'];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Task Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .doc(widget.taskId)
                .collection('comments')
                .orderBy('reported_at', descending: true)
                .snapshots(),
            builder: (context, commentSnapshot) {
              final reports = commentSnapshot.hasData
                  ? commentSnapshot.data!.docs
                        .map((doc) => {'id': doc.id, ...doc.data()})
                        .toList()
                  : <Map<String, dynamic>>[];

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.textLight.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (task['priority'] ?? 'N/A').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                AppTheme.getStatusLabel(
                                  task['status'] ?? 'N/A',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          task['title'] ?? 'Untitled Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task['description'] ?? 'No description',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white70
                                : AppTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: AppTheme.textLight.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.person_outline,
                          'Assigned To',
                          task['assignee_name'] ?? 'Unassigned',
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Deadline',
                          DateFormat('MMMM dd, yyyy').format(deadline),
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Created',
                          DateFormat('MMM dd, yyyy').format(createdAt),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Simple Completion Toggle
                  if (isAssignee)
                    GestureDetector(
                      onTap: () {
                        final newStatus = task['status'] == 'done'
                            ? 'todo'
                            : 'done';
                        _updateStatus(newStatus, reports);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: task['status'] == 'done'
                              ? AppTheme.statusDone.withValues(alpha: 0.1)
                              : AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: task['status'] == 'done'
                                ? AppTheme.statusDone
                                : AppTheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: task['status'] == 'done'
                                    ? AppTheme.statusDone
                                    : Colors.transparent,
                                border: Border.all(
                                  color: task['status'] == 'done'
                                      ? AppTheme.statusDone
                                      : AppTheme.primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: task['status'] == 'done'
                                  ? const Icon(
                                      Icons.check,
                                      size: 22,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['status'] == 'done'
                                        ? 'Task Completed'
                                        : 'Mark as Complete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: task['status'] == 'done'
                                          ? AppTheme.statusDone
                                          : AppTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    task['status'] == 'done'
                                        ? 'Tap to mark as incomplete'
                                        : 'Tap to mark this task as done',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              task['status'] == 'done'
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: task['status'] == 'done'
                                  ? AppTheme.statusDone
                                  : AppTheme.primary,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (isAssignee && task['status'] != 'done')
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.textLight.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (task['status'] == 'todo')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _updateStatus('in-progress', reports),
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Start Task'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.statusInProgress,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              if (task['status'] == 'in-progress') ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _updateStatus('done', reports),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Complete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.statusDone,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (isAssignee && task['status'] != 'done')
                    const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.textLight.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isAssignee) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCommentTypeChip(
                                  'text',
                                  'Text',
                                  Icons.text_fields,
                                ),
                                const SizedBox(width: 8),
                                _buildCommentTypeChip(
                                  'link',
                                  'Link',
                                  Icons.link,
                                ),
                                const SizedBox(width: 8),
                                _buildCommentTypeChip(
                                  'file',
                                  'File',
                                  Icons.attach_file,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_commentType == 'text') ...[
                            TextField(
                              controller: _reportController,
                              decoration: InputDecoration(
                                hintText: 'Add a progress update...',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
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
                                      onPressed: _isSubmittingReport
                                          ? null
                                          : _submitReport,
                                      color: AppTheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                          if (_commentType == 'link') ...[
                            TextField(
                              controller: _linkController,
                              decoration: InputDecoration(
                                hintText: 'Enter URL (e.g., https://...)',
                                prefixIcon: const Icon(Icons.link),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
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
                                  onPressed: _isSubmittingReport
                                      ? null
                                      : _submitReport,
                                  color: AppTheme.primary,
                                ),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _reportController,
                              decoration: InputDecoration(
                                hintText: 'Add description (optional)...',
                                prefixIcon: const Icon(Icons.description),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ],
                          if (_commentType == 'file') ...[
                            if (_selectedFilePath != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.insert_drive_file,
                                      color: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedFileName!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
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
                              const SizedBox(height: 12),
                              TextField(
                                controller: _reportController,
                                decoration: InputDecoration(
                                  hintText: 'Add description (optional)...',
                                  prefixIcon: const Icon(Icons.description),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isSubmittingReport
                                      ? null
                                      : _submitReport,
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
                                  label: const Text('Submit Report'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              OutlinedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Choose File'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supported: PDF, DOC, DOCX, TXT, JPG, PNG, XLSX, XLS',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                          const SizedBox(height: 24),
                          Divider(
                            color: AppTheme.textLight.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (reports.isEmpty)
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
                          ...reports.map(
                            (report) => _buildReportItem(report, isDark),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommentTypeChip(String type, String label, IconData icon) {
    final isSelected = _commentType == type;
    return GestureDetector(
      onTap: () {
        // Show under development for file upload
        if (type == 'file') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.construction,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '🚧 File Upload - Under Development\nComing Soon!',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          return;
        }

        setState(() {
          _commentType = type;
          // Clear attachment only when switching away from file type
          if (type != 'file' && _selectedFilePath != null) {
            _selectedFilePath = null;
            _selectedFileName = null;
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
            if (type == 'file')
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report, bool isDark) {
    final reportedAt =
        (report['reported_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, HH:mm').format(reportedAt);
    final commentType = report['comment_type'] ?? 'text';
    final attachmentPath = report['attachment_path'];
    final reporterName = report['reporter_name'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.1)),
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
                  reporterName.isNotEmpty ? reporterName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporterName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              if (commentType == 'file')
                const Icon(Icons.attach_file, size: 18, color: AppTheme.primary)
              else if (commentType == 'link')
                const Icon(Icons.link, size: 18, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report['comment_text'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppTheme.textPrimary,
            ),
          ),
          if (attachmentPath != null && attachmentPath.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (commentType == 'file')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.textLight.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        path.basename(attachmentPath),
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
                  // URL launcher logic here
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.textLight.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.link,
                        size: 20,
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 8),
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
                      const Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: AppTheme.secondary,
                      ),
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
