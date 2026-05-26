import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const StatCard({super.key, 
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: context.appFonts.bodySmall()
                ?.copyWith(color: color.withOpacity(0.8)),),
          const SizedBox(height: 4),
          Text(value,
              style: context.appFonts.bodySmall()?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),),
        ],
      ),
    );
  }
}