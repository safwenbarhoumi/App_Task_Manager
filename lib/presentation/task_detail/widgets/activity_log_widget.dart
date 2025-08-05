import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityLogWidget extends StatefulWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityLogWidget({
    super.key,
    required this.activities,
  });

  @override
  State<ActivityLogWidget> createState() => _ActivityLogWidgetState();
}

class _ActivityLogWidgetState extends State<ActivityLogWidget> {
  bool _isExpanded = false;
  final int _maxVisibleItems = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleActivities = _isExpanded
        ? widget.activities
        : widget.activities.take(_maxVisibleItems).toList();

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Historique d\'activité',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.activities.length > _maxVisibleItems)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Réduire' : 'Voir tout',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: _isExpanded ? 'expand_less' : 'expand_more',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleActivities.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              final activity = visibleActivities[index];
              return _buildActivityItem(activity, index == 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isLatest) {
    final String action = activity['action'] ?? '';
    final String user = activity['user'] ?? 'Utilisateur';
    final String timestamp = activity['timestamp'] ?? '';
    final String? details = activity['details'];
    final String type = activity['type'] ?? 'general';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isLatest
            ? AppTheme.lightTheme.colorScheme.primaryContainer
                .withValues(alpha: 0.3)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: _getActivityColor(type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getActivityIcon(type),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: user,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' $action'),
                    ],
                  ),
                ),
                if (details != null && details.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    details,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                SizedBox(height: 1.h),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityIcon(String type) {
    switch (type) {
      case 'created':
        return 'add_circle';
      case 'updated':
        return 'edit';
      case 'completed':
        return 'check_circle';
      case 'commented':
        return 'comment';
      case 'attachment':
        return 'attach_file';
      case 'priority':
        return 'flag';
      case 'due_date':
        return 'schedule';
      case 'assigned':
        return 'person_add';
      default:
        return 'info';
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'created':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'updated':
        return AppTheme.warningLight;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'commented':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'attachment':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'priority':
        return AppTheme.lightTheme.colorScheme.error;
      case 'due_date':
        return AppTheme.warningLight;
      case 'assigned':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
