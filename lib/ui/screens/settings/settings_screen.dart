import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';
import 'package:my_teacher_wallet/core/route/routes.dart';
import 'package:my_teacher_wallet/core/services/shared_preference_service.dart';
import 'package:my_teacher_wallet/core/theme/theme_provider.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/settings/widgets/settings_list_divider.dart';
import 'package:my_teacher_wallet/ui/screens/settings/widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final fonts = context.appFonts;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset All Data',
          style: fonts.headlineSmall()?.copyWith(
            color: colors.colorPrimaryText,
          ),
        ),
        content: Text(
          'This will permanently delete all students, payment records, '
          'and reset the app to its initial state. This cannot be undone.',
          style: fonts.bodyMedium()?.copyWith(color: colors.colorPrimaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: fonts.bodyMedium()?.copyWith(
                color: colors.colorSecondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Reset',
              style: fonts.bodyMedium()?.copyWith(
                color: colors.colorRedBox,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isar = ref.read(dbProvider);
      await isar.writeTxn(() async => isar.clear());
      await SharedPreferenceService.reset();
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
    final fonts = context.appFonts;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: fonts.appBarTitle()?.copyWith(color: colors.colorPrimaryText),
        ),
        backgroundColor: colors.colorNavBarBg,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Dark mode ───────────────────────────────────────────────────
          SettingsTile(
            icon: Icons.dark_mode_outlined,
            iconColor: colors.colorPrimary,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              activeColor: colors.colorPrimary,
            ),
          ),

          SettingsListDivider(),

          // ── Reset ───────────────────────────────────────────────────────
          SettingsTile(
            icon: Icons.delete_sweep_outlined,
            iconColor: colors.colorRedBox,
            title: 'Reset All Data',
            titleColor: colors.colorRedBox,
            showChevron: true,
            onTap: () => _confirmReset(context, ref),
          ),

          SettingsListDivider(),

          // ── About ───────────────────────────────────────────────────────
          SettingsTile(
            icon: Icons.info_outline,
            iconColor: colors.colorPrimary,
            title: 'About',
            showChevron: true,
            onTap: () => context.pushNamed(Routes.about.name),
          ),

          SettingsListDivider(),

          // ── Info ────────────────────────────────────────────────────────
          SettingsTile(
            icon: Icons.help_outline,
            iconColor: colors.colorPrimary,
            title: 'Help & Info',
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
