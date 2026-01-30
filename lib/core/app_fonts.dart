import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_colors.dart';

enum FontFamily {
  poppins('Poppins');

  const FontFamily(this.value);

  final String value;
}

class AppFontStyle {
  const AppFontStyle(this.context);

  final BuildContext context;

  TextStyle pure() {
    return TextStyle(
      fontFamily: FontFamily.poppins.value,
    );
  }

  TextStyle? displayLarge() {
    return Theme.of(context).textTheme.displayLarge?.copyWith(
          fontFamily: FontFamily.poppins.value,
        );
  }

  TextStyle? displayMedium() {
    return Theme.of(context).textTheme.displayMedium?.copyWith(
          fontFamily: FontFamily.poppins.value,
        );
  }

  TextStyle? displaySmall() {
    return Theme.of(context).textTheme.displaySmall?.copyWith(
          fontFamily:  FontFamily.poppins.value,
        );
  }

  TextStyle? headlineLarge() {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontFamily: FontFamily.poppins.value,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        );
  }

  TextStyle? headlineMedium() {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontFamily: FontFamily.poppins.value,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        );
  }

  TextStyle? headlineSmall() {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFamily: FontFamily.poppins.value,
          fontSize: 16,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        );
  }

  TextStyle? appBarTitle() {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontFamily: FontFamily.poppins.value,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Colors.white
    );
  }

  TextStyle? titleLarge() {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: FontFamily.poppins.value,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        );
  }

  TextStyle? titleMedium() {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
        fontFamily: FontFamily.poppins.value,
        height: 1.5,
        color: Colors.white);
  }

  TextStyle? titleSmall() {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontFamily: FontFamily.poppins.value,
        );
  }

  TextStyle? labelLarge() {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
        fontFamily: FontFamily.poppins.value,
        color: context.appColors.colorWhite,
        fontWeight: FontWeight.w400,
        fontSize: 18);
  }

  TextStyle? labelMedium() {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
        fontFamily: FontFamily.poppins.value,
        color: context.appColors.colorWhite,
        fontWeight: FontWeight.w400,
        fontSize: 14);
  }

  TextStyle? labelSmall() {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontFamily: FontFamily.poppins.value,
        );
  }

  TextStyle? bodyLarge() {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontFamily: FontFamily.poppins.value,
        fontWeight: FontWeight.w400,
        fontSize: 16
        );
  }

  TextStyle? bodyMedium() {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily:FontFamily.poppins.value,
        );
  }

  TextStyle? bodySmall() {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: FontFamily.poppins.value,
        );
  }
}
