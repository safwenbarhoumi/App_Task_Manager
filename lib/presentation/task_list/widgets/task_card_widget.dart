import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = task['isCompleted'] as bool? ?? false;
    final priority = task['priority'] as String? ?? 'medium';
    final dueDate = task['dueDate'] as DateTime?;
    final category = task['category'] as String? ?? 'General';

    return Dismissible(
      key: Key(task['id'].toString()),
      background: _buildSwipeBackground(context, true),
      secondaryBackground: _buildSwipeBackground(context, false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggleComplete?.call();
        } else {
          onDelete?.call();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? colorScheme.primary
                                : colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? CustomIconWidget(
                                iconName: 'check',
                                color: Colors.white,
                                size: 4.w,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] as String? ?? 'Untitled Task',
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurface.withValues(alpha: 0.6)
                                  : colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task['description'] != null &&
                              (task['description'] as String).isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              task['description'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildPriorityIndicator(context, priority),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _buildCategoryChip(context, category),
                    const Spacer(),
                    if (dueDate != null) _buildDueDateChip(context, dueDate),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isComplete) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: isComplete ? 'check_circle' : 'delete',
                color: isComplete ? Colors.green : Colors.red,
                size: 6.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isComplete ? 'Complete' : 'Delete',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isComplete ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context, String priority) {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      width: 1.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context, DateTime dueDate) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now);
    final isToday = dueDate.day == now.day &&
        dueDate.month == now.month &&
        dueDate.year == now.year;

    Color chipColor;
    String dateText;

    if (isOverdue) {
      chipColor = Colors.red;
      dateText = 'Overdue';
    } else if (isToday) {
      chipColor = Colors.orange;
      dateText = 'Today';
    } else {
      chipColor = colorScheme.outline;
      final difference = dueDate.difference(now).inDays;
      if (difference == 1) {
        dateText = 'Tomorrow';
      } else if (difference < 7) {
        dateText = '${difference}d';
      } else {
        dateText = '${dueDate.day}/${dueDate.month}';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: 'schedule',
          color: chipColor,
          size: 3.w,
        ),
        SizedBox(width: 1.w),
        Text(
          dateText,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
