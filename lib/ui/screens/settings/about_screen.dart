import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/ui/screens/settings/widgets/info_row.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.colorNavBarBg,
      appBar: AppBar(
        title: Text('About',
            style: TextStyle(
                color: colors.colorPrimaryText,
                fontWeight: FontWeight.bold)),
        backgroundColor: colors.colorNavBarBg,
        foregroundColor: colors.colorPrimaryText,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App icon + name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.colorPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 42),
                ),
                const SizedBox(height: 16),
                Text(
                  'My Teacher Wallet',
                  style: TextStyle(
                    color: colors.colorPrimaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                      color: colors.colorSecondaryText, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'My Teacher Wallet helps private tutors and teachers '
            'track monthly tuition fees, manage student payment records, '
            'and gain insights into their income — all in one simple app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.colorSecondaryText,
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),

          InfoRow(
              icon: Icons.build_outlined,
              label: 'Built with',
              value: 'Flutter & Dart',),
          InfoRow(
              icon: Icons.storage_outlined,
              label: 'Database',
              value: 'Isar (local)',),
          InfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: 'May 2026',),
        ],
      ),
    );
  }
}