import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeekCalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final List<Map<String, dynamic>> tasks;
  final Function(DateTime) onDateTap;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(DateTime) onLongPress;
  final Set<String> visibleCategories;

  const WeekCalendarWidget({
    super.key,
    required this.currentDate,
    required this.tasks,
    required this.onDateTap,
    required this.onTaskTap,
    required this.onLongPress,
    required this.visibleCategories,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          _buildWeekHeader(startOfWeek),
          SizedBox(height: 2.h),
          Expanded(
            child: _buildWeekView(startOfWeek),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(DateTime startOfWeek) {
    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = _isToday(date);

        return Expanded(
          child: GestureDetector(
            onTap: () => onDateTap(date),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _getWeekdayName(date.weekday),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isToday
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWeekView(DateTime startOfWeek) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeColumn(),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildTasksGrid(startOfWeek),
        ),
      ],
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 12.w,
      child: Column(
        children: List.generate(24, (hour) {
          return Container(
            height: 8.h,
            alignment: Alignment.topCenter,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTasksGrid(DateTime startOfWeek) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 24 * 8.h,
        child: Row(
          children: List.generate(7, (dayIndex) {
            final date = startOfWeek.add(Duration(days: dayIndex));
            return Expanded(
              child: _buildDayColumn(date),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime date) {
    final dayTasks = _getTasksForDate(date);

    return GestureDetector(
      onLongPress: () => onLongPress(date),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Hour grid lines
            ...List.generate(24, (hour) {
              return Positioned(
                top: hour * 8.h,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                ),
              );
            }),
            // Tasks
            ...dayTasks
                .where((task) => visibleCategories
                    .contains(task['category'] as String? ?? 'General'))
                .map((task) => _buildTaskBlock(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBlock(Map<String, dynamic> task) {
    final startTime = task['startTime'] as DateTime? ?? DateTime.now();
    final duration = task['duration'] as int? ?? 60; // minutes
    final priority = task['priority'] as String? ?? 'medium';
    final title = task['title'] as String? ?? 'Untitled Task';

    final topPosition = (startTime.hour + startTime.minute / 60) * 8.h;
    final height = (duration / 60) * 8.h;

    return Positioned(
      top: topPosition,
      left: 1.w,
      right: 1.w,
      height: height,
      child: GestureDetector(
        onTap: () => onTaskTap(task),
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _getTaskColor(priority).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getTaskColor(priority),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 6.h) ...[
                SizedBox(height: 0.5.h),
                Text(
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    return (tasks as List)
        .where((dynamic task) {
          final taskMap = task as Map<String, dynamic>;
          final dueDate = taskMap['dueDate'] as DateTime?;
          if (dueDate == null) return false;

          return dueDate.year == date.year &&
              dueDate.month == date.month &&
              dueDate.day == date.day;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  Color _getTaskColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'medium':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'low':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
