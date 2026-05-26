import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({super.key, 
    required this.icon,
    required this.iconColor,
    required this.title,
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
                style: context.appFonts.titleLarge()?.copyWith(
                  color: titleColor ?? context.appColors.colorPrimaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(Icons.chevron_right,
                  color: context.appColors.colorGray, size: 20),
          ],
        ),
      ),
    );
  }
}