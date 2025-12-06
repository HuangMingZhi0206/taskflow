import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../theme/app_theme.dart';

class ScheduleDayView extends StatelessWidget {
  final String day;
  final List<ClassScheduleModel> schedules;
  final Map<String, CourseModel> courses;
  final Function(String) onDelete;
  final VoidCallback onAdd;

  const ScheduleDayView({
    super.key,
    required this.day,
    required this.schedules,
    required this.courses,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Height per hour (60 minutes)
        const double hourHeight = 80.0;
        const double startHour =
            0.0; // Show full day as requested/implied to be safe
        const double endHour = 24.0;
        const double totalHeight = (endHour - startHour) * hourHeight;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // Fab space
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // Background Grid
                ...List.generate((endHour - startHour).toInt(), (index) {
                  final hour = startHour + index;
                  return Positioned(
                    top: index * hourHeight,
                    left: 0,
                    right: 0,
                    height: hourHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.textLight.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          _formatHour(hour),
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Events with overlap detection
                ..._buildEventsWithOverlapHandling(
                  schedules,
                  startHour,
                  endHour,
                  hourHeight,
                  context,
                  constraints,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEventsWithOverlapHandling(
    List<ClassScheduleModel> schedules,
    double startHour,
    double endHour,
    double hourHeight,
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (schedules.isEmpty) return [];

    // Create event data with timing
    final eventData = schedules
        .map((schedule) {
          final start = _parseTime(schedule.startTime);
          final end = _parseTime(schedule.endTime);
          return {'schedule': schedule, 'start': start, 'end': end};
        })
        .where((e) {
          final start = e['start'] as double;
          return start >= startHour && start < endHour;
        })
        .toList();

    // Sort by start time, then by duration
    eventData.sort((a, b) {
      final startCompare = (a['start'] as double).compareTo(
        b['start'] as double,
      );
      if (startCompare != 0) return startCompare;
      return ((b['end'] as double) - (b['start'] as double)).compareTo(
        (a['end'] as double) - (a['start'] as double),
      );
    });

    // Group overlapping events
    final List<List<Map<String, dynamic>>> groups = [];
    for (final event in eventData) {
      bool added = false;
      for (final group in groups) {
        // Check if this event overlaps with any in the group
        bool overlaps = group.any((e) {
          final eStart = e['start'] as double;
          final eEnd = e['end'] as double;
          final eventStart = event['start'] as double;
          final eventEnd = event['end'] as double;
          return eventStart < eEnd && eventEnd > eStart;
        });

        if (overlaps) {
          group.add(event);
          added = true;
          break;
        }
      }

      if (!added) {
        groups.add([event]);
      }
    }

    // Build positioned widgets
    final List<Widget> widgets = [];
    const double leftMargin = 60.0;
    const double rightMargin = 16.0;

    for (final group in groups) {
      final int columnCount = group.length;

      for (int i = 0; i < group.length; i++) {
        final event = group[i];
        final schedule = event['schedule'] as ClassScheduleModel;
        final start = event['start'] as double;
        final end = event['end'] as double;

        final double startOffset = (start - startHour) * hourHeight;
        final double duration = end - start;
        final double height = duration * hourHeight > 24
            ? duration * hourHeight
            : 24;

        // Calculate horizontal position
        final availableWidth = constraints.maxWidth - leftMargin - rightMargin;
        final columnWidth = availableWidth / columnCount;
        final left = leftMargin + (i * columnWidth);
        final width = columnWidth - 4; // Small gap between columns

        widgets.add(
          Positioned(
            top: startOffset,
            left: left,
            width: width,
            height: height,
            child: _buildEventCard(context, schedule),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildEventCard(BuildContext context, ClassScheduleModel schedule) {
    // Try to get data from model first, then fallback to courses map
    String name = schedule.courseName ?? 'Unknown Course';
    Color color = AppTheme.primary;

    if (courses.containsKey(schedule.courseId)) {
      final course = courses[schedule.courseId]!;
      name = course.courseName;
      color = Color(int.parse('0xFF${course.color}'));
    } else if (schedule.color != null) {
      color = Color(int.parse('0xFF${schedule.color}'));
    }

    return GestureDetector(
      onLongPress: () => onDelete(schedule.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ), // Space for delete icon
                      child: Text(
                        name,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                    ),
                    if (schedule.room != null)
                      Text(
                        schedule.room!,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => onDelete(schedule.id),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseTime(String timeStr) {
    try {
      // Clean string
      timeStr = timeStr.trim().toUpperCase();

      bool isPm = timeStr.contains('PM') || timeStr.contains('P.M');
      bool isAm = timeStr.contains('AM') || timeStr.contains('A.M');

      // Replace dot separator logic if user inputs HH.MM
      String cleanTime = timeStr.replaceAll('.', ':');

      // Remove all non-numeric and non-colon characters
      cleanTime = cleanTime.replaceAll(RegExp(r'[^0-9:]'), '');

      if (cleanTime.isEmpty) return 0;

      // Split
      final parts = cleanTime.split(':');
      if (parts.isEmpty) return 0;

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 && parts[1].isNotEmpty
          ? int.parse(parts[1])
          : 0;

      if (isPm && hour != 12) {
        hour += 12;
      } else if (isAm && hour == 12) {
        hour = 0;
      }

      return hour + (minute / 60.0);
    } catch (e) {
      debugPrint('Error parsing time $timeStr: $e');
      return 0; // Prevent crash, return valid double
    }
  }

  String _formatHour(double hour) {
    final h = hour.toInt();
    final ampm = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH $ampm';
  }
}
