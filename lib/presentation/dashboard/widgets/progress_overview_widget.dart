import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProgressOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> progressData;
  final VoidCallback? onViewDetails;

  const ProgressOverviewWidget({
    super.key,
    required this.progressData,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = progressData['completedTasks'] as int? ?? 0;
    final totalTasks = progressData['totalTasks'] as int? ?? 0;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
    final weeklyData =
        progressData['weeklyData'] as List<Map<String, dynamic>>? ?? [];

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24),
            SizedBox(width: 3.w),
            Expanded(
                child: Text('Progress Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600))),
            TextButton(
                onPressed: onViewDetails,
                child: Text('View Details',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500))),
          ]),
          SizedBox(height: 3.h),
          Row(children: [
            Expanded(
                child: _buildStatCard(
                    context,
                    'Completed',
                    completedTasks.toString(),
                    AppTheme.lightTheme.colorScheme.tertiary,
                    'check_circle')),
            SizedBox(width: 3.w),
            Expanded(
                child: _buildStatCard(
                    context,
                    'Remaining',
                    (totalTasks - completedTasks).toString(),
                    AppTheme.lightTheme.colorScheme.secondary,
                    'pending')),
            SizedBox(width: 3.w),
            Expanded(
                child: _buildStatCard(
                    context,
                    'Success Rate',
                    '${(completionRate * 100).round()}%',
                    AppTheme.lightTheme.colorScheme.primary,
                    'trending_up')),
          ]),
          SizedBox(height: 4.h),
          Text('Weekly Progress',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          SizedBox(
              height: 20.h,
              child: weeklyData.isNotEmpty
                  ? _buildWeeklyChart(weeklyData)
                  : _buildEmptyChart(context)),
        ]));
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      Color color, String iconName) {
    return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1)),
        child: Column(children: [
          CustomIconWidget(iconName: iconName, color: color, size: 24),
          SizedBox(height: 1.h),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7)),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> data) {
    return Semantics(
        label: "Weekly Progress Chart",
        child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: data
                    .map((e) => (e['completed'] as num).toDouble())
                    .reduce((a, b) => a > b ? a : b) +
                2,
            barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                    tooltipBorder: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2)),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                          '${data[group.x]['day']}\n${rod.toY.round()} tasks',
                          const TextStyle());
                    })),
            titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length) {
                            return Text(data[value.toInt()]['day'] as String,
                                style: const TextStyle());
                          }
                          return const Text('');
                        },
                        reservedSize: 30)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return BarChartGroupData(x: index, barRods: [
                BarChartRodData(
                    toY: (item['completed'] as num).toDouble(),
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 4.w,
                    borderRadius: BorderRadius.circular(1.w)),
              ]);
            }).toList(),
            gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                      strokeWidth: 1);
                }))));
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1)),
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomIconWidget(
              iconName: 'bar_chart',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 32),
          SizedBox(height: 2.h),
          Text('No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6))),
          Text('Complete some tasks to see your progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5)),
              textAlign: TextAlign.center),
        ])));
  }
}
