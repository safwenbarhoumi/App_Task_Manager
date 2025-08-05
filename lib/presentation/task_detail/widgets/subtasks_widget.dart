import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubtasksWidget extends StatefulWidget {
  final List<Map<String, dynamic>> subtasks;
  final bool isEditMode;
  final Function(Map<String, dynamic>)? onSubtaskAdded;
  final Function(int, bool)? onSubtaskToggled;
  final Function(int)? onSubtaskRemoved;

  const SubtasksWidget({
    super.key,
    required this.subtasks,
    this.isEditMode = false,
    this.onSubtaskAdded,
    this.onSubtaskToggled,
    this.onSubtaskRemoved,
  });

  @override
  State<SubtasksWidget> createState() => _SubtasksWidgetState();
}

class _SubtasksWidgetState extends State<SubtasksWidget> {
  final TextEditingController _newSubtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subtasks.isEmpty && !widget.isEditMode) {
      return const SizedBox.shrink();
    }

    final completedCount =
        widget.subtasks.where((task) => task['isCompleted'] == true).length;
    final totalCount = widget.subtasks.length;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'checklist',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sous-tâches',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 2.w),
              if (totalCount > 0)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              if (widget.isEditMode)
                GestureDetector(
                  onTap: _toggleAddSubtask,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _isAddingSubtask ? 'close' : 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          if (totalCount > 0) _buildProgressBar(completedCount, totalCount),
          if (totalCount > 0) SizedBox(height: 2.h),
          if (_isAddingSubtask) _buildAddSubtaskField(),
          if (_isAddingSubtask) SizedBox(height: 2.h),
          if (widget.subtasks.isNotEmpty)
            _buildSubtasksList()
          else if (!widget.isEditMode)
            Text(
              'Aucune sous-tâche',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 0.8.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSubtaskField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newSubtaskController,
              decoration: const InputDecoration(
                hintText: 'Nouvelle sous-tâche...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              onSubmitted: (_) => _addSubtask(),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: _addSubtask,
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.subtasks.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final subtask = widget.subtasks[index];
        return _buildSubtaskItem(subtask, index);
      },
    );
  }

  Widget _buildSubtaskItem(Map<String, dynamic> subtask, int index) {
    final bool isCompleted = subtask['isCompleted'] ?? false;
    final String title = subtask['title'] ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.lightTheme.colorScheme.tertiaryContainer
                .withValues(alpha: 0.5)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onSubtaskToggled?.call(index, !isCompleted),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isCompleted
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6)
                    : AppTheme.lightTheme.colorScheme.onSurface,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (widget.isEditMode) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () => widget.onSubtaskRemoved?.call(index),
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleAddSubtask() {
    setState(() {
      _isAddingSubtask = !_isAddingSubtask;
      if (!_isAddingSubtask) {
        _newSubtaskController.clear();
      }
    });
  }

  void _addSubtask() {
    final title = _newSubtaskController.text.trim();
    if (title.isNotEmpty) {
      final subtask = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
      };
      widget.onSubtaskAdded?.call(subtask);
      _newSubtaskController.clear();
      setState(() {
        _isAddingSubtask = false;
      });
    }
  }
}
