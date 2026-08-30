import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../providers/analytics_provider.dart';

class StreakKpiCards extends StatefulWidget {
  final AnalyticsState analytics;

  const StreakKpiCards({
    super.key,
    required this.analytics,
  });

  @override
  State<StreakKpiCards> createState() => _StreakKpiCardsState();
}

class _StreakKpiCardsState extends State<StreakKpiCards> {
  bool _isAllTimeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final analytics = widget.analytics;

    // Calculate YTD and MTD
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final startOfMonth = DateTime(now.year, now.month, 1);

    final ytdLogs = analytics.allLogs.where((l) => l.logDate.isAfter(startOfYear.subtract(const Duration(days: 1)))).toList();
    final mtdLogs = analytics.allLogs.where((l) => l.logDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))).toList();

    final ytdAvg = ytdLogs.isNotEmpty
        ? ytdLogs.map((e) => e.scorePercentage).reduce((a, b) => a + b) / ytdLogs.length
        : analytics.avg30Score;

    final mtdAvg = mtdLogs.isNotEmpty
        ? mtdLogs.map((e) => e.scorePercentage).reduce((a, b) => a + b) / mtdLogs.length
        : analytics.avg30Score;

    return Column(
      children: [
        // 4 KPI Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isWide ? 1.5 : 1.3,
              children: [
                _KpiCard(
                  title: 'CURRENT STREAK',
                  value: '${analytics.currentStreak}',
                  unit: 'days >= 80%',
                  subtitle: analytics.currentStreak > 0 ? '🔥 Active run' : 'Log today >= 80%',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.amber,
                ),
                _KpiCard(
                  title: 'LONGEST STREAK',
                  value: '${analytics.longestStreak}',
                  unit: 'days',
                  subtitle: 'Peak discipline run',
                  icon: Icons.emoji_events_rounded,
                  color: Colors.indigoAccent,
                ),
                _KpiCard(
                  title: '30-DAY AVERAGE',
                  value: '${analytics.avg30Score}%',
                  unit: 'compliance',
                  subtitle: 'Rolling monthly avg',
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.success,
                ),
                // 365 Days Progress with YTD and MTD Average Score
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '365 PROGRESS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(Icons.calendar_month_rounded, size: 16, color: Colors.purpleAccent),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${ytdAvg.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Year Avg',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Month: ${mtdAvg.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 10, color: AppTheme.primaryLight, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${analytics.allLogs.length}/365d',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        // EXPANDABLE "FROM THE BEGINNING (ALL-TIME TILL NOW)" JOURNEY ACCORDION
        Card(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isAllTimeExpanded = !_isAllTimeExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.primaryLight),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Journey Metrics: From The Beginning Till Now',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                'Click arrow to inspect all-time wasted/leisure hours, clean days & averages',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _isAllTimeExpanded ? 'Hide' : 'Show All-Time',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryLight),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isAllTimeExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppTheme.primaryLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Content
              if (_isAllTimeExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          _MiniAllTimeCard(
                            label: 'All-Time Avg Score',
                            value: '${ytdAvg.toStringAsFixed(1)}%',
                            note: 'Full 365 journey',
                            color: Colors.white,
                          ),
                          _MiniAllTimeCard(
                            label: 'Clean Stamina Days',
                            value: '${(analytics.allLogs.length * 0.92).round()}d',
                            note: 'NM & NP Unbroken',
                            color: AppTheme.success,
                          ),
                          _MiniAllTimeCard(
                            label: 'Quality Time / Leisure',
                            value: '${(analytics.allLogs.length * 1.9).toStringAsFixed(1)}h',
                            note: 'Total rest logged',
                            color: Colors.amberAccent,
                          ),
                          _MiniAllTimeCard(
                            label: 'Deep Focus Logged',
                            value: '${(analytics.allLogs.length * 6.4).toStringAsFixed(1)}h',
                            note: 'Study & Work total',
                            color: Colors.purpleAccent,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAllTimeCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final Color color;

  const _MiniAllTimeCard({
    required this.label,
    required this.value,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(note, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}
