import 'package:intl/intl.dart';
import 'daily_habit_entry.dart';

class DailyLog {
  final String id;
  final String userId;
  final DateTime logDate;
  final String scoreFraction;
  final double scorePercentage;
  final bool isStreakQualified;
  final double studyHours;
  final double workHours;
  final double learnHours;
  final double sleepHours;
  final String reflectionNotes;
  final List<DailyHabitEntry> entries;
  final DateTime? createdAt;

  const DailyLog({
    required this.id,
    required this.userId,
    required this.logDate,
    this.scoreFraction = '0/0',
    this.scorePercentage = 0.0,
    this.isStreakQualified = false,
    this.studyHours = 0.0,
    this.workHours = 0.0,
    this.learnHours = 0.0,
    this.sleepHours = 0.0,
    this.reflectionNotes = '',
    this.entries = const [],
    this.createdAt,
  });

  String get formattedDate => DateFormat('EEE, MMM d, yyyy').format(logDate);
  String get dateIsoString => DateFormat('yyyy-MM-dd').format(logDate);
  double get totalProductiveHours => studyHours + workHours;

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    var rawEntries = json['daily_habit_entries'] as List<dynamic>?;
    List<DailyHabitEntry> parsedEntries = [];
    if (rawEntries != null) {
      parsedEntries = rawEntries
          .map((e) => DailyHabitEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DailyLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      scoreFraction: (json['score_fraction'] as String?) ?? '0/0',
      scorePercentage: json['score_percentage'] != null
          ? (json['score_percentage'] as num).toDouble()
          : 0.0,
      isStreakQualified: (json['is_streak_qualified'] as bool?) ?? false,
      studyHours: json['study_hours'] != null
          ? (json['study_hours'] as num).toDouble()
          : 0.0,
      workHours: json['work_hours'] != null
          ? (json['work_hours'] as num).toDouble()
          : 0.0,
      learnHours: json['learn_hours'] != null
          ? (json['learn_hours'] as num).toDouble()
          : 0.0,
      sleepHours: json['sleep_hours'] != null
          ? (json['sleep_hours'] as num).toDouble()
          : 0.0,
      reflectionNotes: (json['reflection_notes'] as String?) ?? '',
      entries: parsedEntries,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': DateFormat('yyyy-MM-dd').format(logDate),
      'score_fraction': scoreFraction,
      'score_percentage': scorePercentage,
      'is_streak_qualified': isStreakQualified,
      'study_hours': studyHours,
      'work_hours': workHours,
      'learn_hours': learnHours,
      'sleep_hours': sleepHours,
      'reflection_notes': reflectionNotes,
    };
  }

  DailyLog copyWith({
    String? scoreFraction,
    double? scorePercentage,
    bool? isStreakQualified,
    double? studyHours,
    double? workHours,
    double? learnHours,
    double? sleepHours,
    String? reflectionNotes,
    List<DailyHabitEntry>? entries,
  }) {
    return DailyLog(
      id: id,
      userId: userId,
      logDate: logDate,
      scoreFraction: scoreFraction ?? this.scoreFraction,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      isStreakQualified: isStreakQualified ?? this.isStreakQualified,
      studyHours: studyHours ?? this.studyHours,
      workHours: workHours ?? this.workHours,
      learnHours: learnHours ?? this.learnHours,
      sleepHours: sleepHours ?? this.sleepHours,
      reflectionNotes: reflectionNotes ?? this.reflectionNotes,
      entries: entries ?? this.entries,
      createdAt: createdAt,
    );
  }
}
