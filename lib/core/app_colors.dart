import 'package:flutter/material.dart';

const colorPrimaryLight = Color(0xFF1672EC);
const colorPrimaryDark = Color(0xFF1672EC);

const colorPrimaryTextLight = Color(0xFF404454);
const colorPrimaryTextDark = Color(0xFFE9E9E9);

const colorSecondaryLight = Color(0xFFE1EDFB);
const colorSecondaryDark = Color(0xFF1E293B);

const colorSecondaryTextLight = Color(0xFF7C84A3);
const colorSecondaryTextDark = Color(0xFF94A3B8);

const colorHintLight = Color(0x80444444);
const colorHintDark = Color(0x80E9E9E9);

const colorSliderLight = Color(0x665B5B5B);
const colorSliderDark = Color(0x66DCDCDC);

const colorGray = Color(0xFF9E9E9E);

const colorButtonDisableLight = Color(0xffd0d0d0);
const colorButtonDisableDark = Color(0xff334155);

const colorEmptyListLight = Color(0x665B5B5B);
const colorEmptyListDark = Color(0x66DCDCDC);

const colorDividerLight = Color(0x1A000000);
const colorDividerDark = Color(0x1AFFFFFF);

const colorErrorLight = Color(0xFFF84646);
const colorErrorDark = Color(0xFFF84646);

const colorWhite = Color(0xFFFFFFFF);
const colorBlack = Color(0xFF0F172A);

const colorRedBox = Color(0xFFA53738);
const colorCardColorLight = Color(0xFFFFFFFF);
const colorCardColorDark = Color(0xFF1E293B);

const colorButtonBorder = Color(0xFFE4E4E7);
const colorNavBarBg = Color(0xFFf7fcfc);

class AppColors {
  final Color colorPrimary;
  final Color colorPrimaryText;
  final Color colorSecondary;
  final Color colorSecondaryText;
  final Color colorHint;
  final Color colorSlider;
  final Color colorButton;
  final Color colorButtonDisable;
  final Color colorEmptyList;
  final Color colorDivider;
  final Color colorGray;
  final Color colorWhite;
  final Color colorRedBox;
  final Color colorCardColor;
  final Color colorNavBarBg;

  AppColors({
    required this.colorPrimary,
    required this.colorPrimaryText,
    required this.colorSecondary, 
    required this.colorSecondaryText, 
    required this.colorHint,
    required this.colorSlider,
    required this.colorButton,
    required this.colorButtonDisable,
    required this.colorEmptyList,
    required this.colorDivider,
    required this.colorGray,
    required this.colorWhite,
    required this.colorRedBox,
    required this.colorCardColor,
    required this.colorNavBarBg,
  });
}

// --- Light Theme Implementation ---
final _appColorLight = AppColors(
  colorPrimary: colorPrimaryLight,
  colorPrimaryText: colorPrimaryTextLight,
  colorSecondary: colorSecondaryLight,
  colorSecondaryText: colorSecondaryTextLight,
  colorHint: colorHintLight,
  colorSlider: colorSliderLight,
  colorButton: colorPrimaryLight,
  colorButtonDisable: colorButtonDisableLight,
  colorEmptyList: colorEmptyListLight,
  colorDivider: colorDividerLight,
  colorGray: colorGray,
  colorWhite: colorWhite,
  colorRedBox: colorRedBox,
  colorCardColor: colorCardColorLight, 
  colorNavBarBg: colorNavBarBg,
);

// --- Dark Theme Implementation ---
final _appColorDark = AppColors(
  colorPrimary: colorPrimaryDark,
  colorPrimaryText: colorPrimaryTextDark,
  colorSecondary: colorSecondaryDark,
  colorSecondaryText: colorSecondaryTextDark,
  colorHint: colorHintDark,
  colorSlider: colorSliderDark,
  colorButton: colorPrimaryDark,
  colorButtonDisable: colorButtonDisableDark,
  colorEmptyList: colorEmptyListDark,
  colorDivider: colorDividerDark,
  colorGray: colorGray,
  colorWhite: colorWhite,
  colorRedBox: colorRedBox,
  colorCardColor: colorCardColorDark,
  colorNavBarBg: colorNavBarBg,
);

// --- Extensions ---
extension AppTheme on ThemeData {
  AppColors get appColors =>
      brightness == Brightness.light ? _appColorLight : _appColorDark;
}

extension ContextThemeExtension on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;
  AppColors get appColors => Theme.of(this).appColors;
}