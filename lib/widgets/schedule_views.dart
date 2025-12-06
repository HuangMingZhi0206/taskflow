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
            (a, b) =>
                _parseTime(a.startTime).compareTo(_parseTime(b.startTime)),
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
              childAspectRatio: 0.8,
            ),
            itemCount: daysInMonth + emptySlots,
            itemBuilder: (context, index) {
              if (index < emptySlots) {
                return Container();
              }
              final day = index - emptySlots + 1;
              final date = DateTime(focusedDate.year, focusedDate.month, day);
              final dayName = _getDayName(date.weekday);
              final eventsForDay = schedules
                  .where(
                    (s) =>
                        s.dayOfWeek.trim().toLowerCase() ==
                        dayName.toLowerCase(),
                  )
                  .toList();
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
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday ? AppTheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (eventsForDay.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: eventsForDay.take(3).map((e) {
                              return Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getColor(e),
                                ),
                              );
                            }).toList(),
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
