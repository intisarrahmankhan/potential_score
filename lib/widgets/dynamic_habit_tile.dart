import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/habit.dart';

class DynamicHabitTile extends StatelessWidget {
  final Habit habit;
  final bool? isChecked;
  final double? numericValue;
  final ValueChanged<bool> onBooleanChanged;
  final ValueChanged<double?> onNumericChanged;

  const DynamicHabitTile({
    super.key,
    required this.habit,
    required this.isChecked,
    required this.numericValue,
    required this.onBooleanChanged,
    required this.onNumericChanged,
  });

  bool get isPassed => habit.evaluate(
        booleanValue: isChecked,
        numericValue: numericValue,
      );

  @override
  Widget build(BuildContext context) {
    if (habit.habitType == HabitType.boolean) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPassed ? AppTheme.success.withOpacity(0.4) : Theme.of(context).dividerColor,
          ),
        ),
        child: CheckboxListTile(
          value: isChecked ?? false,
          onChanged: (val) => onBooleanChanged(val ?? false),
          activeColor: AppTheme.primary,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            habit.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isPassed ? null : Colors.grey[400],
            ),
          ),
          secondary: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPassed ? AppTheme.success.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPassed ? 'Done ✓' : 'Pending',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPassed ? AppTheme.success : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Numeric Habit Tile (Range, Min, Max)
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPassed ? AppTheme.success.withOpacity(0.4) : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  _getCriteriaString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: numericValue?.toString() ?? '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                suffixText: habit.unit,
                isDense: true,
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val.trim());
                onNumericChanged(parsed);
              },
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isPassed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: isPassed ? AppTheme.success : Colors.grey,
          ),
        ],
      ),
    );
  }

  String _getCriteriaString() {
    switch (habit.habitType) {
      case HabitType.numericRange:
        return 'Target: ${habit.targetMin} - ${habit.targetMax} ${habit.unit}';
      case HabitType.numericMin:
        return 'Target: >= ${habit.targetMin} ${habit.unit}';
      case HabitType.numericMax:
        return 'Target: <= ${habit.targetMax} ${habit.unit}';
      case HabitType.boolean:
        return 'Checkbox criteria';
    }
  }
}
