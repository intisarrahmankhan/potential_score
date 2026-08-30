import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/analytics_provider.dart';
import '../providers/daily_log_provider.dart';
import '../widgets/streak_kpi_cards.dart';
import '../widgets/potential_line_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Trajectory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: () => notifier.loadAnalytics(),
          ),
        ],
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.loadAnalytics(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Top 4 KPI Cards
                        StreakKpiCards(analytics: analytics),

                        const SizedBox(height: 16),

                        // 2. Dynamic FL_CHART Graph
                        PotentialLineChart(
                          state: analytics,
                          onMetricChanged: (metric) => notifier.setMetric(metric),
                          onRangeChanged: (range) => notifier.setTimeRange(range),
                        ),

                        const SizedBox(height: 16),

                        // 3. Historical Journal Entries List
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Past Journal Reviews',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${analytics.allLogs.length} Total Logs',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (analytics.allLogs.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: Text(
                                        'No daily reviews recorded yet.',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: analytics.allLogs.take(15).length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final log = analytics.allLogs[index];
                                      final isQualified = log.scorePercentage >= 80.0;

                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                        leading: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isQualified
                                                ? AppTheme.success.withOpacity(0.15)
                                                : AppTheme.warning.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${log.scorePercentage.toInt()}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              color: isQualified ? AppTheme.success : AppTheme.warning,
                                            ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              DateFormat('EEE, MMM d, yyyy').format(log.logDate),
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                            ),
                                            if (isQualified) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 14),
                                            ],
                                          ],
                                        ),
                                        subtitle: log.reflectionNotes.isNotEmpty
                                            ? Text(
                                                '"${log.reflectionNotes}"',
                                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Text(
                                                'Score: ${log.scoreFraction} • Sleep: ${log.sleepHours}h • Focus: ${log.totalProductiveHours}h',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          onPressed: () {
                                            ref.read(dailyEntryProvider.notifier).setDate(log.logDate);
                                            DefaultTabController.of(context).animateTo(0);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
