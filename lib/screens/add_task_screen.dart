import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AddTaskScreen({super.key, required this.user});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedHoursController = TextEditingController();

  String _selectedPriority = 'medium';
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog('You must be logged in to create a task.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final task = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assignee_name': widget.user['name'],
        'userId': currentUser.uid,
        'priority': _selectedPriority,
        'status': 'todo',
        'deadline': Timestamp.fromDate(_selectedDeadline),
        'created_at': FieldValue.serverTimestamp(),
        'created_by': currentUser.uid,
        'tags': [],
        'estimated_hours': _estimatedHoursController.text.isNotEmpty
            ? double.tryParse(_estimatedHoursController.text)
            : null,
      };

      await FirebaseFirestore.instance.collection('tasks').add(task);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully'),
          backgroundColor: AppTheme.secondary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorDialog('Error creating task: $e');
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    bool isDark,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textLight.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.textLight.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      filled: true,
      fillColor: isDark ? AppTheme.darkSurface : Colors.white,
      labelStyle: TextStyle(color: AppTheme.textLight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Create New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title Input
            TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration(
                'Task Title',
                Icons.title,
                isDark,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description Input
            TextFormField(
              controller: _descriptionController,
              decoration: _buildInputDecoration(
                'Description',
                Icons.description_outlined,
                isDark,
              ).copyWith(alignLabelWithHint: true),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Estimated Hours Input
            TextFormField(
              controller: _estimatedHoursController,
              decoration: _buildInputDecoration(
                'Estimated Hours (Optional)',
                Icons.access_time,
                isDark,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = double.tryParse(value);
                  if (hours == null || hours <= 0) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Priority Selection
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPriorityCard(
                    'urgent',
                    'Urgent',
                    AppTheme.urgent,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriorityCard(
                    'medium',
                    'Medium',
                    AppTheme.medium,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriorityCard('low', 'Low', AppTheme.low, isDark),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Deadline Selection
            Text(
              'Deadline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDeadline,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.textLight.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDeadline),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textLight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 16),

            // Create Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Create Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    final isSelected = _selectedPriority == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : AppTheme.textLight.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(value),
              color: isSelected ? color : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.info_outline_rounded;
      case 'low':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
