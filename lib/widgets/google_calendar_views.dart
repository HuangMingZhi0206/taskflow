import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Google Calendar-inspired Week View
class GoogleCalendarWeekView extends StatelessWidget {
  final DateTime startOfWeek;
  final List<ClassScheduleModel> schedules;
  final Map<String, CourseModel> courses;
  final Function(String) onDelete;
  final Function(ClassScheduleModel)? onTap;

  const GoogleCalendarWeekView({
    super.key,
    required this.startOfWeek,
    required this.schedules,
    required this.courses,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('Week View starting from ${startOfWeek.toString()}, Total schedules: ${schedules.length}');

    return Column(
      children: [
        // Day headers
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.textLight.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              // Time column header
              const SizedBox(width: 60),
              // Day headers
              ...List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final isToday = _isSameDay(date, DateTime.now());

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.textLight.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isToday
                                ? AppTheme.primary
                                : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? AppTheme.primary
                                : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? Colors.white
                                  : (isDark ? Colors.white : AppTheme.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Schedule grid
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time labels
                Column(
                  children: List.generate(24, (hour) {
                    return Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: Text(
                        _formatHour(hour),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight,
                        ),
                      ),
                    );
                  }),
                ),

                // Days grid
                Expanded(
                  child: Stack(
                    children: [
                      // Grid lines
                      Column(
                        children: List.generate(24, (hour) {
                          return Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.textLight.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: List.generate(7, (day) {
                                return Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: AppTheme.textLight.withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),

                      // Events - render for each day
                      ...List.generate(7, (dayIndex) {
                        final date = startOfWeek.add(Duration(days: dayIndex));
                        final daySchedules = _getSchedulesForDate(date);

                        debugPrint('Week View Day $dayIndex (${date.toString().split(' ')[0]}): ${daySchedules.length} schedules');
                        for (var s in daySchedules) {
                          debugPrint('  - ${s.courseName}: ${s.startTime} (type: ${s.type}, specificDate: ${s.specificDate})');
                        }

                        final eventLayout = _calculateEventColumns(daySchedules);
                        debugPrint('  Event layout: ${eventLayout.length} events to render');

                        final dayWidth = (MediaQuery.of(context).size.width - 60) / 7;
                        final dayLeft = dayWidth * dayIndex;

                        // Return multiple Positioned widgets, one for each event
                        return eventLayout.map((layout) {
                          final schedule = layout['schedule'] as ClassScheduleModel;
                          final column = layout['column'] as int;
                          final totalColumns = layout['totalColumns'] as int;

                          // Calculate position
                          final startMinutes = _parseTimeToMinutes(schedule.startTime);
                          final endMinutes = _parseTimeToMinutes(schedule.endTime);
                          final duration = endMinutes - startMinutes;
                          final topOffset = (startMinutes / 60.0) * 60.0;
                          final height = (duration / 60.0) * 60.0;

                          final course = courses[schedule.courseId];
                          final colorStr = course?.color ?? schedule.color ?? '3b82f6';
                          final color = Color(int.parse('0xFF$colorStr'));

                          final columnWidth = 1.0 / totalColumns;
                          final eventLeft = dayLeft + (dayWidth * column * columnWidth);
                          final eventWidth = dayWidth * columnWidth * 0.92; // Leave small gap

                          debugPrint('  📍 Positioning: ${schedule.courseName} at day=$dayIndex, top=$topOffset, height=$height, column=$column/$totalColumns');

                          return Positioned(
                            left: eventLeft,
                            top: topOffset,
                            width: eventWidth,
                            height: height,
                            child: GestureDetector(
                              onTap: () => onTap?.call(schedule),
                              onLongPress: () => onDelete(schedule.id),
                              child: Container(
                                margin: const EdgeInsets.only(right: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color.withOpacity(0.8), width: 1),
                                ),
                                padding: EdgeInsets.all(totalColumns > 1 ? 2 : 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      schedule.courseName ?? course?.courseName ?? 'Event',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: totalColumns > 1 ? 9 : 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (height > 40 && totalColumns <= 2)
                                      Text(
                                        schedule.startTime,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: totalColumns > 1 ? 8 : 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList();
                      }).expand((element) => element),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<ClassScheduleModel> _getSchedulesForDate(DateTime date) {
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
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return schedules.where((s) {
      if (s.specificDate != null) {
        final scheduleDate = DateTime(
          s.specificDate!.year,
          s.specificDate!.month,
          s.specificDate!.day,
        );
        return scheduleDate == normalizedDate;
      }
      return s.dayOfWeek.trim().toLowerCase() == dayName.trim().toLowerCase();
    }).toList()
      ..sort((a, b) => _parseTimeToMinutes(a.startTime).compareTo(
          _parseTimeToMinutes(b.startTime)));
  }

  // Calculate column layout for overlapping events
  List<Map<String, dynamic>> _calculateEventColumns(List<ClassScheduleModel> daySchedules) {
    if (daySchedules.isEmpty) return [];

    final List<Map<String, dynamic>> eventLayout = [];
    final List<List<int>> columns = [];

    for (var i = 0; i < daySchedules.length; i++) {
      final event = daySchedules[i];
      final startMinutes = _parseTimeToMinutes(event.startTime);
      final endMinutes = _parseTimeToMinutes(event.endTime);

      // Find which column this event should go in
      int columnIndex = -1;
      for (var col = 0; col < columns.length; col++) {
        bool canFit = true;
        for (var existingEventIndex in columns[col]) {
          final existing = daySchedules[existingEventIndex];
          final existingStart = _parseTimeToMinutes(existing.startTime);
          final existingEnd = _parseTimeToMinutes(existing.endTime);

          // Check if events overlap (including touching times)
          // Two events overlap if one starts before the other ends
          bool overlaps = (startMinutes < existingEnd && endMinutes > existingStart);

          if (overlaps) {
            canFit = false;
            break;
          }
        }
        if (canFit) {
          columnIndex = col;
          break;
        }
      }

      // Create new column if needed
      if (columnIndex == -1) {
        columnIndex = columns.length;
        columns.add([]);
      }
      columns[columnIndex].add(i);

      eventLayout.add({
        'schedule': event,
        'column': columnIndex,
        'totalColumns': columns.length,
      });
    }

    // Update totalColumns for all events
    for (var layout in eventLayout) {
      layout['totalColumns'] = columns.length;
    }

    return eventLayout;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  int _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final isPM = parts[1].toUpperCase() == 'PM';
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Google Calendar-inspired Day View
class GoogleCalendarDayView extends StatelessWidget {
  final DateTime date;
  final List<ClassScheduleModel> schedules;
  final Map<String, CourseModel> courses;
  final Function(String) onDelete;
  final Function(ClassScheduleModel)? onTap;

  const GoogleCalendarDayView({
    super.key,
    required this.date,
    required this.schedules,
    required this.courses,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daySchedules = _getSchedulesForDate();

    debugPrint('Day View for ${date.toString()}: ${daySchedules.length} schedules');
    for (var schedule in daySchedules) {
      debugPrint('  - ${schedule.courseName}: ${schedule.startTime} to ${schedule.endTime} (type: ${schedule.type}, specificDate: ${schedule.specificDate})');
    }

    final eventLayout = _calculateEventColumns(daySchedules);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels
          Column(
            children: List.generate(24, (hour) {
              return Container(
                height: 80,
                width: 60,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Text(
                  _formatHour(hour),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ),

          // Schedule column
          Expanded(
            child: Stack(
              children: [
                // Grid lines
                Column(
                  children: List.generate(24, (hour) {
                    return Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.textLight.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Current time indicator
                if (_isSameDay(date, DateTime.now()))
                  _buildCurrentTimeIndicator(),

                // Events with column layout
                ...eventLayout.map((layout) {
                  final schedule = layout['schedule'] as ClassScheduleModel;
                  final column = layout['column'] as int;
                  final totalColumns = layout['totalColumns'] as int;
                  return _buildDayEventBlock(
                    context,
                    schedule,
                    isDark,
                    column,
                    totalColumns,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Calculate column layout for overlapping events
  List<Map<String, dynamic>> _calculateEventColumns(List<ClassScheduleModel> daySchedules) {
    if (daySchedules.isEmpty) return [];

    debugPrint('🔍 Calculating columns for ${daySchedules.length} events');

    final List<Map<String, dynamic>> eventLayout = [];
    final List<List<int>> columns = [];

    for (var i = 0; i < daySchedules.length; i++) {
      final event = daySchedules[i];
      final startMinutes = _parseTimeToMinutes(event.startTime);
      final endMinutes = _parseTimeToMinutes(event.endTime);

      debugPrint('  Event $i: ${event.courseName} (${event.startTime}-${event.endTime}) = $startMinutes-$endMinutes minutes');

      // Find which column this event should go in
      int columnIndex = -1;
      for (var col = 0; col < columns.length; col++) {
        bool canFit = true;
        for (var existingEventIndex in columns[col]) {
          final existing = daySchedules[existingEventIndex];
          final existingStart = _parseTimeToMinutes(existing.startTime);
          final existingEnd = _parseTimeToMinutes(existing.endTime);

          // Check if events overlap (including touching times)
          // Two events overlap if one starts before the other ends
          bool overlaps = (startMinutes < existingEnd && endMinutes > existingStart);

          debugPrint('    Checking vs ${existing.courseName} ($existingStart-$existingEnd): overlaps=$overlaps');

          if (overlaps) {
            canFit = false;
            debugPrint('    ❌ Overlaps with ${existing.courseName} in column $col');
            break;
          }
        }
        if (canFit) {
          columnIndex = col;
          debugPrint('    ✅ Fits in existing column $col');
          break;
        }
      }

      // Create new column if needed
      if (columnIndex == -1) {
        columnIndex = columns.length;
        columns.add([]);
        debugPrint('    ➕ Created new column $columnIndex');
      }
      columns[columnIndex].add(i);

      eventLayout.add({
        'schedule': event,
        'column': columnIndex,
        'totalColumns': columns.length,
      });
    }

    // Update totalColumns for all events
    for (var layout in eventLayout) {
      layout['totalColumns'] = columns.length;
    }

    debugPrint('📊 Final layout: ${columns.length} columns');
    for (var i = 0; i < eventLayout.length; i++) {
      final layout = eventLayout[i];
      final schedule = layout['schedule'] as ClassScheduleModel;
      debugPrint('  ${schedule.courseName}: column ${layout['column']}/${layout['totalColumns']}');
    }

    return eventLayout;
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final topOffset = (minutes / 60.0) * 80.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.urgent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: AppTheme.urgent,
            ),
          ),
        ],
      ),
    );
  }

  List<ClassScheduleModel> _getSchedulesForDate() {
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
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return schedules.where((s) {
      if (s.specificDate != null) {
        final scheduleDate = DateTime(
          s.specificDate!.year,
          s.specificDate!.month,
          s.specificDate!.day,
        );
        return scheduleDate == normalizedDate;
      }
      return s.dayOfWeek.trim().toLowerCase() == dayName.trim().toLowerCase();
    }).toList()
      ..sort((a, b) => _parseTimeToMinutes(a.startTime).compareTo(
          _parseTimeToMinutes(b.startTime)));
  }

  Widget _buildDayEventBlock(
      BuildContext context,
      ClassScheduleModel schedule,
      bool isDark,
      int column,
      int totalColumns,
      ) {
    final course = courses[schedule.courseId];
    final colorStr = course?.color ?? schedule.color ?? '3b82f6';
    final color = Color(int.parse('0xFF$colorStr'));

    final startMinutes = _parseTimeToMinutes(schedule.startTime);
    final endMinutes = _parseTimeToMinutes(schedule.endTime);
    var duration = endMinutes - startMinutes;

    // Safeguard: Ensure positive duration (minimum 30 minutes)
    if (duration <= 0) {
      duration = 30; // Default to 30 minutes
    }

    final topOffset = (startMinutes / 60.0) * 80.0;
    var height = (duration / 60.0) * 80.0;

    // Safeguard: Ensure minimum height of 40px
    if (height < 40) {
      height = 40;
    }

    // Calculate width and left position for side-by-side events
    final columnWidthFraction = 1.0 / totalColumns;
    final leftOffsetFraction = column * columnWidthFraction;

    debugPrint('🔵 Building event: ${schedule.courseName}, column=$column/$totalColumns');
    debugPrint('  📐 columnWidth=$columnWidthFraction, leftOffset=$leftOffsetFraction, height=$height');

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: height,
      child: FractionallySizedBox(
        widthFactor: 1.0,
        alignment: Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final eventWidth = totalWidth * columnWidthFraction * 0.98;
            final eventLeftOffset = totalWidth * leftOffsetFraction;

            debugPrint('  🎯 totalWidth=$totalWidth, eventWidth=$eventWidth, eventLeftOffset=$eventLeftOffset');

            return Stack(
              children: [
                Positioned(
                  left: eventLeftOffset,
                  top: 0,
                  width: eventWidth,
                  height: height,
                  child: GestureDetector(
                    onTap: () => onTap?.call(schedule),
                    onLongPress: () => _showDeleteDialog(context, schedule),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4, right: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(totalColumns > 1 ? 6 : 12),
                      child: ClipRect(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      schedule.courseName ?? course?.courseName ?? 'Event',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: totalColumns > 1 ? 11 : 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (totalColumns == 1 && height > 60)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      color: Colors.white70,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => onDelete(schedule.id),
                                    ),
                                ],
                              ),
                              if (height > 50) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${schedule.startTime} - ${schedule.endTime}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: totalColumns > 1 ? 9 : 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (schedule.room != null && height > 70) ...[
                                const SizedBox(height: 2),
                                Text(
                                  schedule.room!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: totalColumns > 1 ? 9 : 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ClassScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${schedule.courseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(schedule.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  int _parseTimeToMinutes(String time) {
    try {
      final parts = time.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final isPM = parts[1].toUpperCase() == 'PM';
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}