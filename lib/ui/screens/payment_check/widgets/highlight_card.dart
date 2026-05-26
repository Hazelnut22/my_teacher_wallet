import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const HighlightCard({
    super.key, 
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: context.appFonts.bodySmall()?.copyWith(
                    color: color.withOpacity(0.8),
                    fontSize: 11,
                  ),),
                Text(value,
                    style: context.appFonts.titleLarge()?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),),
                Text(sub,
                    style: context.appFonts.bodySmall()?.copyWith(
                    color: context.appColors.colorSecondaryText,
                    fontSize: 11,
                  ),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}