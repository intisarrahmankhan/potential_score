import '../models/habit.dart';
import '../models/daily_log.dart';

class ScoreResult {
  final int passedCount;
  final int totalCount;
  final double percentage;
  final String fraction;
  final bool isStreakQualified;
  final bool isEliteQualified;
  final bool isNMPassed;
  final bool isNPPassed;
  final bool isSleepPassed;
  final bool isLeisureSafe;

  const ScoreResult({
    required this.passedCount,
    required this.totalCount,
    required this.percentage,
    required this.fraction,
    required this.isStreakQualified,
    this.isEliteQualified = false,
    this.isNMPassed = false,
    this.isNPPassed = false,
    this.isSleepPassed = true,
    this.isLeisureSafe = true,
  });
}

class ScoringEngine {
  /// Optimal sleep window rule: Passed ONLY if targetMin <= sleepHours <= targetMax (default 7.0 - 8.5)
  static bool evaluateSleep(double? sleepHours, {double min = 7.0, double max = 8.5}) {
    if (sleepHours == null) return false;
    return sleepHours >= min && sleepHours <= max;
  }

  /// Evaluates study focus goal
  static bool evaluateStudy(double? studyHours, {double target = 2.0}) {
    if (studyHours == null) return false;
    return studyHours >= target;
  }

  /// Evaluates work focus goal
  static bool evaluateWork(double? workHours, {double target = 4.0}) {
    if (workHours == null) return false;
    return workHours >= target;
  }

  /// Evaluates leisure / wasted time limit (<= 3.0h safe, > 3.0h penalty)
  static bool evaluateLeisure(int hours, int minutes, {double maxLimit = 3.0}) {
    final double total = hours + (minutes / 60.0);
    return total <= maxLimit;
  }

  /// Calculates total score with NM, NP, Sleep, and Leisure penalties
  static ScoreResult calculateDailyScore({
    required List<Habit> activeHabits,
    required Map<String, bool> booleanValues,
    required Map<String, double?> numericValues,
    bool isNMPassed = false, // Unticked by default
    bool isNPPassed = false, // Unticked by default
    double? sleepHours,
    double sleepMin = 7.0,
    double sleepMax = 8.5,
    double? studyHours,
    double studyTarget = 2.0,
    double? workHours,
    double workTarget = 4.0,
    int leisureHours = 1,
    int leisureMinutes = 30,
  }) {
    final isSleepOptimal = evaluateSleep(sleepHours, min: sleepMin, max: sleepMax);
    final isStudyMet = evaluateStudy(studyHours, target: studyTarget);
    final isWorkMet = evaluateWork(workHours, target: workTarget);
    final isLeisureSafe = evaluateLeisure(leisureHours, leisureMinutes, maxLimit: 3.0);

    int baseHabitsCount = 3 + activeHabits.length; // Sleep + Study + Work + Dynamic Habits
    int basePassedCount = (isSleepOptimal ? 1 : 0) + (isStudyMet ? 1 : 0) + (isWorkMet ? 1 : 0);

    for (final habit in activeHabits) {
      final boolVal = booleanValues[habit.id];
      final numVal = numericValues[habit.id];
      if (habit.evaluate(booleanValue: boolVal, numericValue: numVal)) {
        basePassedCount++;
      }
    }

    final int totalCriteriaCount = 2 + baseHabitsCount; // NM + NP + Base Items
    final int passedCriteriaCount = (isNMPassed ? 1 : 0) + (isNPPassed ? 1 : 0) + basePassedCount;

    // Base percentage
    double rawScore = baseHabitsCount > 0 ? (basePassedCount / baseHabitsCount) * 100.0 : 0.0;

    // Direct penalty deductions
    if (!isNMPassed) {
      rawScore -= 25.0; // Heavy stamina drop penalty
    }
    if (!isNPPassed) {
      rawScore -= 15.0; // Moderate dopamine clarity penalty
    }
    if (!isSleepOptimal) {
      rawScore -= 10.0; // Sleep disruption penalty
    }
    if (!isLeisureSafe) {
      rawScore -= 10.0; // Excess leisure penalty (> 3h)
    }

    if (isNMPassed && isNPPassed && isSleepOptimal && isLeisureSafe) {
      rawScore = (passedCriteriaCount / totalCriteriaCount) * 100.0;
    }

    final double finalPct = rawScore.clamp(0.0, 100.0);
    final bool isStreakQualified = finalPct >= 80.0;
    final bool isEliteQualified = finalPct >= 90.0;

    return ScoreResult(
      passedCount: passedCriteriaCount,
      totalCount: totalCriteriaCount,
      percentage: double.parse(finalPct.toStringAsFixed(1)),
      fraction: '$passedCriteriaCount/$totalCriteriaCount',
      isStreakQualified: isStreakQualified,
      isEliteQualified: isEliteQualified,
      isNMPassed: isNMPassed,
      isNPPassed: isNPPassed,
      isSleepPassed: isSleepOptimal,
      isLeisureSafe: isLeisureSafe,
    );
  }

  /// Calculates current and longest streaks from historical daily logs
  static ({int currentStreak, int longestStreak, int totalStreakDays}) calculateStreaks(
    List<DailyLog> logs,
  ) {
    if (logs.isEmpty) {
      return (currentStreak: 0, longestStreak: 0, totalStreakDays: 0);
    }

    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    final Map<String, bool> qualifiedMap = {};
    for (final log in sortedLogs) {
      final key = "${log.logDate.year}-${log.logDate.month.toString().padLeft(2, '0')}-${log.logDate.day.toString().padLeft(2, '0')}";
      qualifiedMap[key] = log.scorePercentage >= 80.0;
    }

    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final log in sortedLogs) {
      final isQualified = log.scorePercentage >= 80.0;
      if (isQualified) {
        if (prevDate != null && log.logDate.difference(prevDate).inDays == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
      prevDate = log.logDate;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String todayKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    String yesterdayKey = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

    DateTime? anchorDate;
    if (qualifiedMap[todayKey] == true) {
      anchorDate = today;
    } else if (qualifiedMap[yesterdayKey] == true) {
      anchorDate = yesterday;
    }

    int currentStreak = 0;
    if (anchorDate != null) {
      DateTime checkDate = anchorDate;
      while (true) {
        String key = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
        if (qualifiedMap[key] == true) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    final int totalStreakDays = qualifiedMap.values.where((v) => v).length;

    return (
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalStreakDays: totalStreakDays,
    );
  }
}
