import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AiInsightsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> insights;

  const AiInsightsWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Insights IA',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: 'psychology',
                color: colorScheme.secondary,
                size: 6.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...insights.map((insight) => _buildInsightItem(context, insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, Map<String, dynamic> insight) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final IconData iconData = _getInsightIcon(insight['type'] as String);
    final Color iconColor =
        _getInsightColor(insight['type'] as String, colorScheme);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(1.5.w),
            ),
            child: CustomIconWidget(
              iconName: iconData.codePoint.toString(),
              color: iconColor,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  insight['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (insight['action'] != null) ...[
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: () {
                      // Handle insight action
                    },
                    child: Text(
                      insight['action'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'productivity':
        return Icons.trending_up;
      case 'pattern':
        return Icons.pattern;
      case 'suggestion':
        return Icons.lightbulb;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getInsightColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'productivity':
        return colorScheme.primary;
      case 'pattern':
        return colorScheme.secondary;
      case 'suggestion':
        return colorScheme.tertiary;
      case 'warning':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }
}
