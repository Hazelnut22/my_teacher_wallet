import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

class CustomInputTextField extends StatelessWidget {
  const CustomInputTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isNumber = false,
  });

  final String label;
  final TextEditingController controller;
  final bool isNumber;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: context.appColors.colorPrimaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.appColors.colorHint),
        filled: true,
        fillColor: context.appColors.colorWhite,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.colorDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.colorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.colorRedBox),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.colorRedBox, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Required" : null,
    );
  }
}