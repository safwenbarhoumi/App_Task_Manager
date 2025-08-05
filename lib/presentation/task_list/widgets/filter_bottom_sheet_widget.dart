import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusFilter(context),
                  SizedBox(height: 3.h),
                  _buildPriorityFilter(context),
                  SizedBox(height: 3.h),
                  _buildCategoryFilter(context),
                  SizedBox(height: 3.h),
                  _buildDateFilter(context),
                  SizedBox(height: 3.h),
                  _buildAssignedUserFilter(context),
                ],
              ),
            ),
          ),
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
            'Filter Tasks',
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

  Widget _buildStatusFilter(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = ['all', 'pending', 'completed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: statuses.map((status) {
            final isSelected = _filters['status'] == status;
            return FilterChip(
              label: Text(status.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['status'] = selected ? status : 'all';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter(BuildContext context) {
    final theme = Theme.of(context);
    final priorities = ['high', 'medium', 'low'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: priorities.map((priority) {
            final selectedPriorities =
                _filters['priorities'] as List<String>? ?? [];
            final isSelected = selectedPriorities.contains(priority);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(priority.toUpperCase()),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final priorities =
                      List<String>.from(_filters['priorities'] ?? []);
                  if (selected) {
                    priorities.add(priority);
                  } else {
                    priorities.remove(priority);
                  }
                  _filters['priorities'] = priorities;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['Work', 'Personal', 'Shopping', 'Health', 'Education'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: categories.map((category) {
            final selectedCategories =
                _filters['categories'] as List<String>? ?? [];
            final isSelected = selectedCategories.contains(category);

            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final categories =
                      List<String>.from(_filters['categories'] ?? []);
                  if (selected) {
                    categories.add(category);
                  } else {
                    categories.remove(category);
                  }
                  _filters['categories'] = categories;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final theme = Theme.of(context);
    final dateFilters = ['today', 'tomorrow', 'this_week', 'overdue'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: dateFilters.map((dateFilter) {
            final isSelected = _filters['dateFilter'] == dateFilter;
            String label;
            switch (dateFilter) {
              case 'today':
                label = 'Today';
                break;
              case 'tomorrow':
                label = 'Tomorrow';
                break;
              case 'this_week':
                label = 'This Week';
                break;
              case 'overdue':
                label = 'Overdue';
                break;
              default:
                label = dateFilter;
            }

            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['dateFilter'] = selected ? dateFilter : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAssignedUserFilter(BuildContext context) {
    final theme = Theme.of(context);
    final users = ['Me', 'John Doe', 'Jane Smith', 'Mike Johnson'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned To',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: users.map((user) {
            final selectedUsers =
                _filters['assignedUsers'] as List<String>? ?? [];
            final isSelected = selectedUsers.contains(user);

            return FilterChip(
              label: Text(user),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final users =
                      List<String>.from(_filters['assignedUsers'] ?? []);
                  if (selected) {
                    users.add(user);
                  } else {
                    users.remove(user);
                  }
                  _filters['assignedUsers'] = users;
                });
              },
            );
          }).toList(),
        ),
      ],
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
              onPressed: () {
                setState(() {
                  _filters = {
                    'status': 'all',
                    'priorities': <String>[],
                    'categories': <String>[],
                    'dateFilter': null,
                    'assignedUsers': <String>[],
                  };
                });
              },
              child: const Text('Clear All'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
