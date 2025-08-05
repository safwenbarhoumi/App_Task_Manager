import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? imagePath;
  final bool isSearchResult;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.imagePath,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context),
            SizedBox(height: 4.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                  ),
                  child: Text(buttonText!),
                ),
              ),
            ],
            if (isSearchResult) ...[
              SizedBox(height: 3.h),
              _buildSearchSuggestions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imagePath != null) {
      return CustomImageWidget(
        imageUrl: imagePath!,
        width: 60.w,
        height: 30.h,
        fit: BoxFit.contain,
      );
    }

    // Default illustration based on context
    return Container(
      width: 60.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _getIconName(),
              color: colorScheme.primary,
              size: 12.w,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: 30.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 20.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final suggestions = [
      'Try different keywords',
      'Check your spelling',
      'Use more general terms',
      'Clear filters and try again',
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb_outline',
                color: colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Search Tips',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  Container(
                    width: 1.w,
                    height: 1.w,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getIconName() {
    if (isSearchResult) {
      return 'search_off';
    }

    if (title.toLowerCase().contains('task')) {
      return 'assignment';
    } else if (title.toLowerCase().contains('filter')) {
      return 'filter_list_off';
    } else if (title.toLowerCase().contains('complete')) {
      return 'check_circle_outline';
    }

    return 'inbox';
  }
}

// Predefined empty states for common scenarios
class TaskEmptyStates {
  static Widget noTasks(VoidCallback onCreateTask) {
    return EmptyStateWidget(
      title: 'No Tasks Yet',
      description:
          'Start organizing your work by creating your first task. Tap the button below to get started.',
      buttonText: 'Create First Task',
      onButtonPressed: onCreateTask,
      imagePath:
          'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=300&fit=crop',
    );
  }

  static Widget noSearchResults(String query) {
    return EmptyStateWidget(
      title: 'No Results Found',
      description:
          'We couldn\'t find any tasks matching "$query". Try adjusting your search terms or filters.',
      isSearchResult: true,
      imagePath:
          'https://images.unsplash.com/photo-1584824486509-112e4181ff6b?w=400&h=300&fit=crop',
    );
  }

  static Widget noFilteredTasks(VoidCallback onClearFilters) {
    return EmptyStateWidget(
      title: 'No Matching Tasks',
      description:
          'No tasks match your current filters. Try adjusting your filter criteria or clear all filters.',
      buttonText: 'Clear Filters',
      onButtonPressed: onClearFilters,
      imagePath:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
    );
  }

  static Widget allTasksCompleted(VoidCallback onCreateTask) {
    return EmptyStateWidget(
      title: 'All Done! 🎉',
      description:
          'Congratulations! You\'ve completed all your tasks. Ready to tackle something new?',
      buttonText: 'Add New Task',
      onButtonPressed: onCreateTask,
      imagePath:
          'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop',
    );
  }

  static Widget offlineMode() {
    return const EmptyStateWidget(
      title: 'You\'re Offline',
      description:
          'Some features may be limited while offline. Your changes will sync when you\'re back online.',
      imagePath:
          'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=400&h=300&fit=crop',
    );
  }
}
