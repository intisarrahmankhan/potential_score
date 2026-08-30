import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import '../models/daily_habit_entry.dart';

class SupabaseService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // --- Auth Methods ---
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) return null;
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = _client;
    if (client == null) return null;
    return await client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }

  // --- Habits CRUD ---
  Future<List<Habit>> fetchHabits() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) {
      return _getMockDefaultHabits();
    }

    try {
      final response = await client
          .from('habits')
          .select()
          .eq('user_id', user.id)
          .order('order_index', ascending: true);

      final list = (response as List)
          .map((json) => Habit.fromJson(json as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        return await initDefaultHabits(user.id);
      }
      return list;
    } catch (e) {
      return _getMockDefaultHabits();
    }
  }

  Future<Habit?> createHabit(Habit habit) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;

    final json = habit.toJson()..remove('id');
    json['user_id'] = user.id;

    final response = await client.from('habits').insert(json).select().single();
    return Habit.fromJson(response);
  }

  Future<void> updateHabit(Habit habit) async {
    final client = _client;
    if (client == null) return;
    await client.from('habits').update(habit.toJson()).eq('id', habit.id);
  }

  Future<void> toggleHabitActive(String habitId, bool isActive) async {
    final client = _client;
    if (client == null) return;
    await client.from('habits').update({'is_active': isActive}).eq('id', habitId);
  }

  Future<void> deleteHabit(String habitId) async {
    final client = _client;
    if (client == null) return;
    await client.from('habits').delete().eq('id', habitId);
  }

  Future<List<Habit>> initDefaultHabits(String userId) async {
    final client = _client;
    if (client == null) return _getMockDefaultHabits();

    final defaultList = [
      {'title': 'Sleep Duration (7.0 - 8.5 hrs)', 'category': 'sleep', 'habit_type': 'numeric_range', 'unit': 'hrs', 'target_min': 7.0, 'target_max': 8.5, 'order_index': 1},
      {'title': 'Work Focus Time (>= 4.0 hrs)', 'category': 'productivity', 'habit_type': 'numeric_min', 'unit': 'hrs', 'target_min': 4.0, 'order_index': 2},
      {'title': 'Study Focus Time (>= 2.0 hrs)', 'category': 'productivity', 'habit_type': 'numeric_min', 'unit': 'hrs', 'target_min': 2.0, 'order_index': 3},
      {'title': 'Learn New Skills (>= 1.0 hr)', 'category': 'productivity', 'habit_type': 'numeric_min', 'unit': 'hrs', 'target_min': 1.0, 'order_index': 4},
      {'title': 'Physical Workout / Exercise', 'category': 'health', 'habit_type': 'boolean', 'unit': '', 'order_index': 5},
      {'title': 'Hydration (3L+ Water)', 'category': 'health', 'habit_type': 'boolean', 'unit': '', 'order_index': 6},
      {'title': 'Clean Nutrition & No Sugar', 'category': 'health', 'habit_type': 'boolean', 'unit': '', 'order_index': 7},
      {'title': 'Read 20+ Pages of Book', 'category': 'mindset', 'habit_type': 'boolean', 'unit': '', 'order_index': 8},
      {'title': 'Mindfulness & Meditation', 'category': 'mindset', 'habit_type': 'boolean', 'unit': '', 'order_index': 9},
      {'title': 'No Screen 1hr Before Bed', 'category': 'mindset', 'habit_type': 'boolean', 'unit': '', 'order_index': 10},
    ];

    final insertPayload = defaultList.map((h) => {...h, 'user_id': userId, 'is_active': true}).toList();
    final res = await client.from('habits').insert(insertPayload).select();
    return (res as List).map((j) => Habit.fromJson(j as Map<String, dynamic>)).toList();
  }

  // --- Daily Logs CRUD ---
  Future<DailyLog?> fetchDailyLogByDate(DateTime date) async {
    final client = _client;
    final user = currentUser;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (client == null || user == null) return null;

    try {
      final response = await client
          .from('daily_logs')
          .select('*, daily_habit_entries(*)')
          .eq('user_id', user.id)
          .eq('log_date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      return DailyLog.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<List<DailyLog>> fetchAllDailyLogs({int limit = 365}) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return [];

    try {
      final response = await client
          .from('daily_logs')
          .select('*, daily_habit_entries(*)')
          .eq('user_id', user.id)
          .order('log_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DailyLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<DailyLog?> saveDailyReview({
    required DateTime date,
    required String scoreFraction,
    required double scorePercentage,
    required bool isStreakQualified,
    required double studyHours,
    required double workHours,
    required double learnHours,
    required double sleepHours,
    required String reflectionNotes,
    required List<DailyHabitEntry> entries,
  }) async {
    final client = _client;
    final user = currentUser;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (client == null || user == null) return null;

    // Upsert Daily Log
    final logPayload = {
      'user_id': user.id,
      'log_date': dateStr,
      'score_fraction': scoreFraction,
      'score_percentage': scorePercentage,
      'is_streak_qualified': isStreakQualified,
      'study_hours': studyHours,
      'work_hours': workHours,
      'learn_hours': learnHours,
      'sleep_hours': sleepHours,
      'reflection_notes': reflectionNotes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final logRes = await client
        .from('daily_logs')
        .upsert(logPayload, onConflict: 'user_id,log_date')
        .select()
        .single();

    final savedLogId = logRes['id'] as String;

    // Upsert Habit Entries
    if (entries.isNotEmpty) {
      final entriesPayload = entries.map((e) => {
        'daily_log_id': savedLogId,
        'habit_id': e.habitId,
        'is_passed': e.isPassed,
        'logged_value': e.loggedValue,
      }).toList();

      await client
          .from('daily_habit_entries')
          .upsert(entriesPayload, onConflict: 'daily_log_id,habit_id');
    }

    return fetchDailyLogByDate(date);
  }

  // --- Mock Seed Data for Preview & Local Testing ---
  List<Habit> _getMockDefaultHabits() {
    return [
      const Habit(id: '1', userId: 'demo', title: 'Sleep Duration (7.0 - 8.5 hrs)', category: 'sleep', habitType: HabitType.numericRange, unit: 'hrs', targetMin: 7.0, targetMax: 8.5, orderIndex: 1),
      const Habit(id: '2', userId: 'demo', title: 'Work Focus Time (>= 4.0 hrs)', category: 'productivity', habitType: HabitType.numericMin, unit: 'hrs', targetMin: 4.0, orderIndex: 2),
      const Habit(id: '3', userId: 'demo', title: 'Study Focus Time (>= 2.0 hrs)', category: 'productivity', habitType: HabitType.numericMin, unit: 'hrs', targetMin: 2.0, orderIndex: 3),
      const Habit(id: '4', userId: 'demo', title: 'Learn New Skills (>= 1.0 hr)', category: 'productivity', habitType: HabitType.numericMin, unit: 'hrs', targetMin: 1.0, orderIndex: 4),
      const Habit(id: '5', userId: 'demo', title: 'Physical Workout / Exercise', category: 'health', habitType: HabitType.boolean, orderIndex: 5),
      const Habit(id: '6', userId: 'demo', title: 'Hydration (3L+ Water)', category: 'health', habitType: HabitType.boolean, orderIndex: 6),
      const Habit(id: '7', userId: 'demo', title: 'Clean Nutrition & No Sugar', category: 'health', habitType: HabitType.boolean, orderIndex: 7),
      const Habit(id: '8', userId: 'demo', title: 'Read 20+ Pages of Book', category: 'mindset', habitType: HabitType.boolean, orderIndex: 8),
      const Habit(id: '9', userId: 'demo', title: 'Mindfulness & Meditation', category: 'mindset', habitType: HabitType.boolean, orderIndex: 9),
      const Habit(id: '10', userId: 'demo', title: 'No Screen 1hr Before Bed', category: 'mindset', habitType: HabitType.boolean, orderIndex: 10),
    ];
  }

  List<DailyLog> _getMockLogs() {
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: i + 1));
      final pct = 70.0 + (i % 4) * 10.0;
      return DailyLog(
        id: 'mock-$i',
        userId: 'demo',
        logDate: date,
        scoreFraction: '${(pct / 10).round()}/10',
        scorePercentage: pct > 100 ? 100 : pct,
        isStreakQualified: pct >= 80.0,
        studyHours: 2.0 + (i % 3) * 0.5,
        workHours: 4.0 + (i % 2) * 1.0,
        learnHours: 1.0 + (i % 2) * 0.5,
        sleepHours: 7.5 + ((i % 3) == 0 ? -1.0 : 0.2),
        reflectionNotes: i % 3 == 0 ? 'Felt energetic and completed high-focus blocks.' : '',
      );
    });
  }
}
