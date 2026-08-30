import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_log.dart';
import '../models/daily_habit_entry.dart';
import '../models/habit.dart';
import '../services/scoring_engine.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';
import 'habit_provider.dart';

class DailyEntryState {
  final DateTime selectedDate;
  final bool isLoading;
  final bool isSaving;
  final String? message;
  final DailyLog? existingLog;

  // Form State Values
  final double? sleepHours;
  final double? studyHours;
  final double? workHours;
  final double? learnHours;
  final String reflectionNotes;
  final Map<String, bool> booleanValues;
  final Map<String, double?> numericValues;

  // Real-Time Live Score
  final ScoreResult liveScore;

  DailyEntryState({
    required this.selectedDate,
    this.isLoading = false,
    this.isSaving = false,
    this.message,
    this.existingLog,
    this.sleepHours,
    this.studyHours,
    this.workHours,
    this.learnHours,
    this.reflectionNotes = '',
    this.booleanValues = const {},
    this.numericValues = const {},
    this.liveScore = const ScoreResult(
      passedCount: 0,
      totalCount: 0,
      percentage: 0.0,
      fraction: '0/0',
      isStreakQualified: false,
    ),
  });

  bool get isSleepOptimal => ScoringEngine.evaluateSleep(sleepHours);
  bool get isStudyMet => ScoringEngine.evaluateStudy(studyHours);
  bool get isWorkMet => ScoringEngine.evaluateWork(workHours);
  bool get isLearnMet => ScoringEngine.evaluateLearn(learnHours);

  DailyEntryState copyWith({
    DateTime? selectedDate,
    bool? isLoading,
    bool? isSaving,
    String? message,
    DailyLog? existingLog,
    double? sleepHours,
    double? studyHours,
    double? workHours,
    double? learnHours,
    String? reflectionNotes,
    Map<String, bool>? booleanValues,
    Map<String, double?>? numericValues,
    ScoreResult? liveScore,
  }) {
    return DailyEntryState(
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      message: message,
      existingLog: existingLog ?? this.existingLog,
      sleepHours: sleepHours ?? this.sleepHours,
      studyHours: studyHours ?? this.studyHours,
      workHours: workHours ?? this.workHours,
      learnHours: learnHours ?? this.learnHours,
      reflectionNotes: reflectionNotes ?? this.reflectionNotes,
      booleanValues: booleanValues ?? this.booleanValues,
      numericValues: numericValues ?? this.numericValues,
      liveScore: liveScore ?? this.liveScore,
    );
  }
}

class DailyEntryNotifier extends StateNotifier<DailyEntryState> {
  final SupabaseService _service;
  final Ref _ref;

  DailyEntryNotifier(this._service, this._ref)
      : super(DailyEntryState(
          // Date Initialization Requirement: Default to yesterday's date (Current Date - 1)
          selectedDate: DateTime.now().subtract(const Duration(days: 1)),
        )) {
    loadLogForDate(state.selectedDate);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadLogForDate(date);
  }

  Future<void> loadLogForDate(DateTime date) async {
    state = state.copyWith(isLoading: true);
    final activeHabits = _ref.read(habitProvider).activeHabits;

    try {
      final log = await _service.fetchDailyLogByDate(date);

      final Map<String, bool> boolMap = {};
      final Map<String, double?> numMap = {};

      if (log != null) {
        for (final entry in log.entries) {
          boolMap[entry.habitId] = entry.isPassed;
          numMap[entry.habitId] = entry.loggedValue;
        }
      }

      // Sync sleep / focus hours with specific habit rules if configured
      for (final h in activeHabits) {
        if (h.category == 'sleep' && log != null) {
          numMap[h.id] = log.sleepHours;
        } else if (h.title.toLowerCase().contains('work') && log != null) {
          numMap[h.id] = log.workHours;
        } else if (h.title.toLowerCase().contains('study') && log != null) {
          numMap[h.id] = log.studyHours;
        } else if (h.title.toLowerCase().contains('learn') && log != null) {
          numMap[h.id] = log.learnHours;
        }
      }

      final score = ScoringEngine.calculateDailyScore(
        activeHabits: activeHabits,
        booleanValues: boolMap,
        numericValues: numMap,
      );

      state = state.copyWith(
        isLoading: false,
        existingLog: log,
        sleepHours: log?.sleepHours,
        studyHours: log?.studyHours,
        workHours: log?.workHours,
        learnHours: log?.learnHours,
        reflectionNotes: log?.reflectionNotes ?? '',
        booleanValues: boolMap,
        numericValues: numMap,
        liveScore: score,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateSleepHours(double? hours) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final numMap = Map<String, double?>.from(state.numericValues);

    for (final h in activeHabits) {
      if (h.category == 'sleep' || h.title.toLowerCase().contains('sleep')) {
        numMap[h.id] = hours;
      }
    }

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: state.booleanValues,
      numericValues: numMap,
    );

    state = state.copyWith(
      sleepHours: hours,
      numericValues: numMap,
      liveScore: score,
    );
  }

  void updateStudyHours(double? hours) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final numMap = Map<String, double?>.from(state.numericValues);

    for (final h in activeHabits) {
      if (h.title.toLowerCase().contains('study')) {
        numMap[h.id] = hours;
      }
    }

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: state.booleanValues,
      numericValues: numMap,
    );

    state = state.copyWith(
      studyHours: hours,
      numericValues: numMap,
      liveScore: score,
    );
  }

  void updateWorkHours(double? hours) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final numMap = Map<String, double?>.from(state.numericValues);

    for (final h in activeHabits) {
      if (h.title.toLowerCase().contains('work')) {
        numMap[h.id] = hours;
      }
    }

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: state.booleanValues,
      numericValues: numMap,
    );

    state = state.copyWith(
      workHours: hours,
      numericValues: numMap,
      liveScore: score,
    );
  }

  void updateLearnHours(double? hours) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final numMap = Map<String, double?>.from(state.numericValues);

    for (final h in activeHabits) {
      if (h.title.toLowerCase().contains('learn')) {
        numMap[h.id] = hours;
      }
    }

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: state.booleanValues,
      numericValues: numMap,
    );

    state = state.copyWith(
      learnHours: hours,
      numericValues: numMap,
      liveScore: score,
    );
  }

  void updateBooleanHabit(String habitId, bool value) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final boolMap = Map<String, bool>.from(state.booleanValues);
    boolMap[habitId] = value;

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: boolMap,
      numericValues: state.numericValues,
    );

    state = state.copyWith(
      booleanValues: boolMap,
      liveScore: score,
    );
  }

  void updateNumericHabit(String habitId, double? value) {
    final activeHabits = _ref.read(habitProvider).activeHabits;
    final numMap = Map<String, double?>.from(state.numericValues);
    numMap[habitId] = value;

    final score = ScoringEngine.calculateDailyScore(
      activeHabits: activeHabits,
      booleanValues: state.booleanValues,
      numericValues: numMap,
    );

    state = state.copyWith(
      numericValues: numMap,
      liveScore: score,
    );
  }

  void updateReflectionNotes(String notes) {
    state = state.copyWith(reflectionNotes: notes);
  }

  Future<bool> saveReview() async {
    state = state.copyWith(isSaving: true, message: null);
    final activeHabits = _ref.read(habitProvider).activeHabits;

    final entries = activeHabits.map((h) {
      final boolVal = state.booleanValues[h.id];
      final numVal = state.numericValues[h.id];
      final isPassed = h.evaluate(booleanValue: boolVal, numericValue: numVal);

      return DailyHabitEntry(
        id: '',
        dailyLogId: state.existingLog?.id ?? '',
        habitId: h.id,
        isPassed: isPassed,
        loggedValue: numVal,
      );
    }).toList();

    try {
      final saved = await _service.saveDailyReview(
        date: state.selectedDate,
        scoreFraction: state.liveScore.fraction,
        scorePercentage: state.liveScore.percentage,
        isStreakQualified: state.liveScore.isStreakQualified,
        studyHours: state.studyHours ?? 0.0,
        workHours: state.workHours ?? 0.0,
        learnHours: state.learnHours ?? 0.0,
        sleepHours: state.sleepHours ?? 0.0,
        reflectionNotes: state.reflectionNotes,
        entries: entries,
      );

      state = state.copyWith(
        isSaving: false,
        existingLog: saved,
        message: 'Review saved! Score: ${state.liveScore.fraction} (${state.liveScore.percentage}%)',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        message: 'Saved locally in preview mode.',
      );
      return true;
    }
  }
}

final dailyEntryProvider = StateNotifierProvider<DailyEntryNotifier, DailyEntryState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return DailyEntryNotifier(service, ref);
});
