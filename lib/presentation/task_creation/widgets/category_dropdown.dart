import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<Map<String, dynamic>> categories = [
    {
      'value': 'work',
      'label': 'Travail',
      'icon': 'work_outline',
      'color': Color(0xFF2563EB),
    },
    {
      'value': 'personal',
      'label': 'Personnel',
      'icon': 'person_outline',
      'color': Color(0xFF7C3AED),
    },
    {
      'value': 'health',
      'label': 'Santé',
      'icon': 'favorite_outline',
      'color': Color(0xFF059669),
    },
    {
      'value': 'finance',
      'label': 'Finance',
      'icon': 'account_balance_wallet_outlined',
      'color': Color(0xFFF59E0B),
    },
    {
      'value': 'education',
      'label': 'Éducation',
      'icon': 'school_outlined',
      'color': Color(0xFF8B5CF6),
    },
    {
      'value': 'shopping',
      'label': 'Achats',
      'icon': 'shopping_cart_outlined',
      'color': Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              hint: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'category_outlined',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Sélectionner une catégorie',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['value'],
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: category['icon'],
                        size: 20,
                        color: category['color'],
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        category['label'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onCategoryChanged,
              dropdownColor: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 40.h,
            ),
          ),
        ),
      ],
    );
  }
}
