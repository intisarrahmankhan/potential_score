import 'package:flutter/material.dart';
import '../config/theme.dart';

class SleepTrackerCard extends StatelessWidget {
  final double? sleepHours;
  final ValueChanged<double?> onChanged;

  const SleepTrackerCard({
    super.key,
    required this.sleepHours,
    required this.onChanged,
  });

  bool get isPassed => sleepHours != null && sleepHours! >= 7.0 && sleepHours! <= 8.5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String statusText = 'Goal: 7.0 - 8.5 hrs';
    Color badgeColor = Colors.grey;

    if (sleepHours != null) {
      if (isPassed) {
        statusText = 'Optimal Range ($sleepHours hrs)';
        badgeColor = AppTheme.success;
      } else if (sleepHours! < 7.0) {
        statusText = 'Under Target (< 7.0 hrs)';
        badgeColor = AppTheme.warning;
      } else {
        statusText = 'Over Target (> 8.5 hrs)';
        badgeColor = AppTheme.warning;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bedtime_rounded, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep & Recovery',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Optimal window: 7.0 to 8.5 hrs',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                // Pass / Fail Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPassed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        size: 13,
                        color: badgeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Number Input
            TextFormField(
              initialValue: sleepHours?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 7.5',
                suffixText: 'hours',
                prefixIcon: const Icon(Icons.timer_outlined, size: 18),
                helperText: 'Rule: Marked passed ONLY if >= 7.0 and <= 8.5 hours',
                helperStyle: TextStyle(
                  color: isPassed ? AppTheme.success : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val.trim());
                onChanged(parsed);
              },
            ),
          ],
        ),
      ),
    );
  }
}
