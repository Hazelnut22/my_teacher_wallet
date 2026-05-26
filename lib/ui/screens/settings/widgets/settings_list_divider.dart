import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class SettingsListDivider extends StatelessWidget {
  const SettingsListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 58,
      endIndent: 0,
      color: context.appColors.colorDivider,
    );
  }
}