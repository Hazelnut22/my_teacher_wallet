import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_provider.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _navigate();
    });
  }

  void _navigate() {
    final authState = ref.read(authProvider);
    if (authState is UserAuthAuthenticated) {
      context.goNamed(Routes.root.name);
    }
    context.goNamed(Routes.login.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fonts = context.appFonts;

    return Scaffold(
      backgroundColor: colors.colorPrimary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.colorWhite.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.colorWhite,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'My Teacher Wallet',
                  style: fonts.headlineLarge()?.copyWith(
                    color: colors.colorWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track fees. Stay organised.',
                  style: fonts.bodyMedium()?.copyWith(
                    color: colors.colorWhite.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.colorWhite.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}