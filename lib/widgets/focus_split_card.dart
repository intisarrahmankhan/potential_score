import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/scoring_engine.dart';

class FocusSplitCard extends StatelessWidget {
  final double? studyHours;
  final double? workHours;
  final int leisureHours;
  final int leisureMinutes;
  final double studyTarget;
  final double workTarget;
  final ValueChanged<double?> onStudyChanged;
  final ValueChanged<double?> onWorkChanged;
  final ValueChanged<int> onLeisureHoursChanged;
  final ValueChanged<int> onLeisureMinutesChanged;
  final ValueChanged<double> onStudyTargetChanged;
  final ValueChanged<double> onWorkTargetChanged;

  const FocusSplitCard({
    super.key,
    required this.studyHours,
    required this.workHours,
    this.leisureHours = 1,
    this.leisureMinutes = 30,
    this.studyTarget = 2.0,
    this.workTarget = 4.0,
    required this.onStudyChanged,
    required this.onWorkChanged,
    required this.onLeisureHoursChanged,
    required this.onLeisureMinutesChanged,
    required this.onStudyTargetChanged,
    required this.onWorkTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isStudyPassed = ScoringEngine.evaluateStudy(studyHours, target: studyTarget);
    final isWorkPassed = ScoringEngine.evaluateWork(workHours, target: workTarget);
    final double totalLeisure = leisureHours + (leisureMinutes / 60.0);
    final bool isLeisureSafe = totalLeisure <= 3.0; // <= 3h safe, > 3h penalty
    final totalFocus = (studyHours ?? 0.0) + (workHours ?? 0.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.purpleAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Split & Leisure Time',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Study, Work goals & Leisure limit (<= 3h)',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Focus: ${totalFocus.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3-Way Grid: Study, Work, and Leisure (Hours + Minutes)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 550;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 1.05 : 2.5,
                  children: [
                    // Study Block
                    _EditableFocusField(
                      title: 'Study Focus',
                      icon: Icons.menu_book_rounded,
                      color: Colors.blueAccent,
                      loggedHours: studyHours,
                      targetGoal: studyTarget,
                      isPassed: isStudyPassed,
                      onLoggedChanged: onStudyChanged,
                      onTargetChanged: onStudyTargetChanged,
                    ),

                    // Work Block
                    _EditableFocusField(
                      title: 'Work Focus',
                      icon: Icons.work_rounded,
                      color: Colors.indigoAccent,
                      loggedHours: workHours,
                      targetGoal: workTarget,
                      isPassed: isWorkPassed,
                      onLoggedChanged: onWorkChanged,
                      onTargetChanged: onWorkTargetChanged,
                    ),

                    // Leisure / Wasted Time Tracker (Editable in Hours & Minutes, Penalty if > 3h)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isLeisureSafe ? AppTheme.success.withOpacity(0.4) : AppTheme.error.withOpacity(0.6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.coffee_rounded, size: 16, color: Colors.amber),
                                  SizedBox(width: 6),
                                  Text(
                                    'Leisure / Quality Time',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isLeisureSafe ? AppTheme.success.withOpacity(0.12) : AppTheme.error.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isLeisureSafe ? 'Safe Rest ✓' : '> 3h Limit ⚠️',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isLeisureSafe ? AppTheme.success : AppTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              // Hours
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('HOURS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    TextFormField(
                                      initialValue: leisureHours.toString(),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                      decoration: const InputDecoration(contentPadding: EdgeInsets.all(8), suffixText: 'h', isDense: true),
                                      onChanged: (val) {
                                        final p = int.tryParse(val.trim());
                                        if (p != null) onLeisureHoursChanged(p);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Minutes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('MINUTES', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    TextFormField(
                                      initialValue: leisureMinutes.toString(),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                      decoration: const InputDecoration(contentPadding: EdgeInsets.all(8), suffixText: 'm', isDense: true),
                                      onChanged: (val) {
                                        final p = int.tryParse(val.trim());
                                        if (p != null) onLeisureMinutesChanged(p);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Text(
                            'Limit: <= 3h (${leisureHours}h ${leisureMinutes}m)',
                            style: TextStyle(fontSize: 9, color: isLeisureSafe ? Colors.grey : AppTheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableFocusField extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double? loggedHours;
  final double targetGoal;
  final bool isPassed;
  final ValueChanged<double?> onLoggedChanged;
  final ValueChanged<double> onTargetChanged;

  const _EditableFocusField({
    required this.title,
    required this.icon,
    required this.color,
    required this.loggedHours,
    required this.targetGoal,
    required this.isPassed,
    required this.onLoggedChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPassed ? AppTheme.success.withOpacity(0.5) : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPassed ? AppTheme.success.withOpacity(0.12) : AppTheme.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPassed ? 'Pass ✓' : 'Below',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isPassed ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              // Logged Input
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOGGED',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextFormField(
                      initialValue: loggedHours?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        suffixText: 'h',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val.trim());
                        onLoggedChanged(parsed);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Target Input
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GOAL',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextFormField(
                      initialValue: targetGoal.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        suffixText: 'h',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null && parsed > 0) {
                          onTargetChanged(parsed);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            'Target: >= ${targetGoal}h',
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
