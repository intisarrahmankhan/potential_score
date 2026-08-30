import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class HabitState {
  final List<Habit> habits;
  final bool isLoading;
  final String? errorMessage;

  const HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  List<Habit> get activeHabits => habits.where((h) => h.isActive).toList();

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  final SupabaseService _service;

  HabitNotifier(this._service) : super(const HabitState()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.fetchHabits();
      state = state.copyWith(habits: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final created = await _service.createHabit(habit);
      if (created != null) {
        state = state.copyWith(habits: [...state.habits, created]);
      } else {
        // Fallback for demo mode
        final mockHabit = habit.copyWith(orderIndex: state.habits.length + 1);
        state = state.copyWith(habits: [...state.habits, mockHabit]);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> toggleActive(String habitId, bool isActive) async {
    try {
      await _service.toggleHabitActive(habitId, isActive);
      final updated = state.habits.map((h) {
        if (h.id == habitId) return h.copyWith(isActive: isActive);
        return h;
      }).toList();
      state = state.copyWith(habits: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    try {
      await _service.updateHabit(updatedHabit);
      final updated = state.habits.map((h) {
        if (h.id == updatedHabit.id) return updatedHabit;
        return h;
      }).toList();
      state = state.copyWith(habits: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _service.deleteHabit(habitId);
      final updated = state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return HabitNotifier(service);
});
