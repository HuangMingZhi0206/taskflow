import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../theme/app_theme.dart';

class ScheduleWeekView extends StatelessWidget {
  final DateTime startOfWeek;
  final List<ClassScheduleModel> schedules;
  final Map<String, CourseModel> courses;
  final Function(String) onDelete;

  const ScheduleWeekView({
    super.key,
    required this.startOfWeek,
    required this.schedules,
    required this.courses,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final dayName = _getDayName(date.weekday);
          final daySchedules = schedules
              .where(
                (s) =>
                    s.dayOfWeek.trim().toLowerCase() == dayName.toLowerCase(),
              )
              .toList();

          // Sort by start time
          daySchedules.sort(
            (a, b) {
              final startComparison = _parseTime(a.startTime).compareTo(_parseTime(b.startTime));
              if (startComparison == 0) {
                // Validate that end time is not earlier than start time
                if (_parseTime(a.endTime) < _parseTime(a.startTime)) {
                  throw ArgumentError('End time cannot be earlier than start time for schedule: \\${a.courseName}');
                }
                if (_parseTime(b.endTime) < _parseTime(b.startTime)) {
                  throw ArgumentError('End time cannot be earlier than start time for schedule: \\${b.courseName}');
                }
              }
              return startComparison;
            },
          );

          return Container(
            width: 150, // Fixed width for each day column
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: isSameDay(date, DateTime.now())
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    '$dayName ${date.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSameDay(date, DateTime.now())
                          ? AppTheme.primary
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      400, // Constrain height or use Expanded within a sized container in parent
                  child: ListView.builder(
                    itemCount: daySchedules.length,
                    itemBuilder: (context, i) {
                      final schedule = daySchedules[i];
                      final course = courses[schedule.courseId];
                      final color = Color(
                        int.parse(
                          '0xFF${course?.color ?? schedule.color ?? '3b82f6'}',
                        ),
                      );

                      return GestureDetector(
                        onLongPress: () => onDelete(schedule.id),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            border: Border(
                              left: BorderSide(color: color, width: 4),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 18),
                                    child: Text(
                                      schedule.courseName ??
                                          course?.courseName ??
                                          'Untitled',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${schedule.startTime} - ${schedule.endTime}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  if (schedule.room != null)
                                    Text(
                                      schedule.room!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => onDelete(schedule.id),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: color.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
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

  double _parseTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(
        parts[1].split(' ')[0],
      ); // Handle AM/PM if present loosely
      return hour + minute / 60.0;
    } catch (e) {
      return 0;
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class ScheduleMonthView extends StatelessWidget {
  final DateTime focusedDate;
  final List<ClassScheduleModel> schedules;
  final Function(DateTime) onDateSelected;

  const ScheduleMonthView({
    super.key,
    required this.focusedDate,
    required this.schedules,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedDate.year,
      focusedDate.month,
    );
    final int firstWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun
    final int emptySlots = firstWeekday - 1;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.65, // Increased height for task titles
            ),
            itemCount: daysInMonth + emptySlots,
            itemBuilder: (context, index) {
              if (index < emptySlots) {
                return Container();
              }
              final day = index - emptySlots + 1;
              final date = DateTime(focusedDate.year, focusedDate.month, day);
              final dayName = _getDayName(date.weekday);
              final normalizedDate = DateTime(date.year, date.month, date.day);

              // Get events for this specific day
              final allEventsForDay = schedules.where((s) {
                // If event has a specific date, check exact date match
                if (s.specificDate != null) {
                  final scheduleDate = DateTime(
                    s.specificDate!.year,
                    s.specificDate!.month,
                    s.specificDate!.day,
                  );
                  return scheduleDate == normalizedDate;
                }
                // Otherwise, check recurring events by day of week
                return s.dayOfWeek.trim().toLowerCase() == dayName.toLowerCase();
              }).toList();

              // Deduplicate: keep only unique courses
              final Map<String, ClassScheduleModel> uniqueEvents = {};
              for (var event in allEventsForDay) {
                final key = event.courseId ?? event.courseName ?? event.id;
                if (!uniqueEvents.containsKey(key)) {
                  uniqueEvents[key] = event;
                }
              }
              final eventsForDay = uniqueEvents.values.toList();

              final isToday = isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : null,
                    border: isToday
                        ? Border.all(color: AppTheme.primary)
                        : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday ? AppTheme.primary : null,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (eventsForDay.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 2.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: eventsForDay.take(2).map((event) {
                                final color = _getColor(event);
                                final title = event.courseName ?? 'Event';
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      if (eventsForDay.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                          child: Text(
                            '+${eventsForDay.length - 2}',
                            style: TextStyle(
                              fontSize: 7,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColor(ClassScheduleModel schedule) {
    if (schedule.color != null) {
      return Color(int.parse('0xFF${schedule.color}'));
    }
    return Colors.blue;
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
}
