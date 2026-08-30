import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/scoring_engine.dart';

class LiveScoreHeader extends StatelessWidget {
  final ScoreResult score;
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const LiveScoreHeader({
    super.key,
    required this.score,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFF4F46E5), const Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDateTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateHeader(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
              // Streak Qualification Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: score.isStreakQualified
                      ? AppTheme.success.withOpacity(0.25)
                      : AppTheme.warning.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: score.isStreakQualified ? AppTheme.success : AppTheme.warning,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.isStreakQualified ? '🔥 Streak Qualified' : '🎯 Goal: >= 80%',
                      style: TextStyle(
                        color: score.isStreakQualified
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFFDE68A),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Score Metrics
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY POTENTIAL SCORE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${score.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${score.fraction} criteria met)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: (score.totalCount > 0) ? (score.passedCount / score.totalCount) : 0.0,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  score.isStreakQualified ? AppTheme.success : AppTheme.primaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 1) return 'Yesterday Review (Morning)';
    if (diff == 0) return 'Today Review';
    return '${date.month}/${date.day}/${date.year}';
  }
}
