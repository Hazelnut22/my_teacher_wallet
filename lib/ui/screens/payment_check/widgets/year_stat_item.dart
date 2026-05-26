import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class YearStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const YearStatItem(
      {super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: context.appFonts.bodySmall()?.copyWith(
              color: context.appColors.colorSecondaryText,
              fontSize: 11,
            ),),
          const SizedBox(height: 4),
          Text(value,
              style: context.appFonts.bodySmall()?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),),
        ],
      ),
    );
  }
}
