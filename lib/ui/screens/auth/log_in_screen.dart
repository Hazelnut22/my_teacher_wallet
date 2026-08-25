import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_provider.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fonts = context.appFonts;

    // Listen for auth changes and navigate
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
            backgroundColor: colors.colorRedBox,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState is UserAuthLoading;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Logo + header ─────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.colorPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colors.colorWhite,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Welcome back',
                    style: fonts.headlineLarge()?.copyWith(
                      color: colors.colorPrimaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Sign in to your account',
                    style: fonts.bodyMedium()?.copyWith(
                      color: colors.colorSecondaryText,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Email field ───────────────────────────────────────
                Text(
                  'Email',
                  style: fonts.bodySmall()?.copyWith(
                    color: colors.colorPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: fonts.bodyMedium()?.copyWith(
                    color: colors.colorPrimaryText,
                  ),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Password field ────────────────────────────────────
                Text(
                  'Password',
                  style: fonts.bodySmall()?.copyWith(
                    color: colors.colorPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: fonts.bodyMedium()?.copyWith(
                    color: colors.colorPrimaryText,
                  ),
                  decoration: _inputDecoration(
                    colors: colors,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.colorGray,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ── Login button ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.colorPrimary,
                      disabledBackgroundColor: colors.colorButtonDisable,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _login,
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
                            'Sign In',
                            style: fonts.bodyLarge()?.copyWith(
                              color: colors.colorWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Divider ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.colorDivider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: fonts.bodySmall()?.copyWith(
                          color: colors.colorSecondaryText,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.colorDivider)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Google button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.colorDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: colors.colorWhite,
                    ),
                    onPressed: isLoading ? null : _googleSignIn,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.g_mobiledata,
                        color: colors.colorPrimaryText,
                        size: 24,
                      ),
                    ),
                    label: Text(
                      'Sign in with Google',
                      style: fonts.bodyMedium()?.copyWith(
                        color: colors.colorPrimaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Register link ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: fonts.bodyMedium()?.copyWith(
                        color: colors.colorSecondaryText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(Routes.createAccount.name),
                      child: Text(
                        'Register',
                        style: fonts.bodyMedium()?.copyWith(
                          color: colors.colorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
