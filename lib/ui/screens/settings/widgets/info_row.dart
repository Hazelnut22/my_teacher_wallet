import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({super.key, 
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: context.appColors.colorPrimary, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: context.appColors.colorSecondaryText, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: context.appColors.colorPrimaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}