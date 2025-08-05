import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TimeAnalysisWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timeData;

  const TimeAnalysisWidget({
    super.key,
    required this.timeData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
        width: double.infinity,
        height: 28.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Analyse du Temps',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500)),
            CustomIconWidget(
                iconName: 'schedule', color: colorScheme.primary, size: 6.w),
          ]),
          SizedBox(height: 2.h),
          Expanded(
              child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= 0 &&
                                groupIndex < timeData.length) {
                              return BarTooltipItem(
                                  '${timeData[groupIndex]['period']}\n${rod.toY.toInt()}h',
                                  theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.w500) ??
                                      const TextStyle());
                            }
                            return null;
                          })),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < timeData.length) {
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                          timeData[index]['period'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withValues(
                                                          alpha: 0.6))));
                                }
                                return const SizedBox.shrink();
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 2,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text('${value.toInt()}h',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.6))));
                              }))),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(colorScheme),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                            strokeWidth: 1);
                      })))),
        ]));
  }

  double _getMaxValue() {
    double max = 0;
    for (final data in timeData) {
      final hours = data['hours'] as double;
      if (hours > max) max = hours;
    }
    return (max + 2).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups(ColorScheme colorScheme) {
    return timeData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: data['hours'] as double,
            gradient: LinearGradient(colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.7),
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            width: 6.w,
            borderRadius: BorderRadius.circular(1.w),
            backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxValue(),
                color: colorScheme.outline.withValues(alpha: 0.1))),
      ]);
    }).toList();
  }
}
