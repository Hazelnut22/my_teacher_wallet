import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/services/app_config_service.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Text('Reset',
                style: TextStyle(
                    color: colors.colorRedBox,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isar = ref.read(dbProvider);
      await isar.writeTxn(() async {
        await isar.clear();
      });
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
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ─────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance', colors: colors),
          _SettingsTile(
            colors: colors,
            icon: Icons.dark_mode_outlined,
            iconColor: colors.colorPrimary,
            title: 'Dark Mode',
            subtitle: 'Coming soon',
            trailing: Switch(
              value: false,
              onChanged: null, // placeholder
              activeColor: colors.colorPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // ── Data ───────────────────────────────────────────────────────
          _SectionHeader(label: 'Data', colors: colors),
          _SettingsTile(
            colors: colors,
            icon: Icons.delete_sweep_outlined,
            iconColor: colors.colorRedBox,
            title: 'Reset All Data',
            subtitle: 'Delete all students and payment records',
            onTap: () => _confirmReset(context, ref),
          ),

          const SizedBox(height: 16),

          // ── App ────────────────────────────────────────────────────────
          _SectionHeader(label: 'App', colors: colors),
          _SettingsTile(
            colors: colors,
            icon: Icons.info_outline,
            iconColor: colors.colorPrimary,
            title: 'About',
            subtitle: 'Coming soon',
            onTap: null,
          ),
          const SizedBox(height: 1),
          _SettingsTile(
            colors: colors,
            icon: Icons.help_outline,
            iconColor: colors.colorPrimary,
            title: 'Info & Help',
            subtitle: 'Coming soon',
            onTap: null,
          ),

          const SizedBox(height: 32),

          // ── App version ────────────────────────────────────────────────
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

class _SectionHeader extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _SectionHeader({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colors.colorSecondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.colorDivider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: colors.colorPrimaryText, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style:
              TextStyle(color: colors.colorSecondaryText, fontSize: 12),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right, color: colors.colorGray)
                : null),
      ),
    );
  }
}