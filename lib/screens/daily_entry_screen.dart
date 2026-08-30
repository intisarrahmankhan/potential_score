import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/daily_log_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/scoring_engine.dart';
import '../widgets/live_score_header.dart';
import '../widgets/sleep_tracker_card.dart';
import '../widgets/focus_split_card.dart';
import '../widgets/dynamic_habit_tile.dart';

class DailyEntryScreen extends ConsumerStatefulWidget {
  const DailyEntryScreen({super.key});

  @override
  ConsumerState<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends ConsumerState<DailyEntryScreen> {
  double _studyTarget = 2.0;
  double _workTarget = 4.0;
  int _leisureHours = 1;
  int _leisureMinutes = 30;
  bool _isNMPassed = false; // UNCHECKED BY DEFAULT
  bool _isNPPassed = false; // UNCHECKED BY DEFAULT
  bool _isStaminaBlockOpen = false; // HIDDEN UNDER ARROW BY DEFAULT

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(dailyEntryProvider);
    final entryNotifier = ref.read(dailyEntryProvider.notifier);
    final habitState = ref.watch(habitProvider);
    final analytics = ref.watch(analyticsProvider);

    // Active general checklist habits
    final generalHabits = habitState.activeHabits.where((h) {
      final titleLower = h.title.toLowerCase();
      return h.category != 'sleep' &&
          !titleLower.contains('sleep') &&
          !titleLower.contains('study') &&
          !titleLower.contains('work');
    }).toList();

    // Recalculate score on-the-fly with NM, NP, Sleep, and Leisure
    final liveScore = ScoringEngine.calculateDailyScore(
      activeHabits: generalHabits,
      booleanValues: entryState.booleanValues,
      numericValues: entryState.numericValues,
      isNMPassed: _isNMPassed,
      isNPPassed: _isNPPassed,
      sleepHours: entryState.sleepHours,
      studyHours: entryState.studyHours,
      studyTarget: _studyTarget,
      workHours: entryState.workHours,
      workTarget: _workTarget,
      leisureHours: _leisureHours,
      leisureMinutes: _leisureMinutes,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Potential Score', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: liveScore.isStreakQualified ? AppTheme.success.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: liveScore.isStreakQualified ? AppTheme.success.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
                ),
              ),
              child: Text(
                '${liveScore.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: liveScore.isStreakQualified ? AppTheme.success : Colors.amberAccent,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Select Review Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: entryState.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                entryNotifier.setDate(picked);
              }
            },
          ),
        ],
      ),
      body: entryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Sticky Top Live Score Header
                      LiveScoreHeader(
                        score: liveScore,
                        selectedDate: entryState.selectedDate,
                        onDateTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: entryState.selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            entryNotifier.setDate(picked);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // 2. CORE STAMINA & DISCIPLINE PILLARS (HIDDEN UNDER ARROW BY DEFAULT, UNCHECKED BY DEFAULT)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.rose.withOpacity(0.35)),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isStaminaBlockOpen = !_isStaminaBlockOpen;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.rose.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.shield_outlined, size: 18, color: Colors.roseAccent),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Avoid Bad Habits (Discipline Pillars)',
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                            ),
                                            Text(
                                              (_isNMPassed && _isNPPassed)
                                                  ? 'Clean discipline confirmed ✓'
                                                  : 'Unticked: High penalty active',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: (_isNMPassed && _isNPPassed) ? AppTheme.success : AppTheme.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _isStaminaBlockOpen ? 'Hide' : 'Open',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.roseAccent),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isStaminaBlockOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: Colors.roseAccent,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Collapsible Content
                            if (_isStaminaBlockOpen) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    // NM (Bad Habit) Checkbox
                                    CheckboxListTile(
                                      title: const Text('NM (Bad Habit)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      subtitle: const Text('Preserves physical stamina & vitality. Unticked incurs -25% penalty.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      value: _isNMPassed,
                                      activeColor: AppTheme.success,
                                      onChanged: (val) => setState(() => _isNMPassed = val ?? false),
                                      secondary: const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 20),
                                    ),
                                    const Divider(height: 1),
                                    // NP (Bad Habit) Checkbox
                                    CheckboxListTile(
                                      title: const Text('NP (Bad Habit)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      subtitle: const Text('Protects dopamine focus & clarity. Unticked incurs -15% penalty.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      value: _isNPPassed,
                                      activeColor: AppTheme.success,
                                      onChanged: (val) => setState(() => _isNPPassed = val ?? false),
                                      secondary: const Icon(Icons.psychology_rounded, color: Colors.purpleAccent, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Sleep & Recovery Card (Optimal 7.0 - 8.5 hrs)
                      SleepTrackerCard(
                        sleepHours: entryState.sleepHours,
                        onChanged: (hours) => entryNotifier.updateSleepHours(hours),
                      ),

                      const SizedBox(height: 16),

                      // 4. Focus Split & Leisure Tracker (Study, Work, Leisure with Minutes)
                      FocusSplitCard(
                        studyHours: entryState.studyHours,
                        workHours: entryState.workHours,
                        leisureHours: _leisureHours,
                        leisureMinutes: _leisureMinutes,
                        studyTarget: _studyTarget,
                        workTarget: _workTarget,
                        onStudyChanged: (h) => entryNotifier.updateStudyHours(h),
                        onWorkChanged: (h) => entryNotifier.updateWorkHours(h),
                        onLeisureHoursChanged: (h) => setState(() => _leisureHours = h),
                        onLeisureMinutesChanged: (m) => setState(() => _leisureMinutes = m),
                        onStudyTargetChanged: (t) => setState(() => _studyTarget = t),
                        onWorkTargetChanged: (t) => setState(() => _workTarget = t),
                      ),

                      const SizedBox(height: 16),

                      // 5. Dynamic Habits Checklist
                      if (generalHabits.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: Text(
                            'DAILY DISCIPLINES & HEALTH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...generalHabits.map((habit) {
                          return DynamicHabitTile(
                            habit: habit,
                            isChecked: entryState.booleanValues[habit.id],
                            numericValue: entryState.numericValues[habit.id],
                            onBooleanChanged: (val) => entryNotifier.updateBooleanHabit(habit.id, val),
                            onNumericChanged: (val) => entryNotifier.updateNumericHabit(habit.id, val),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // 6. Daily Reflection Notes Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, color: AppTheme.warning, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Daily Reflection Notes',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                initialValue: entryState.reflectionNotes,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Why did you succeed or fail today? Friction, coffee timing, lessons...',
                                ),
                                onChanged: (val) => entryNotifier.updateReflectionNotes(val),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 7. Save Review Action Button
                      ElevatedButton.icon(
                        onPressed: entryState.isSaving
                            ? null
                            : () async {
                                if (entryState.selectedDate.isAfter(DateTime.now())) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('⚠️ Cannot log or edit reviews for future dates! Only past days or today can be reviewed.'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                  return;
                                }
                                final success = await entryNotifier.saveReview();
                                if (success && context.mounted) {
                                  ref.read(analyticsProvider.notifier).loadAnalytics();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Saved review for ${entryState.selectedDate.month}/${entryState.selectedDate.day}! Score: ${liveScore.fraction} (${liveScore.percentage}%)',
                                      ),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                }
                              },
                        icon: entryState.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(
                          entryState.isSaving ? 'Saving...' : 'Save Daily Review',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 2,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 8. PAST REVIEWS LIST WITH >=80% STREAK LOWER FONT NUMBERS AND >=90% ACHIEVEMENT MARKS
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.history_rounded, size: 18, color: AppTheme.primaryLight),
                                      SizedBox(width: 8),
                                      Text(
                                        'Daily Reviews History & Streaks',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${analytics.allLogs.length} Total',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Streak days (>= 80%) show flame numbers; Elite days (> 90%) earn the Achievement mark',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 14),

                              if (analytics.allLogs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No past reviews yet. Save today\'s review to start your history!',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: analytics.allLogs.take(10).length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final log = analytics.allLogs[index];
                                    final isStreak = log.scorePercentage >= 80.0;
                                    final isAchievement = log.scorePercentage >= 90.0;

                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isAchievement
                                              ? Colors.amber.withOpacity(0.18)
                                              : (isStreak ? AppTheme.success.withOpacity(0.15) : Colors.grey.withOpacity(0.1)),
                                          borderRadius: BorderRadius.circular(14),
                                          border: isAchievement
                                              ? Border.all(color: Colors.amber.withOpacity(0.5))
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${log.scorePercentage.toInt()}%',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                color: isAchievement ? Colors.amber : (isStreak ? AppTheme.success : Colors.grey),
                                              ),
                                            ),
                                            Text(
                                              log.scoreFraction,
                                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            DateFormat('EEE, MMM d').format(log.logDate),
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                          ),
                                          const SizedBox(width: 6),

                                          // STREAK BADGE WITH LOWER FONT NUMBERS (>= 80%)
                                          if (isStreak)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('🔥', style: TextStyle(fontSize: 11)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${analytics.currentStreak}',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          const SizedBox(width: 4),

                                          // > 90% ACHIEVEMENT MARK BADGE
                                          if (isAchievement)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.yellow.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.yellow.withOpacity(0.4)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('⭐', style: TextStyle(fontSize: 10)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    log.scorePercentage >= 100 ? '100%' : 'Elite 90%+',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.yellow,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: log.reflectionNotes.isNotEmpty
                                          ? Text(
                                              '"${log.reflectionNotes}"',
                                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              'Sleep: ${log.sleepHours}h • Study: ${log.studyHours}h • Work: ${log.workHours}h',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        onPressed: () {
                                          entryNotifier.setDate(log.logDate);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Loaded review for ${DateFormat('MMM d').format(log.logDate)}'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
