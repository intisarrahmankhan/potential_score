import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      await notifier.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );
    } else {
      await notifier.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Icon
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 30),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        _isSignUp ? 'Join 365 Potential' : 'Sign In to 365 Potential',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp
                            ? 'Create your habit rules and start your streak'
                            : 'Log your morning retrospective review',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 24),

                      if (authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) => val == null || val.length < 6 ? 'Password must be >= 6 chars' : null,
                      ),

                      const SizedBox(height: 22),

                      // Submit Button
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                      ),

                      const SizedBox(height: 14),

                      // Demo Mode Option
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).enterDemoMode();
                        },
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                        label: const Text('Try Demo Mode (Instant Access)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Toggle Sign In / Sign Up
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : "Don't have an account? Sign Up",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
