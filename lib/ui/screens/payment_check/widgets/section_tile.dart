import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';
import 'package:my_teacher_wallet/core/app_fonts.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: context.appFonts.headlineSmall()?.copyWith(
            color: context.appColors.colorPrimaryText,
            fontWeight: FontWeight.bold,
          ),);
  }
}