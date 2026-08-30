enum HabitType {
  boolean,
  numericRange,
  numericMin,
  numericMax;

  static HabitType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'numeric_range':
      case 'range':
        return HabitType.numericRange;
      case 'numeric_min':
      case 'min':
      case 'min_value':
        return HabitType.numericMin;
      case 'numeric_max':
      case 'max':
      case 'max_value':
        return HabitType.numericMax;
      case 'boolean':
      default:
        return HabitType.boolean;
    }
  }

  String toDbString() {
    switch (this) {
      case HabitType.numericRange:
        return 'numeric_range';
      case HabitType.numericMin:
        return 'numeric_min';
      case HabitType.numericMax:
        return 'numeric_max';
      case HabitType.boolean:
        return 'boolean';
    }
  }

  String get displayName {
    switch (this) {
      case HabitType.numericRange:
        return 'Target Range (Min - Max)';
      case HabitType.numericMin:
        return 'At Least Goal (>= Min)';
      case HabitType.numericMax:
        return 'At Most Limit (<= Max)';
      case HabitType.boolean:
        return 'Yes / No Checkbox';
    }
  }
}

class Habit {
  final String id;
  final String userId;
  final String title;
  final String category;
  final HabitType habitType;
  final String unit;
  final double? targetMin;
  final double? targetMax;
  final bool isActive;
  final int orderIndex;
  final DateTime? createdAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.category = 'custom',
    this.habitType = HabitType.boolean,
    this.unit = '',
    this.targetMin,
    this.targetMax,
    this.isActive = true,
    this.orderIndex = 0,
    this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: (json['category'] as String?) ?? 'custom',
      habitType: HabitType.fromString((json['habit_type'] as String?) ?? 'boolean'),
      unit: (json['unit'] as String?) ?? '',
      targetMin: json['target_min'] != null ? (json['target_min'] as num).toDouble() : null,
      targetMax: json['target_max'] != null ? (json['target_max'] as num).toDouble() : null,
      isActive: (json['is_active'] as bool?) ?? true,
      orderIndex: (json['order_index'] as int?) ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'habit_type': habitType.toDbString(),
      'unit': unit,
      'target_min': targetMin,
      'target_max': targetMax,
      'is_active': isActive,
      'order_index': orderIndex,
    };
  }

  Habit copyWith({
    String? title,
    String? category,
    HabitType? habitType,
    String? unit,
    double? targetMin,
    double? targetMax,
    bool? isActive,
    int? orderIndex,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      category: category ?? this.category,
      habitType: habitType ?? this.habitType,
      unit: unit ?? this.unit,
      targetMin: targetMin ?? this.targetMin,
      targetMax: targetMax ?? this.targetMax,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt,
    );
  }

  /// Evaluates whether a given logged value meets the pass condition
  bool evaluate({bool? booleanValue, double? numericValue}) {
    if (habitType == HabitType.boolean) {
      return booleanValue ?? false;
    }
    if (numericValue == null) return false;

    switch (habitType) {
      case HabitType.numericRange:
        final min = targetMin ?? 0.0;
        final max = targetMax ?? 999999.0;
        return numericValue >= min && numericValue <= max;
      case HabitType.numericMin:
        final min = targetMin ?? 0.0;
        return numericValue >= min;
      case HabitType.numericMax:
        final max = targetMax ?? 999999.0;
        return numericValue <= max;
      case HabitType.boolean:
        return booleanValue ?? false;
    }
  }
}
