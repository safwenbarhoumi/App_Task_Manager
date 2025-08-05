import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskInfoWidget extends StatefulWidget {
  final String title;
  final String description;
  final DateTime? dueDate;
  final String priority;
  final String category;
  final List<String> tags;
  final bool isCompleted;
  final bool isEditMode;
  final Function(String)? onTitleChanged;
  final Function(String)? onDescriptionChanged;
  final Function(DateTime?)? onDueDateChanged;
  final Function(String)? onPriorityChanged;
  final Function(bool)? onCompletionChanged;

  const TaskInfoWidget({
    super.key,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    required this.category,
    required this.tags,
    required this.isCompleted,
    this.isEditMode = false,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onDueDateChanged,
    this.onPriorityChanged,
    this.onCompletionChanged,
  });

  @override
  State<TaskInfoWidget> createState() => _TaskInfoWidgetState();
}

class _TaskInfoWidgetState extends State<TaskInfoWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(),
          SizedBox(height: 3.h),
          _buildDescriptionSection(),
          SizedBox(height: 3.h),
          _buildTaskMetadata(),
          SizedBox(height: 3.h),
          _buildCompletionToggle(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return widget.isEditMode
        ? TextField(
            controller: _titleController,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Titre de la tâche',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: widget.onTitleChanged,
          )
        : Text(
            widget.title,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              decoration:
                  widget.isCompleted ? TextDecoration.lineThrough : null,
            ),
          );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'description',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Description',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (!widget.isEditMode && widget.description.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: CustomIconWidget(
                  iconName:
                      _isDescriptionExpanded ? 'expand_less' : 'expand_more',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        widget.isEditMode
            ? TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ajouter une description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: widget.onDescriptionChanged,
              )
            : Text(
                widget.description.isEmpty
                    ? 'Aucune description'
                    : widget.description,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: widget.description.isEmpty
                      ? AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6)
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: _isDescriptionExpanded ? null : 3,
                overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
              ),
      ],
    );
  }

  Widget _buildTaskMetadata() {
    return Column(
      children: [
        _buildMetadataRow(
          icon: 'schedule',
          label: 'Échéance',
          value: widget.dueDate != null
              ? '${widget.dueDate!.day}/${widget.dueDate!.month}/${widget.dueDate!.year}'
              : 'Aucune échéance',
          onTap: widget.isEditMode ? _selectDueDate : null,
        ),
        SizedBox(height: 2.h),
        _buildMetadataRow(
          icon: 'flag',
          label: 'Priorité',
          value: _getPriorityText(widget.priority),
          valueColor: _getPriorityColor(widget.priority),
          onTap: widget.isEditMode ? _selectPriority : null,
        ),
        SizedBox(height: 2.h),
        _buildMetadataRow(
          icon: 'category',
          label: 'Catégorie',
          value: widget.category,
        ),
        if (widget.tags.isNotEmpty) ...[
          SizedBox(height: 2.h),
          _buildTagsSection(),
        ],
      ],
    );
  }

  Widget _buildMetadataRow({
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: valueColor ??
                    AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'local_offer',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Tags',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: widget.tags
              .map((tag) => Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCompletionToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: widget.isCompleted
            ? AppTheme.lightTheme.colorScheme.tertiaryContainer
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isCompleted
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onCompletionChanged?.call(!widget.isCompleted),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.isCompleted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: widget.isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            widget.isCompleted ? 'Tâche terminée' : 'Marquer comme terminée',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.isCompleted
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Élevée';
      case 'medium':
        return 'Moyenne';
      case 'low':
        return 'Faible';
      default:
        return 'Non définie';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      widget.onDueDateChanged?.call(picked);
    }
  }

  Future<void> _selectPriority() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner la priorité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['high', 'medium', 'low'].map((priority) {
              return ListTile(
                title: Text(_getPriorityText(priority)),
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(priority),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      widget.onPriorityChanged?.call(selected);
    }
  }
}
