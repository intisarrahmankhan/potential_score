class DailyHabitEntry {
  final String id;
  final String dailyLogId;
  final String habitId;
  final bool isPassed;
  final double? loggedValue;
  final DateTime? createdAt;

  const DailyHabitEntry({
    required this.id,
    required this.dailyLogId,
    required this.habitId,
    required this.isPassed,
    this.loggedValue,
    this.createdAt,
  });

  factory DailyHabitEntry.fromJson(Map<String, dynamic> json) {
    return DailyHabitEntry(
      id: json['id'] as String,
      dailyLogId: json['daily_log_id'] as String,
      habitId: json['habit_id'] as String,
      isPassed: (json['is_passed'] as bool?) ?? false,
      loggedValue: json['logged_value'] != null ? (json['logged_value'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daily_log_id': dailyLogId,
      'habit_id': habitId,
      'is_passed': isPassed,
      'logged_value': loggedValue,
    };
  }

  DailyHabitEntry copyWith({
    bool? isPassed,
    double? loggedValue,
  }) {
    return DailyHabitEntry(
      id: id,
      dailyLogId: dailyLogId,
      habitId: habitId,
      isPassed: isPassed ?? this.isPassed,
      loggedValue: loggedValue ?? this.loggedValue,
      createdAt: createdAt,
    );
  }
}
