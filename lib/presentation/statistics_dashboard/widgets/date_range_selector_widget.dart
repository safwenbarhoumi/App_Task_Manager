import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DateRangeSelectorWidget extends StatefulWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  const DateRangeSelectorWidget({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  State<DateRangeSelectorWidget> createState() =>
      _DateRangeSelectorWidgetState();
}

class _DateRangeSelectorWidgetState extends State<DateRangeSelectorWidget> {
  final List<String> _ranges = ['Semaine', 'Mois', 'Trimestre', 'Année'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: _ranges.map((range) {
          final isSelected = range == widget.selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onRangeChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: Text(
                    range,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
