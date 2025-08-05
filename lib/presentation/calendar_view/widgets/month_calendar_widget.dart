import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MonthCalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final List<Map<String, dynamic>> tasks;
  final Function(DateTime) onDateTap;
  final Function(Map<String, dynamic>) onTaskTap;
  final Set<String> visibleCategories;

  const MonthCalendarWidget({
    super.key,
    required this.currentDate,
    required this.tasks,
    required this.onDateTap,
    required this.onTaskTap,
    required this.visibleCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          SizedBox(height: 1.h),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentDate.year, currentDate.month, day);
      final dayTasks = _getTasksForDate(date);
      dayWidgets.add(_buildDayCell(date, dayTasks));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.w,
      crossAxisSpacing: 1.w,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date, List<Map<String, dynamic>> dayTasks) {
    final isToday = _isToday(date);
    final isCurrentMonth = date.month == currentDate.month;
    final hasVisibleTasks = dayTasks
        .where((task) => visibleCategories
            .contains(task['category'] as String? ?? 'General'))
        .isNotEmpty;

    return GestureDetector(
      onTap: () => onDateTap(date),
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isCurrentMonth
                    ? (isToday
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface)
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.3),
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (hasVisibleTasks) ...[
              SizedBox(height: 0.5.h),
              _buildTaskIndicators(dayTasks),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIndicators(List<Map<String, dynamic>> dayTasks) {
    final visibleTasks = dayTasks
        .where((task) => visibleCategories
            .contains(task['category'] as String? ?? 'General'))
        .take(3)
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: visibleTasks.map((task) {
        final priority = task['priority'] as String? ?? 'medium';
        final category = task['category'] as String? ?? 'General';

        return Container(
          width: 1.5.w,
          height: 1.5.w,
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          decoration: BoxDecoration(
            color: _getTaskColor(priority, category),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
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

  Color _getTaskColor(String priority, String category) {
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
