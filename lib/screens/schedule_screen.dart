import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/schedule_views.dart';
import '../widgets/google_calendar_views.dart';

enum ViewMode { day, week, month }

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScheduleScreen({super.key, required this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Calendar state
  DateTime _selectedDate = DateTime.now();
  late DateTime _startOfWeek;

  List<ClassScheduleModel> _schedules = [];
  Map<String, CourseModel> _courses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Align to the start of the week (Monday)
    _startOfWeek = _getStartOfWeek(DateTime.now());
    _loadSchedule();
  }

  DateTime _getStartOfWeek(DateTime date) {
    // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.user['id'].toString();

      // 1. Fetch Courses
      final courses = await CourseService.instance.getUserCourses(userId);
      _courses = {for (var course in courses) course.id: course};

      // 2. Fetch Class Schedules & General Events
      final schedules = await CourseService.instance.getUserSchedules(userId);

      // 3. Fetch Tasks
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      final taskEvents = tasksSnapshot.docs
          .map((doc) {
            final data = doc.data();
            DateTime? dueDate;
            if (data['deadline'] != null) {
              if (data['deadline'] is Timestamp) {
                dueDate = (data['deadline'] as Timestamp).toDate();
              } else if (data['deadline'] is String) {
                dueDate = DateTime.tryParse(data['deadline']);
              }
            }

            if (dueDate == null) return null;

            // Map weekday to string
            final dayNames = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];
            final dayName = dayNames[dueDate.weekday - 1];

            // Determine Color based on priority
            String color = '64748b'; // Default Grey
            final priority = data['priority']?.toString().toLowerCase();
            if (priority == 'urgent') {
              color = 'ef4444';
            } else if (priority == 'medium') {
              color = 'f59e0b';
            } else if (priority == 'low') {
              color = '10b981';
            }

            // Use a reasonable default time (9 AM) if deadline is just a date
            // This ensures tasks are visible in day/week views
            DateTime taskStartTime = dueDate;
            if (taskStartTime.hour == 0 && taskStartTime.minute == 0) {
              taskStartTime = DateTime(
                dueDate.year,
                dueDate.month,
                dueDate.day,
                9, // Default to 9 AM
                0,
              );
            }

            debugPrint('Task: ${data['title']}, Time: ${_formatTime(taskStartTime)}, Date: ${DateTime(dueDate.year, dueDate.month, dueDate.day)}');

            final taskModel = ClassScheduleModel(
              id: doc.id,
              userId: userId,
              courseId: null,
              courseName: data['title'] ?? 'Untitled Task',
              dayOfWeek: dayName,
              startTime: _formatTime(taskStartTime),
              endTime: _formatTime(taskStartTime.add(const Duration(hours: 1))),
              color: color,
              type: 'task',
              isActive: true,
              specificDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
            );

            debugPrint('Created task model: ${taskModel.courseName}, start: ${taskModel.startTime}, type: ${taskModel.type}, specificDate: ${taskModel.specificDate}');
            return taskModel;
          })
          .whereType<ClassScheduleModel>()
          .toList();

      debugPrint('Loaded ${schedules.length} schedules and ${taskEvents.length} tasks');
      debugPrint('Sample task events: ${taskEvents.take(3).map((t) => '${t.courseName} at ${t.startTime}').join(', ')}');

      if (!mounted) return;

      setState(() {
        _schedules = [...schedules, ...taskEvents];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading schedule: $e')));
      }
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }


  // View Modes
  ViewMode _viewMode = ViewMode.day;

  // ... (schedules and courses same)

  // ... (initState same)

  void _changeDate(int offset) {
    setState(() {
      if (_viewMode == ViewMode.day) {
        _selectedDate = _selectedDate.add(Duration(days: offset));
        _startOfWeek = _getStartOfWeek(_selectedDate);
      } else if (_viewMode == ViewMode.week) {
        _startOfWeek = _startOfWeek.add(Duration(days: offset * 7));
        _selectedDate = _startOfWeek;
      } else if (_viewMode == ViewMode.month) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + offset,
          1,
        );
        _startOfWeek = _getStartOfWeek(_selectedDate);
      }
    });
  }

  // ... (keep build method signature)

  String _getShortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String titleText = '';
    if (_viewMode == ViewMode.day) {
      titleText = isSameDay(_selectedDate, DateTime.now())
          ? 'Today'
          : '${_getDayName(_selectedDate.weekday)}, ${_getShortMonthName(_selectedDate.month)} ${_selectedDate.day}';
    } else if (_viewMode == ViewMode.week) {
      final endOfWeek = _startOfWeek.add(const Duration(days: 6));
      titleText =
          '${_getShortMonthName(_startOfWeek.month)} ${_startOfWeek.day} - ${_getShortMonthName(endOfWeek.month)} ${endOfWeek.day}';
    } else {
      titleText =
          '${_getShortMonthName(_selectedDate.month)} ${_selectedDate.year}';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          titleText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _startOfWeek = _getStartOfWeek(_selectedDate);
              });
            },
            tooltip: 'Go to Today',
          ),
          PopupMenuButton<ViewMode>(
            icon: const Icon(
              Icons.calendar_view_month,
            ),
            onSelected: (mode) => setState(() => _viewMode = mode),
            itemBuilder: (context) => [
              const PopupMenuItem(value: ViewMode.day, child: Text('Day View')),
              const PopupMenuItem(
                value: ViewMode.week,
                child: Text('Week View'),
              ),
              const PopupMenuItem(
                value: ViewMode.month,
                child: Text('Month View'),
              ),
            ],
            tooltip: 'Change View',
          ),
        ],
      ),
      // ... body keeps navigation row logic but uses short month names
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(-1),
                ),
                Text(
                  _viewMode == ViewMode.day
                      ? '${_getShortMonthName(_selectedDate.month)} ${_selectedDate.year}'
                      : _viewMode == ViewMode.week
                      ? 'Week of ${_getShortMonthName(_startOfWeek.month)} ${_startOfWeek.day}'
                      : '${_selectedDate.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),
          // ... rest of body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildViewContent(),
          ),
        ],
      ),
      // ... FAB and BottomNavBar same
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleSheet(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              arguments: widget.user,
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/focus',
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
      ),
    );
  }

  // ... _buildViewContent same (uses local getters which we updated/will update)

  // ... _getDayName same

  // _showAddScheduleSheet updated
  void _showAddScheduleSheet() {
    // Variables for the sheet state
    String? selectedCourseId = _courses.isNotEmpty ? _courses.keys.first : null;
    String selectedDay = _getDayName(_selectedDate.weekday);
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);
    final roomController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isGeneralEvent = false;

    // List of days for dropdown
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isGeneralEvent ? 'Add Event' : 'Add Class',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Event', style: TextStyle(fontSize: 12)),
                      Switch(
                        value: isGeneralEvent,
                        onChanged: (val) {
                          setSheetState(() => isGeneralEvent = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (!isGeneralEvent) ...[
                Row(
                  children: [
                    Expanded(
                      child: _courses.isEmpty
                          ? const Text('No courses available.')
                          : DropdownButtonFormField<String>(
                              // ignore: deprecated_member_use
                              value: selectedCourseId,
                              decoration: const InputDecoration(
                                labelText: 'Course',
                              ),
                              items: _courses.values.map((course) {
                                return DropdownMenuItem(
                                  value: course.id,
                                  child: Text(course.courseName),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setSheetState(() => selectedCourseId = val!),
                            ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                      onPressed: () {
                        // Close sheet and navigate to create course or show dialog
                        // Using dialog for flexibility
                        Navigator.pop(sheetContext);
                        _showCreateCourseDialog();
                      },
                    ),
                  ],
                ),
              ] else ...[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ... Day, Time, Room, Save Button (Same as before)
              // Only showing modified parts for brevity, but full method needed for replacement
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: days.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (val) => setSheetState(() => selectedDay = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: sheetContext,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          setSheetState(() => startTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                        ),
                        child: Text(startTime.format(sheetContext)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: sheetContext,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          setSheetState(() => endTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                        ),
                        child: Text(endTime.format(sheetContext)),
                      ),
                    ),
                  ),
                ],
              ),
              // Show warning if end time is before or equal to start time
              Builder(
                builder: (context) {
                  final startMinutes = startTime.hour * 60 + startTime.minute;
                  final endMinutes = endTime.hour * 60 + endTime.minute;
                  final isInvalid = endMinutes <= startMinutes;

                  return isInvalid
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red[700],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'End time must be after start time',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: 'Location/Room (Optional)',
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Validate time: End time must be after start time
                      final startMinutes = startTime.hour * 60 + startTime.minute;
                      final endMinutes = endTime.hour * 60 + endTime.minute;

                      if (endMinutes <= startMinutes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (isGeneralEvent) {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Title is required')),
                          );
                          return;
                        }
                        await CourseService.instance.addGeneralSchedule(
                          userId: widget.user['id'],
                          title: titleController.text,
                          dayOfWeek: selectedDay,
                          startTime: startTime.format(context),
                          endTime: endTime.format(context),
                          room: roomController.text.isEmpty
                              ? null
                              : roomController.text,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                        );
                      } else {
                        if (selectedCourseId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a course'),
                            ),
                          );
                          return;
                        }
                        await CourseService.instance.addClassSchedule(
                          userId: widget.user['id'],
                          courseId: selectedCourseId!,
                          dayOfWeek: selectedDay,
                          startTime: startTime.format(context),
                          endTime: endTime.format(context),
                          room: roomController.text.isEmpty
                              ? null
                              : roomController.text,
                        );
                      }
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      if (!mounted) return; // Ensure screen is still mounted
                      _loadSchedule();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isGeneralEvent ? 'Event added' : 'Class added',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: Text(
                    isGeneralEvent ? 'Add Event' : 'Add Class Schedule',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewContent() {
    if (_viewMode == ViewMode.day) {
      return GoogleCalendarDayView(
        date: _selectedDate,
        schedules: _schedules,
        courses: _courses,
        onDelete: _confirmDeleteSchedule,
        onTap: (schedule) {
          // Optional: Show schedule details
          _showScheduleDetails(schedule);
        },
      );
    } else if (_viewMode == ViewMode.week) {
      return GoogleCalendarWeekView(
        startOfWeek: _startOfWeek,
        schedules: _schedules,
        courses: _courses,
        onDelete: _confirmDeleteSchedule,
        onTap: (schedule) {
          _showScheduleDetails(schedule);
        },
      );
    } else {
      return ScheduleMonthView(
        focusedDate: _selectedDate,
        schedules: _schedules,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
            _viewMode = ViewMode.day; // Drill down to day view
            _startOfWeek = _getStartOfWeek(date);
          });
        },
      );
    }
  }

  void _showScheduleDetails(ClassScheduleModel schedule) {
    final course = _courses[schedule.courseId];
    final colorStr = course?.color ?? schedule.color ?? '3b82f6';
    final color = Color(int.parse('0xFF$colorStr'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    schedule.type == 'task'
                        ? Icons.task_alt
                        : schedule.type == 'course'
                            ? Icons.school
                            : Icons.event,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.courseName ?? course?.courseName ?? 'Event',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule.type == 'task'
                              ? 'Task'
                              : schedule.type == 'course'
                                  ? 'Course'
                                  : 'Event',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Information Cards
            _buildInfoCard(
              icon: Icons.access_time,
              iconColor: color,
              title: 'Time',
              value: '${schedule.startTime} - ${schedule.endTime}',
              isDark: isDark,
            ),

            if (schedule.specificDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.calendar_today,
                iconColor: Colors.blue,
                title: 'Date',
                value: _formatDate(schedule.specificDate!),
                isDark: isDark,
              ),
            ] else ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.repeat,
                iconColor: Colors.purple,
                title: 'Recurring',
                value: 'Every ${schedule.dayOfWeek}',
                isDark: isDark,
              ),
            ],

            if (schedule.room != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.location_on,
                iconColor: Colors.red,
                title: 'Location',
                value: schedule.room!,
                isDark: isDark,
              ),
            ],

            if (course != null) ...[
              if (course.instructor != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.person,
                  iconColor: Colors.green,
                  title: 'Instructor',
                  value: course.instructor!,
                  isDark: isDark,
                ),
              ],
              if (course.courseCode != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.numbers,
                  iconColor: Colors.orange,
                  title: 'Course Code',
                  value: course.courseCode!,
                  isDark: isDark,
                ),
              ],
              if (course.credits != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: 'Credits',
                  value: '${course.credits} SKS',
                  isDark: isDark,
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteSchedule(schedule.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.urgent,
                      side: const BorderSide(color: AppTheme.urgent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textLight.withValues(alpha: 0.1),
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
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showCreateCourseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final instructorController = TextEditingController();
    final roomController = TextEditingController();
    final creditsController = TextEditingController();

    String selectedColor = '3b82f6'; // Default blue

    final colors = [
      {'name': 'Blue', 'value': '3b82f6'},
      {'name': 'Red', 'value': 'ef4444'},
      {'name': 'Green', 'value': '10b981'},
      {'name': 'Purple', 'value': '9c27b0'},
      {'name': 'Orange', 'value': 'f97316'},
      {'name': 'Pink', 'value': 'ec4899'},
      {'name': 'Teal', 'value': '14b8a6'},
      {'name': 'Indigo', 'value': '6366f1'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.textLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Create New Course',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Course Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Course Name *',
                      hintText: 'e.g., Data Structures',
                      prefixIcon: const Icon(Icons.book),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Course Code
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Course Code',
                      hintText: 'e.g., CS202',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instructor
                  TextField(
                    controller: instructorController,
                    decoration: InputDecoration(
                      labelText: 'Instructor',
                      hintText: 'e.g., Dr. Smith',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Room & Credits Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: roomController,
                          decoration: InputDecoration(
                            labelText: 'Default Room',
                            hintText: 'e.g., A216',
                            prefixIcon: const Icon(Icons.location_on, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: creditsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Credits (SKS)',
                            hintText: '3',
                            prefixIcon: const Icon(Icons.star, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Color Picker
                  const Text(
                    'Course Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colors.map((colorData) {
                      final colorValue = colorData['value']!;
                      final color = Color(int.parse('0xFF$colorValue'));
                      final isSelected = selectedColor == colorValue;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedColor = colorValue);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Course name is required'),
                                ),
                              );
                              return;
                            }

                            try {
                              final courseCode = codeController.text.trim().isNotEmpty
                                  ? codeController.text.trim()
                                  : 'COURSE-${DateTime.now().millisecondsSinceEpoch}';

                              await CourseService.instance.createCourse(
                                userId: widget.user['id'],
                                courseName: nameController.text.trim(),
                                courseCode: courseCode,
                                instructor: instructorController.text.trim().isNotEmpty
                                    ? instructorController.text.trim()
                                    : null,
                                room: roomController.text.trim().isNotEmpty
                                    ? roomController.text.trim()
                                    : null,
                                color: selectedColor,
                              );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              if (!mounted) return;
                              _loadSchedule();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ ${nameController.text} created successfully!',
                                  ),
                                  backgroundColor: AppTheme.primary,
                                ),
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Create Course',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteSchedule(String scheduleId) {
    final scheduleItem = _schedules.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => ClassScheduleModel(
        id: 'unknown',
        userId: '',
        courseName: '',
        dayOfWeek: '',
        startTime: '',
        endTime: '',
        color: '',
        type: 'unknown',
        isActive: false,
      ),
    );

    if (scheduleItem.id == 'unknown') return;

    final isTask = scheduleItem.type == 'task';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isTask ? 'Delete Task' : 'Delete Class'),
        content: Text(
          isTask
              ? 'Are you sure you want to delete this task?'
              : 'Are you sure you want to remove this class from your schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (isTask) {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(scheduleId)
                      .delete();
                } else {
                  await CourseService.instance.deleteClassSchedule(scheduleId);
                }

                if (!mounted) return;
                _loadSchedule();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTask
                          ? 'Task deleted successfully'
                          : 'Class removed from schedule',
                    ),
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
