import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitManagementModal extends ConsumerStatefulWidget {
  const HabitManagementModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HabitManagementModal(),
    );
  }

  @override
  ConsumerState<HabitManagementModal> createState() => _HabitManagementModalState();
}

class _HabitManagementModalState extends ConsumerState<HabitManagementModal> {
  final _titleController = TextEditingController();
  final _unitController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  HabitType _selectedType = HabitType.boolean;
  String _category = 'custom';
  bool _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _saveNewHabit() async {
    if (_titleController.text.trim().isEmpty) return;

    final habit = Habit(
      id: '',
      userId: '',
      title: _titleController.text.trim(),
      category: _category,
      habitType: _selectedType,
      unit: _unitController.text.trim(),
      targetMin: double.tryParse(_minController.text.trim()),
      targetMax: double.tryParse(_maxController.text.trim()),
      isActive: true,
    );

    await ref.read(habitProvider.notifier).addHabit(habit);
    setState(() {
      _isAdding = false;
      _titleController.clear();
      _unitController.clear();
      _minController.clear();
      _maxController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Habit & Rule Manager',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Customize dynamic evaluation criteria',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Toggle Add Form Button
                if (!_isAdding)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isAdding = true),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add New Custom Habit / Rule', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  )
                else
                  // New Habit Creation Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'New Dynamic Rule',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Habit Title *',
                              hintText: 'e.g. 10k Daily Steps, Read 20 Pages',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<HabitType>(
                            value: _selectedType,
                            decoration: const InputDecoration(labelText: 'Evaluation Type'),
                            items: HabitType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedType = val);
                            },
                          ),
                          if (_selectedType != HabitType.boolean) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _unitController,
                                    decoration: const InputDecoration(
                                      labelText: 'Unit',
                                      hintText: 'hrs, steps, pages',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _minController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Min / Goal',
                                      hintText: 'e.g. 10000',
                                    ),
                                  ),
                                ),
                                if (_selectedType == HabitType.numericRange) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Max',
                                        hintText: 'e.g. 8.5',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _isAdding = false),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _saveNewHabit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Save Rule', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                const Text(
                  'ACTIVE & CONFIGURED RULES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                // Configured Habits List
                ...habitState.habits.map((habit) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: habit.isActive
                            ? Theme.of(context).dividerColor
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      title: Text(
                        habit.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: habit.isActive ? null : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        '${habit.habitType.displayName} ${habit.unit.isNotEmpty ? "(${habit.unit})" : ""}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: habit.isActive,
                            activeColor: AppTheme.primary,
                            onChanged: (val) => notifier.toggleActive(habit.id, val),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                            onPressed: () => notifier.deleteHabit(habit.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
