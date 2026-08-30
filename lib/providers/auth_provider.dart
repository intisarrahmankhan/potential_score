import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isDemoMode;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isDemoMode = false,
  });

  bool get isAuthenticated => user != null || isDemoMode;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isDemoMode,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _service;

  AuthNotifier(this._service) : super(AuthState(user: _service.currentUser));

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _service.signIn(email: email, password: password);
      state = state.copyWith(
        user: res?.user ?? _service.currentUser,
        isLoading: false,
        isDemoMode: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, {String? fullName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _service.signUp(email: email, password: password, fullName: fullName);
      state = state.copyWith(
        user: res?.user ?? _service.currentUser,
        isLoading: false,
        isDemoMode: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  void enterDemoMode() {
    state = state.copyWith(
      isDemoMode: true,
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AuthNotifier(service);
});
