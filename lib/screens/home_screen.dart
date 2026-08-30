import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'daily_entry_screen.dart';
import 'analytics_screen.dart';
import 'habit_management_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DailyEntryScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;

        if (isWide) {
          // Desktop / Tablet Navigation Rail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.tune_rounded),
                              tooltip: 'Habit Rules',
                              onPressed: () => HabitManagementModal.show(context),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(Icons.logout_rounded),
                              tooltip: 'Sign Out',
                              onPressed: () => ref.read(authProvider.notifier).signOut(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle_outline_rounded),
                      selectedIcon: Icon(Icons.check_circle_rounded),
                      label: Text('Daily Review'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.query_stats_rounded),
                      selectedIcon: Icon(Icons.query_stats_rounded),
                      label: Text('Analytics'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        }

        // Mobile Bottom Navigation Bar
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline_rounded),
                selectedIcon: Icon(Icons.check_circle_rounded),
                label: 'Daily Review',
              ),
              NavigationDestination(
                icon: Icon(Icons.query_stats_rounded),
                selectedIcon: Icon(Icons.query_stats_rounded),
                label: 'Analytics',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            tooltip: 'Customize Habit Rules',
            onPressed: () => HabitManagementModal.show(context),
            child: const Icon(Icons.tune_rounded),
          ),
        );
      },
    );
  }
}
