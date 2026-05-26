
import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const SummaryChip(
      {super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: context.appFonts.bodySmall()
                  ?.copyWith(color: color.withOpacity(0.8), fontSize: 11),),
            const SizedBox(height: 2),
            Text(value,
                style: context.appFonts.bodySmall()?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),),
          ],
        ),
      ),
    );
  }
}
