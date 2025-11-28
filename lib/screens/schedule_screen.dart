import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScheduleScreen({super.key, required this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ClassScheduleModel> _schedules = [];
  Map<String, CourseModel> _courses = {};
  bool _isLoading = true;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      // Load courses
      final courses = await CourseService.instance.getUserCourses(widget.user['id']);
      _courses = {for (var course in courses) course.id: course};

      // Load schedules
      final schedules = await CourseService.instance.getUserSchedules(widget.user['id']);
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading schedule: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ClassScheduleModel> _getSchedulesForDay(String day) {
    return _schedules
        .where((s) => s.dayOfWeek.toLowerCase() == day.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Color _getCourseColor(String courseId) {
    if (_courses.containsKey(courseId)) {
      final colorHex = _courses[courseId]!.color;
      return Color(int.parse('0xFF$colorHex'));
    }
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Class Schedule'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddScheduleDialog(),
            tooltip: 'Add Class',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? _buildEmptyState()
              : _buildScheduleView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text(
            'No classes scheduled yet',
            style: TextStyle(fontSize: 18, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your class schedule to get started',
            style: TextStyle(color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddScheduleDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final day = _days[index];
        final daySchedules = _getSchedulesForDay(day);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${daySchedules.length} class${daySchedules.length != 1 ? 'es' : ''}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (daySchedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'No classes',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                )
              else
                ...daySchedules.map((schedule) => _buildScheduleItem(schedule)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleItem(ClassScheduleModel schedule) {
    final course = _courses[schedule.courseId];
    final courseColor = _getCourseColor(schedule.courseId);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: courseColor, width: 4),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          course?.courseName ?? 'Unknown Course',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${schedule.startTime} - ${schedule.endTime}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (schedule.room != null)
              Text('Room: ${schedule.room}'),
            if (course?.courseCode != null)
              Text(course!.courseCode, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDeleteSchedule(schedule.id),
        ),
      ),
    );
  }

  void _showAddScheduleDialog() {
    // Navigate to add schedule screen or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class Schedule'),
        content: const Text(
          'To add classes to your schedule, first create a course in the Courses section, then add class times.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/courses', arguments: widget.user);
            },
            child: const Text('Go to Courses'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to remove this class from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await CourseService.instance.deleteClassSchedule(scheduleId);
                _loadSchedule();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class removed from schedule')),
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

