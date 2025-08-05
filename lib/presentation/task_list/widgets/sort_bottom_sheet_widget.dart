import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SortBottomSheetWidget extends StatefulWidget {
  final String currentSortBy;
  final bool isAscending;
  final Function(String, bool) onSortChanged;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSortBy,
    required this.isAscending,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheetWidget> createState() => _SortBottomSheetWidgetState();
}

class _SortBottomSheetWidgetState extends State<SortBottomSheetWidget> {
  late String _selectedSortBy;
  late bool _isAscending;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'key': 'dueDate',
      'title': 'Due Date',
      'icon': 'schedule',
      'description': 'Sort by task due date',
    },
    {
      'key': 'priority',
      'title': 'Priority',
      'icon': 'priority_high',
      'description': 'Sort by task priority level',
    },
    {
      'key': 'createdDate',
      'title': 'Created Date',
      'icon': 'calendar_today',
      'description': 'Sort by task creation date',
    },
    {
      'key': 'title',
      'title': 'Alphabetical',
      'icon': 'sort_by_alpha',
      'description': 'Sort by task title A-Z',
    },
    {
      'key': 'category',
      'title': 'Category',
      'icon': 'category',
      'description': 'Sort by task category',
    },
    {
      'key': 'custom',
      'title': 'Custom Order',
      'icon': 'drag_handle',
      'description': 'Manual drag and drop order',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _isAscending = widget.isAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: _sortOptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final option = _sortOptions[index];
                return _buildSortOption(context, option);
              },
            ),
          ),
          _buildOrderToggle(context),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort Tasks',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, Map<String, dynamic> option) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedSortBy == option['key'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortBy = option['key'] as String;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: option['icon'] as String,
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                size: 5.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    option['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.primary,
                size: 6.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_selectedSortBy == 'custom') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'swap_vert',
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            size: 6.w,
          ),
          SizedBox(width: 4.w),
          Text(
            'Sort Order',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAscending = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                  decoration: BoxDecoration(
                    color:
                        _isAscending ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'arrow_upward',
                        color: _isAscending
                            ? Colors.white
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Asc',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _isAscending
                              ? Colors.white
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAscending = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                  decoration: BoxDecoration(
                    color: !_isAscending
                        ? colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'arrow_downward',
                        color: !_isAscending
                            ? Colors.white
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Desc',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: !_isAscending
                              ? Colors.white
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortChanged(_selectedSortBy, _isAscending);
                Navigator.pop(context);
              },
              child: const Text('Apply Sort'),
            ),
          ),
        ],
      ),
    );
  }
}
