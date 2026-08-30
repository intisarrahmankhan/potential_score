import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../services/scoring_engine.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

enum MetricFilter {
  overall('Overall Potential (%)', '%'),
  sleep('Sleep Duration (Hours)', 'hrs'),
  study('Study Time (Hours)', 'hrs'),
  work('Work Time (Hours)', 'hrs'),
  learn('Learn Time (Hours)', 'hrs');

  final String label;
  final String unit;
  const MetricFilter(this.label, this.unit);
}

enum TimeRange {
  sevenDays('7 Days', 7),
  thirtyDays('30 Days', 30),
  year('365 Days', 365);

  final String label;
  final int days;
  const TimeRange(this.label, this.days);
}

class AnalyticsState {
  final List<DailyLog> allLogs;
  final bool isLoading;
  final MetricFilter selectedMetric;
  final TimeRange selectedTimeRange;
  final int currentStreak;
  final int longestStreak;
  final int totalStreakDays;
  final double avg30Score;

  const AnalyticsState({
    this.allLogs = const [],
    this.isLoading = false,
    this.selectedMetric = MetricFilter.overall,
    this.selectedTimeRange = TimeRange.thirtyDays,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStreakDays = 0,
    this.avg30Score = 0.0,
  });

  List<DailyLog> get filteredLogs {
    final cutoff = DateTime.now().subtract(Duration(days: selectedTimeRange.days));
    return allLogs.where((l) => l.logDate.isAfter(cutoff)).toList()
      ..sort((a, b) => a.logDate.compareTo(b.logDate));
  }

  List<FlSpot> get chartSpots {
    final logs = filteredLogs;
    if (logs.isEmpty) return [];

    final spots = <FlSpot>[];
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      double val = 0.0;

      switch (selectedMetric) {
        case MetricFilter.overall:
          val = log.scorePercentage;
          break;
        case MetricFilter.sleep:
          val = log.sleepHours;
          break;
        case MetricFilter.study:
          val = log.studyHours;
          break;
        case MetricFilter.work:
          val = log.workHours;
          break;
        case MetricFilter.learn:
          val = log.learnHours;
          break;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  String getDateLabelForIndex(int index) {
    final logs = filteredLogs;
    if (index >= 0 && index < logs.length) {
      return DateFormat('MMM d').format(logs[index].logDate);
    }
    return '';
  }

  /// Calculates whether trajectory is trending upward or downward
  bool? get isTrendingUp {
    final spots = chartSpots;
    if (spots.length < 2) return null;
    final firstHalf = spots.take(spots.length ~/ 2).map((e) => e.y);
    final secondHalf = spots.skip(spots.length ~/ 2).map((e) => e.y);

    final avg1 = firstHalf.isNotEmpty ? firstHalf.reduce((a, b) => a + b) / firstHalf.length : 0;
    final avg2 = secondHalf.isNotEmpty ? secondHalf.reduce((a, b) => a + b) / secondHalf.length : 0;
    return avg2 >= avg1;
  }

  AnalyticsState copyWith({
    List<DailyLog>? allLogs,
    bool? isLoading,
    MetricFilter? selectedMetric,
    TimeRange? selectedTimeRange,
    int? currentStreak,
    int? longestStreak,
    int? totalStreakDays,
    double? avg30Score,
  }) {
    return AnalyticsState(
      allLogs: allLogs ?? this.allLogs,
      isLoading: isLoading ?? this.isLoading,
      selectedMetric: selectedMetric ?? this.selectedMetric,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStreakDays: totalStreakDays ?? this.totalStreakDays,
      avg30Score: avg30Score ?? this.avg30Score,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final SupabaseService _service;

  AnalyticsNotifier(this._service) : super(const AnalyticsState()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    try {
      final logs = await _service.fetchAllDailyLogs(limit: 365);
      final streaks = ScoringEngine.calculateStreaks(logs);

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recent30 = logs.where((l) => l.logDate.isAfter(thirtyDaysAgo)).toList();
      final avg30 = recent30.isNotEmpty
          ? recent30.map((e) => e.scorePercentage).reduce((a, b) => a + b) / recent30.length
          : 0.0;

      state = state.copyWith(
        allLogs: logs,
        isLoading: false,
        currentStreak: streaks.currentStreak,
        longestStreak: streaks.longestStreak,
        totalStreakDays: streaks.totalStreakDays,
        avg30Score: double.parse(avg30.toStringAsFixed(1)),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setMetric(MetricFilter metric) {
    state = state.copyWith(selectedMetric: metric);
  }

  void setTimeRange(TimeRange range) {
    state = state.copyWith(selectedTimeRange: range);
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AnalyticsNotifier(service);
});
