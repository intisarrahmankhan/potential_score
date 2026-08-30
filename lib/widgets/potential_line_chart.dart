import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../providers/analytics_provider.dart';

class PotentialLineChart extends StatelessWidget {
  final AnalyticsState state;
  final ValueChanged<MetricFilter> onMetricChanged;
  final ValueChanged<TimeRange> onRangeChanged;

  const PotentialLineChart({
    super.key,
    required this.state,
    required this.onMetricChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spots = state.chartSpots;
    final isOverall = state.selectedMetric == MetricFilter.overall;
    final isSleep = state.selectedMetric == MetricFilter.sleep;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls: Metric Selector Dropdown & Timeframe Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown Filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<MetricFilter>(
                    value: state.selectedMetric,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: MetricFilter.values.map((metric) {
                      return DropdownMenuItem<MetricFilter>(
                        value: metric,
                        child: Text(
                          metric.label,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onMetricChanged(val);
                    },
                  ),
                ),

                // Trajectory Trend Pill
                if (state.isTrendingUp != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: state.isTrendingUp!
                          ? AppTheme.success.withOpacity(0.15)
                          : AppTheme.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isTrendingUp!
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 14,
                          color: state.isTrendingUp! ? AppTheme.success : AppTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.isTrendingUp! ? 'Upward' : 'Downward',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: state.isTrendingUp! ? AppTheme.success : AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Timeframe Pills (7D, 30D, 365D)
            Row(
              children: TimeRange.values.map((range) {
                final isSelected = state.selectedTimeRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onRangeChanged(range),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        range.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // FL_CHART Line Chart
            SizedBox(
              height: 220,
              child: spots.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs recorded in this period.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: isOverall ? 20 : (isSleep ? 2 : 1),
                          getDrawingHorizontalLine: (val) {
                            return FlLine(
                              color: isDark ? Colors.white10 : Colors.black12,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: isOverall ? 20 : (isSleep ? 2 : 2),
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  '${val.toInt()}${state.selectedMetric.unit}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: (spots.length / 5).clamp(1.0, 100.0),
                              getTitlesWidget: (val, meta) {
                                return Text(
                                  state.getDateLabelForIndex(val.toInt()),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: isOverall ? 100 : (isSleep ? 12 : null),
                        // Threshold Guideline Annotations
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            if (isOverall)
                              HorizontalLine(
                                y: 80.0,
                                color: AppTheme.success.withOpacity(0.6),
                                strokeWidth: 1.5,
                                dashArray: [6, 4],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => '80% Streak Target',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isSleep) ...[
                              HorizontalLine(
                                y: 7.0,
                                color: AppTheme.success.withOpacity(0.5),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => '7.0h Min Sleep',
                                  style: const TextStyle(fontSize: 8, color: AppTheme.success),
                                ),
                              ),
                              HorizontalLine(
                                y: 8.5,
                                color: AppTheme.warning.withOpacity(0.5),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => '8.5h Max Sleep',
                                  style: const TextStyle(fontSize: 8, color: AppTheme.warning),
                                ),
                              ),
                            ],
                          ],
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.25,
                            color: AppTheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: spots.length <= 15,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3.5,
                                  color: AppTheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0.3),
                                  AppTheme.primary.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
