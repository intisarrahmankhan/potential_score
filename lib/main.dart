import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (with try-catch for local demo mode fallback)
  try {
    if (SupabaseConfig.supabaseUrl.isNotEmpty &&
        !SupabaseConfig.supabaseUrl.contains('xyzcompany')) {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('Supabase initialization note: Running in preview/local mode ($e)');
  }

  runApp(const ProviderScope(child: PotentialTrackerApp()));
}

class PotentialTrackerApp extends ConsumerWidget {
  const PotentialTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: '365 Potential Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: authState.isAuthenticated ? const HomeScreen() : const AuthScreen(),
    );
  }
}
