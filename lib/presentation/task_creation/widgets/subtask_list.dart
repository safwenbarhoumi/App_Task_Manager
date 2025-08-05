import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubtaskList extends StatefulWidget {
  final List<Map<String, dynamic>> subtasks;
  final ValueChanged<List<Map<String, dynamic>>> onSubtasksChanged;

  const SubtaskList({
    super.key,
    required this.subtasks,
    required this.onSubtasksChanged,
  });

  @override
  State<SubtaskList> createState() => _SubtaskListState();
}

class _SubtaskListState extends State<SubtaskList> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;

    final newSubtask = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _subtaskController.text.trim(),
      'isCompleted': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final updatedSubtasks = [...widget.subtasks, newSubtask];
    widget.onSubtasksChanged(updatedSubtasks);
    _subtaskController.clear();
  }

  void _removeSubtask(String id) {
    final updatedSubtasks =
        widget.subtasks.where((s) => s['id'] != id).toList();
    widget.onSubtasksChanged(updatedSubtasks);
  }

  void _toggleSubtask(String id, bool isCompleted) {
    final updatedSubtasks = widget.subtasks.map((subtask) {
      if (subtask['id'] == id) {
        return {...subtask, 'isCompleted': isCompleted};
      }
      return subtask;
    }).toList();
    widget.onSubtasksChanged(updatedSubtasks);
  }

  void _editSubtask(String id, String newTitle) {
    final updatedSubtasks = widget.subtasks.map((subtask) {
      if (subtask['id'] == id) {
        return {...subtask, 'title': newTitle};
      }
      return subtask;
    }).toList();
    widget.onSubtasksChanged(updatedSubtasks);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sous-tâches',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),

        // Add subtask input
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  decoration: InputDecoration(
                    hintText: 'Ajouter une sous-tâche...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              IconButton(
                onPressed: _addSubtask,
                icon: CustomIconWidget(
                  iconName: 'add',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                constraints: BoxConstraints(
                  minWidth: 8.w,
                  minHeight: 8.w,
                ),
              ),
            ],
          ),
        ),

        if (widget.subtasks.isNotEmpty) ...[
          SizedBox(height: 2.h),
          ...widget.subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return _buildSubtaskItem(subtask, index);
          }),
        ],
      ],
    );
  }

  Widget _buildSubtaskItem(Map<String, dynamic> subtask, int index) {
    final isCompleted = subtask['isCompleted'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(subtask['id'], !isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditDialog(subtask),
              child: Text(
                subtask['title'] ?? '',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6)
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeSubtask(subtask['id']),
            icon: CustomIconWidget(
              iconName: 'close',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> subtask) {
    final controller = TextEditingController(text: subtask['title']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifier la sous-tâche',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Titre de la sous-tâche',
          ),
          autofocus: true,
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _editSubtask(subtask['id'], controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
