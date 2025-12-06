import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/schedule_views.dart';
import '../widgets/schedule_day_view.dart';

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

            return ClassScheduleModel(
              id: doc.id,
              userId: userId,
              courseId: null,
              courseName: data['title'] ?? 'Untitled Task',
              dayOfWeek: dayName,
              startTime: _formatTime(dueDate),
              endTime: _formatTime(dueDate.add(const Duration(hours: 1))),
              color: color,
              type: 'task',
              isActive: true,
              specificDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
            );
          })
          .whereType<ClassScheduleModel>()
          .toList();

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

  List<ClassScheduleModel> _getSchedulesForDate(DateTime date) {
    // Map weekday number to string names stored in DB
    // 1=Mon, ..., 7=Sun
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[date.weekday - 1];

    // Normalize date to midnight for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return _schedules.where((s) {
      // For one-time events (tasks), check specific date
      if (s.specificDate != null) {
        final scheduleDate = DateTime(
          s.specificDate!.year,
          s.specificDate!.month,
          s.specificDate!.day,
        );
        return scheduleDate == normalizedDate;
      }

      // For recurring events (classes), check day of week
      return s.dayOfWeek.trim().toLowerCase() == dayName.trim().toLowerCase();
    }).toList();
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
              Icons.calendar_month,
            ), // Calendar icon for View Mode
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
      return ScheduleDayView(
        day: _getDayName(_selectedDate.weekday),
        schedules: _getSchedulesForDate(_selectedDate),
        courses: _courses,
        onDelete: _confirmDeleteSchedule,
        onAdd: _showAddScheduleSheet,
      );
    } else if (_viewMode == ViewMode.week) {
      return ScheduleWeekView(
        startOfWeek: _startOfWeek,
        schedules: _schedules,
        courses: _courses,
        onDelete: _confirmDeleteSchedule,
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
    // Simple dialog to create a course quickly
    final nameController = TextEditingController();
    final codeController = TextEditingController(); // Optional

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Course Code (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                // Create course with a random color or default
                await CourseService.instance.createCourse(
                  userId: widget.user['id'],
                  courseName: nameController.text,
                  courseCode: codeController.text.isNotEmpty
                      ? codeController.text
                      : 'GEN-${DateTime.now().millisecondsSinceEpoch}', // Generate simple code if empty
                  color: '3b82f6', // Default blue
                  instructor: '',
                  room: '',
                  description: '', // Service uses 'description' not 'notes'
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return; // Ensure screen is mounted after pop
                _loadSchedule(); // Reload to fetch new course

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Course created')));
              } catch (e) {
                // Handle error
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(String scheduleId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text(
          'Are you sure you want to remove this class from your schedule?',
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
                await CourseService.instance.deleteClassSchedule(scheduleId);
                if (!mounted) return;
                _loadSchedule();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class removed from schedule')),
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
