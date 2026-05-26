import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const MiniStat(
      {super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: context.appFonts.bodySmall()
                ?.copyWith(color: color.withOpacity(0.8), fontSize: 10),),
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