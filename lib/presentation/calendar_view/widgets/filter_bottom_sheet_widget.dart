import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Set<String> selectedCategories;
  final Set<String> selectedPriorities;
  final Function(Set<String>, Set<String>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.selectedCategories,
    required this.selectedPriorities,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Set<String> _selectedCategories;
  late Set<String> _selectedPriorities;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'icon': 'work', 'color': Colors.blue},
    {'name': 'Personal', 'icon': 'person', 'color': Colors.green},
    {'name': 'Health', 'icon': 'favorite', 'color': Colors.red},
    {'name': 'Education', 'icon': 'school', 'color': Colors.orange},
    {
      'name': 'Finance',
      'icon': 'account_balance_wallet',
      'color': Colors.purple
    },
    {'name': 'Shopping', 'icon': 'shopping_cart', 'color': Colors.teal},
    {'name': 'Travel', 'icon': 'flight', 'color': Colors.indigo},
    {'name': 'General', 'icon': 'label', 'color': Colors.grey},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'name': 'High', 'color': Colors.red, 'icon': 'priority_high'},
    {'name': 'Medium', 'color': Colors.orange, 'icon': 'remove'},
    {'name': 'Low', 'color': Colors.green, 'icon': 'keyboard_arrow_down'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.selectedCategories);
    _selectedPriorities = Set.from(widget.selectedPriorities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoriesSection(),
                  SizedBox(height: 3.h),
                  _buildPrioritiesSection(),
                  SizedBox(height: 3.h),
                  _buildQuickFiltersSection(),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filter Tasks',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected = _selectedCategories.contains(category['name']);
            return GestureDetector(
              onTap: () => _toggleCategory(category['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (category['color'] as Color).withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (category['color'] as Color)
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: category['icon'] as String,
                      color: isSelected
                          ? (category['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      category['name'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? (category['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Levels',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: _priorities.map((priority) {
            final isSelected = _selectedPriorities.contains(priority['name']);
            return Expanded(
              child: GestureDetector(
                onTap: () => _togglePriority(priority['name'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 2.w),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (priority['color'] as Color).withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (priority['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: priority['icon'] as String,
                        color: isSelected
                            ? (priority['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 24,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        priority['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? (priority['color'] as Color)
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterButton(
                'Show All',
                'select_all',
                () => _selectAllFilters(),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildQuickFilterButton(
                'Work Only',
                'work',
                () => _selectWorkOnly(),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterButton(
                'High Priority',
                'priority_high',
                () => _selectHighPriorityOnly(),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildQuickFilterButton(
                'Personal',
                'person',
                () => _selectPersonalOnly(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterButton(
      String label, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
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
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _togglePriority(String priority) {
    setState(() {
      if (_selectedPriorities.contains(priority)) {
        _selectedPriorities.remove(priority);
      } else {
        _selectedPriorities.add(priority);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedPriorities.clear();
    });
  }

  void _selectAllFilters() {
    setState(() {
      _selectedCategories = _categories.map((c) => c['name'] as String).toSet();
      _selectedPriorities = _priorities.map((p) => p['name'] as String).toSet();
    });
  }

  void _selectWorkOnly() {
    setState(() {
      _selectedCategories = {'Work'};
      _selectedPriorities = _priorities.map((p) => p['name'] as String).toSet();
    });
  }

  void _selectHighPriorityOnly() {
    setState(() {
      _selectedCategories = _categories.map((c) => c['name'] as String).toSet();
      _selectedPriorities = {'High'};
    });
  }

  void _selectPersonalOnly() {
    setState(() {
      _selectedCategories = {'Personal'};
      _selectedPriorities = _priorities.map((p) => p['name'] as String).toSet();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_selectedCategories, _selectedPriorities);
    Navigator.pop(context);
  }
}
