import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CoursesScreen({super.key, required this.user});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    try {
      final courses = await CourseService.instance.getUserCourses(widget.user['id']);
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getCourseColor(String colorHex) {
    try {
      return Color(int.parse('0xFF$colorHex'));
    } catch (e) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 My Courses'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? _buildEmptyState()
              : _buildCoursesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text(
            'No courses yet',
            style: TextStyle(fontSize: 18, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your courses to get started',
            style: TextStyle(color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCourseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Course'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final courseColor = _getCourseColor(course.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCourseDetailsDialog(course),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: courseColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: courseColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (course.instructor != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '👨‍🏫 ${course.instructor}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCourseDialog(course);
                  } else if (value == 'schedule') {
                    _showAddScheduleDialog(course);
                  } else if (value == 'delete') {
                    _confirmDeleteCourse(course);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 8),
                        Text('Add Schedule'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
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

  void _showAddCourseDialog() {
    final courseCodeController = TextEditingController();
    final courseNameController = TextEditingController();
    final instructorController = TextEditingController();
    final roomController = TextEditingController();
    String selectedColor = '3b82f6'; // Default blue

    final colors = {
      'Blue': '3b82f6',
      'Red': 'ef4444',
      'Green': '10b981',
      'Yellow': 'f59e0b',
      'Purple': '8b5cf6',
      'Pink': 'ec4899',
      'Indigo': '6366f1',
      'Teal': '14b8a6',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code *',
                    hintText: 'e.g., CS101',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g., Introduction to Programming',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor (Optional)',
                    hintText: 'e.g., Dr. Smith',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room (Optional)',
                    hintText: 'e.g., Room 301',
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Course Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.entries.map((entry) {
                    final isSelected = selectedColor == entry.value;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = entry.value),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse('0xFF${entry.value}')),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (courseCodeController.text.trim().isEmpty ||
                    courseNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  await CourseService.instance.createCourse(
                    userId: widget.user['id'],
                    courseCode: courseCodeController.text.trim(),
                    courseName: courseNameController.text.trim(),
                    instructor: instructorController.text.trim().isEmpty
                        ? null
                        : instructorController.text.trim(),
                    room: roomController.text.trim().isEmpty
                        ? null
                        : roomController.text.trim(),
                    color: selectedColor,
                  );

                  Navigator.pop(context);
                  _loadCourses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Course added!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    // Similar to add, but pre-filled
    // Implementation abbreviated for brevity
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  void _showCourseDetailsDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.courseCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (course.instructor != null) ...[
              const SizedBox(height: 12),
              Text('Instructor: ${course.instructor}'),
            ],
            if (course.room != null) ...[
              const SizedBox(height: 8),
              Text('Room: ${course.room}'),
            ],
            if (course.description != null) ...[
              const SizedBox(height: 8),
              Text(course.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(CourseModel course) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String? selectedDay;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Schedule for ${course.courseCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: daysOfWeek.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) => setState(() => selectedDay = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(startTime?.format(context) ?? 'Not set'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: startTime ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null) setState(() => startTime = time);
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(endTime?.format(context) ?? 'Not set'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: endTime ?? const TimeOfDay(hour: 10, minute: 30),
                  );
                  if (time != null) setState(() => endTime = time);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDay == null || startTime == null || endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await CourseService.instance.addClassSchedule(
                    courseId: course.id,
                    userId: widget.user['id'],
                    dayOfWeek: selectedDay!,
                    startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                    endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                    room: course.room,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Schedule added!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCourse(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.courseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await CourseService.instance.deleteCourse(course.id);
                _loadCourses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

