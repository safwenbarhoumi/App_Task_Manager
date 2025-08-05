import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  static const List<Map<String, dynamic>> priorities = [
    {
      'value': 'low',
      'label': 'Faible',
      'color': Color(0xFF10B981),
      'icon': 'keyboard_arrow_down',
    },
    {
      'value': 'medium',
      'label': 'Moyenne',
      'color': Color(0xFFF59E0B),
      'icon': 'remove',
    },
    {
      'value': 'high',
      'label': 'Élevée',
      'color': Color(0xFFEF4444),
      'icon': 'keyboard_arrow_up',
    },
    {
      'value': 'urgent',
      'label': 'Urgent',
      'color': Color(0xFFDC2626),
      'icon': 'priority_high',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priorité',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 6.h,
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
            children: priorities.map((priority) {
              final isSelected = selectedPriority == priority['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPriorityChanged(priority['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? priority['color'] : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: priority['icon'],
                            size: 16,
                            color:
                                isSelected ? Colors.white : priority['color'],
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            priority['label'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : priority['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
