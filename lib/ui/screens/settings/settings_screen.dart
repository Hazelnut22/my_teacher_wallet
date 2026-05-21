import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/core/services/app_config_service.dart';
import 'package:my_teacher_wallet/core/theme/theme_provider.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete all students, payment records, '
          'and reset the app to its initial state. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Reset',
              style: TextStyle(
                  color: colors.colorRedBox, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isar = ref.read(dbProvider);
      await isar.writeTxn(() async => isar.clear());
      await AppConfigService.reset();
      ref.read(paymentProvider.notifier).refresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Dark mode ───────────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            iconColor: colors.colorPrimary,
            title: 'Dark Mode',
            colors: colors,
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
              activeColor: colors.colorPrimary,
            ),
          ),

          _Divider(colors: colors),

          // ── Reset ───────────────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.delete_sweep_outlined,
            iconColor: colors.colorRedBox,
            title: 'Reset All Data',
            titleColor: colors.colorRedBox,
            colors: colors,
            showChevron: true,
            onTap: () => _confirmReset(context, ref),
          ),

          _Divider(colors: colors),

          // ── About ───────────────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.info_outline,
            iconColor: colors.colorPrimary,
            title: 'About',
            colors: colors,
            showChevron: true,
            onTap: () => context.pushNamed(Routes.about.name),
          ),

          _Divider(colors: colors),

          // ── Info ────────────────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.help_outline,
            iconColor: colors.colorPrimary,
            title: 'Help & Info',
            colors: colors,
            showChevron: true,
            onTap: () => context.pushNamed(Routes.appInfo.name),
          ),

          const SizedBox(height: 40),

          // ── Version ─────────────────────────────────────────────────────
          Center(
            child: Text(
              'My Teacher Wallet  •  v1.0.0',
              style: TextStyle(color: colors.colorGray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final AppColors colors;
  final bool showChevron;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.colors,
    this.titleColor,
    this.showChevron = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? colors.colorPrimaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(Icons.chevron_right,
                  color: colors.colorGray, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final AppColors colors;
  const _Divider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 58,
      endIndent: 0,
      color: colors.colorDivider,
    );
  }
}