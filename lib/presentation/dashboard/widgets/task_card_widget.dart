import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskCardWidget extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onShare,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _isCompleted = widget.task['isCompleted'] ?? false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    final priority = widget.task['priority'] as String? ?? 'medium';
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'medium':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'low':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Color _getCategoryColor() {
    final category = widget.task['category'] as String? ?? 'general';
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'finance':
        return Colors.orange;
      case 'education':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDueTime() {
    final dueDate = widget.task['dueDate'] as String?;
    if (dueDate == null) return '';

    try {
      final date = DateTime.parse(dueDate);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays}d left';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h left';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m left';
      } else if (difference.inMinutes < 0) {
        return 'Overdue';
      } else {
        return 'Due now';
      }
    } catch (e) {
      return '';
    }
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              icon: 'edit',
              title: 'Edit Task',
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'content_copy',
              title: 'Duplicate',
              onTap: () {
                Navigator.pop(context);
                widget.onDuplicate?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'share',
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                widget.onShare?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'delete',
              title: 'Delete',
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDestructive
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.w),
      ),
    );
  }

  void _handleComplete() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dismissible(
            key: Key(widget.task['id'].toString()),
            direction: DismissDirection.horizontal,
            background: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(3.w),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 6.w),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 32,
              ),
            ),
            secondaryBackground: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error,
                borderRadius: BorderRadius.circular(3.w),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 6.w),
              child: CustomIconWidget(
                iconName: 'delete',
                color: Colors.white,
                size: 32,
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _handleComplete();
                return false;
              } else {
                widget.onDelete?.call();
                return true;
              }
            },
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: _showContextMenu,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.5)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow
                          .withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _handleComplete,
                          child: Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isCompleted
                                    ? AppTheme.lightTheme.colorScheme.tertiary
                                    : AppTheme.lightTheme.colorScheme.outline,
                                width: 2,
                              ),
                              color: _isCompleted
                                  ? AppTheme.lightTheme.colorScheme.tertiary
                                  : Colors.transparent,
                            ),
                            child: _isCompleted
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            widget.task['title'] as String? ?? 'Untitled Task',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  decoration: _isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: _isCompleted
                                      ? AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 1.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      ],
                    ),
                    if (widget.task['description'] != null &&
                        (widget.task['description'] as String).isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        widget.task['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              decoration: _isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            widget.task['category'] as String? ?? 'General',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _getCategoryColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (_formatDueTime().isNotEmpty)
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: _formatDueTime() == 'Overdue'
                                    ? AppTheme.lightTheme.colorScheme.error
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _formatDueTime(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: _formatDueTime() == 'Overdue'
                                          ? AppTheme
                                              .lightTheme.colorScheme.error
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
