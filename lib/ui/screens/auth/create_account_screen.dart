import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_provider.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_state.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).registerWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fonts = context.appFonts;

    ref.listen<UserAuthState>(authProvider, (_, next) {
      if (next is UserAuthAuthenticated) {
        context.goNamed(Routes.root.name);
      } else if (next is UserAuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message,
              style: fonts.bodyMedium()?.copyWith(color: colorWhite),
            ),
            backgroundColor: next.message.toLowerCase().contains('confirm')
                ? colors.colorPrimary
                : colors.colorRedBox,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authProvider) is UserAuthLoading;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: colors.colorPrimaryText, size: 18),
          onPressed: () => context.goNamed(Routes.login.name),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────
                Text(
                  'Create account',
                  style: fonts.headlineLarge()?.copyWith(
                    color: colors.colorPrimaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Start tracking your students today',
                  style: fonts.bodyMedium()?.copyWith(
                    color: colors.colorSecondaryText,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Full name ─────────────────────────────────────────
                _FieldLabel(label: 'Full Name', colors: colors),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: fonts.bodyMedium()
                      ?.copyWith(color: colors.colorPrimaryText),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: 'Your name',
                    icon: Icons.person_outline,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────────────────
                _FieldLabel(label: 'Email', colors: colors),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: fonts.bodyMedium()
                      ?.copyWith(color: colors.colorPrimaryText),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────────
                _FieldLabel(label: 'Password', colors: colors),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: fonts.bodyMedium()
                      ?.copyWith(color: colors.colorPrimaryText),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: 'Min. 8 characters',
                    icon: Icons.lock_outline,
                    suffix: _VisibilityToggle(
                      obscure: _obscurePassword,
                      colors: colors,
                      onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Confirm password ──────────────────────────────────
                _FieldLabel(label: 'Confirm Password', colors: colors),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: fonts.bodyMedium()
                      ?.copyWith(color: colors.colorPrimaryText),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: 'Re-enter password',
                    icon: Icons.lock_outline,
                    suffix: _VisibilityToggle(
                      obscure: _obscureConfirm,
                      colors: colors,
                      onTap: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ── Register button ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.colorPrimary,
                      disabledBackgroundColor: colors.colorButtonDisable,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.colorWhite,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: fonts.bodyLarge()?.copyWith(
                              color: colors.colorWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Login link ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: fonts.bodyMedium()?.copyWith(
                        color: colors.colorSecondaryText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(Routes.login.name),
                      child: Text(
                        'Sign In',
                        style: fonts.bodyMedium()?.copyWith(
                          color: colors.colorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required AppColors colors,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.colorHint),
      prefixIcon: Icon(icon, color: colors.colorGray, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.colorWhite,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorRedBox),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.colorRedBox, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _FieldLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.appFonts.bodySmall()?.copyWith(
            color: colors.colorPrimaryText,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final AppColors colors;
  final VoidCallback onTap;
  const _VisibilityToggle({
    required this.obscure,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: colors.colorGray,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}