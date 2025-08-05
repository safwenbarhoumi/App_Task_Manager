import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProductivityTrendsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trendsData;

  const ProductivityTrendsWidget({
    super.key,
    required this.trendsData,
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
            Text('Tendances de Productivité',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500)),
            CustomIconWidget(
                iconName: 'trending_up', color: colorScheme.primary, size: 6.w),
          ]),
          SizedBox(height: 2.h),
          Expanded(
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                            strokeWidth: 1);
                      }),
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
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < trendsData.length) {
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                          (trendsData[index]['day'] as String)
                                              .substring(0, 3),
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
                              interval: 20,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text('${value.toInt()}%',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.6))));
                              }))),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (trendsData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                        spots: trendsData.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(),
                              (entry.value['productivity'] as double));
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.3),
                        ]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                  radius: 4,
                                  color: colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: colorScheme.surface);
                            }),
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.2),
                                  colorScheme.primary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter))),
                  ],
                  lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final index = barSpot.x.toInt();
                              if (index >= 0 && index < trendsData.length) {
                                return LineTooltipItem(
                                    '${trendsData[index]['day']}\n${barSpot.y.toInt()}% productivité',
                                    theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onInverseSurface,
                                            fontWeight: FontWeight.w500) ??
                                        const TextStyle());
                              }
                              return null;
                            }).toList();
                          }))))),
        ]));
  }
}
