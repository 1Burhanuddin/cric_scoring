import 'package:flutter/material.dart';

import '../text/app_text_style.dart';

// CricHeros brand palette
// Primary Red #E21C28 / Dark Red #B01020, Teal accent #18958F / Dark Teal #0F6B67.
const primaryLightColor = Color(0xFFE21C28);
const primaryDarkColor = Color(0xFFE21C28);

const darkPrimaryColor = Color(0xFFB01020);

const primaryVariantLightColor = Color(0x4DE21C28);
const primaryVariantDarkColor = Color(0x66E21C28);

const secondaryColor = Color(0xFF18958F);
const darkSecondaryColor = Color(0xFF0F6B67);

// Dark navy used behind scorecards / share cards.
const scoreCardColor = Color(0xFF1A1A2E);

const containerHighLightColor = Color(0x14191919);
const containerNormalLightColor = Color(0x0F191919);
const containerLowLightColor = Color(0x0A191919);

const containerHighDarkColor = Color(0x3DD1E1ED);
const containerNormalDarkColor = Color(0x29D1E1ED);
const containerLowDarkColor = Color(0x14D1E1ED);

const textPrimaryLightColor = Color(0xFF191919);
const textSecondaryLightColor = Color(0xFF9E9E9E);
const textDisabledLightColor = Color(0x66000000);

const textPrimaryDarkColor = Color(0xFFFFFFFF);
const textSecondaryDarkColor = Color(0xFF9E9E9E);
const textDisabledDarkColor = Color(0x99FFFFFF);

const outlineLightColor = Color(0x14000000);
const outlineDarkColor = Color(0x1FFFFFFF);

const backgroundLightColor = Color(0xFFF5F5F5);
// True near-black + flat gray surface ramp (matches the reference app's
// #000000 / #1C1C1E dark theme) rather than the previous navy-tinted dark
// (#1A1A2E / #16213E) — brand red/teal accents are unchanged, this only
// moves the neutral background/surface tones.
const backgroundDarkColor = Color(0xFF000000);

const surfaceLightColor = Color(0xFFFFFFFF);
const surfaceDarkColor = Color(0xFF1C1C1E);

const awarenessAlertColor = Color(0xFFC62828);
const awarenessPositiveColor = Color(0xFF4CAF50);
const awarenessWarningColor = Color(0xFFF9A825);
const awarenessInfoColor = Color(0xFF0D47A1);

final ThemeData _materialLightTheme = ThemeData.light(useMaterial3: true);
final ThemeData _materialDarkTheme = ThemeData.dark(useMaterial3: true);

final ThemeData materialThemeDataLight = _materialLightTheme.copyWith(
  primaryColor: primaryLightColor,
  dividerColor: outlineLightColor,
  datePickerTheme: _materialLightTheme.datePickerTheme.copyWith(
    backgroundColor: surfaceLightColor,
    headerForegroundColor: textPrimaryLightColor,
    dividerColor: outlineLightColor,
    // DatePickerThemeData.copyWith still takes the legacy InputDecorationTheme
    // type even though its own getter now returns InputDecorationThemeData, so
    // this can't chain off that getter's .copyWith - build a fresh one instead.
    inputDecorationTheme: const InputDecorationTheme(
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: awarenessAlertColor)),
    ),
  ),
  timePickerTheme: _materialLightTheme.timePickerTheme.copyWith(
    backgroundColor: surfaceLightColor,
    dialBackgroundColor: containerLowLightColor,
    dayPeriodColor: primaryLightColor,
    hourMinuteColor: containerLowLightColor,
    inputDecorationTheme: const InputDecorationTheme(
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: awarenessAlertColor)),
    ),
  ),
  colorScheme: _materialLightTheme.colorScheme.copyWith(
    primary: primaryLightColor,
    secondary: secondaryColor,
    surface: surfaceLightColor,
    onPrimary: textPrimaryDarkColor,
    onSecondary: textPrimaryDarkColor,
    onSurface: textPrimaryLightColor,
  ),
  scaffoldBackgroundColor: backgroundLightColor,
  appBarTheme: _materialLightTheme.appBarTheme.copyWith(
    backgroundColor: primaryLightColor,
    foregroundColor: textPrimaryDarkColor,
    surfaceTintColor: primaryLightColor,
    iconTheme: const IconThemeData(color: textPrimaryDarkColor),
    titleTextStyle: _materialLightTheme.appBarTheme.titleTextStyle?.copyWith(
      color: textPrimaryDarkColor,
      fontFamily: AppTextStyle.poppinsFontFamily,
      package: 'style',
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryLightColor,
    foregroundColor: textPrimaryDarkColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryLightColor,
      foregroundColor: textPrimaryDarkColor,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryLightColor),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(foregroundColor: primaryLightColor),
  ),
  bottomNavigationBarTheme: _materialLightTheme.bottomNavigationBarTheme
      .copyWith(
    selectedItemColor: primaryLightColor,
    unselectedItemColor: textSecondaryLightColor,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? secondaryColor : null),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? secondaryColor.withValues(alpha: 0.5)
            : null),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? secondaryColor : null),
  ),
);

final ThemeData materialThemeDataDark = _materialDarkTheme.copyWith(
  primaryColor: primaryDarkColor,
  dividerColor: outlineDarkColor,
  datePickerTheme: _materialDarkTheme.datePickerTheme.copyWith(
    backgroundColor: surfaceDarkColor,
    headerForegroundColor: textPrimaryDarkColor,
    dividerColor: outlineDarkColor,
    inputDecorationTheme: const InputDecorationTheme(
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: awarenessAlertColor)),
    ),
  ),
  timePickerTheme: _materialDarkTheme.timePickerTheme.copyWith(
    backgroundColor: surfaceDarkColor,
    dialBackgroundColor: containerLowDarkColor,
    dayPeriodColor: primaryDarkColor,
    hourMinuteColor: containerLowDarkColor,
    inputDecorationTheme: const InputDecorationTheme(
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: awarenessAlertColor)),
    ),
  ),
  colorScheme: _materialDarkTheme.colorScheme.copyWith(
    primary: primaryDarkColor,
    secondary: secondaryColor,
    surface: surfaceDarkColor,
    onPrimary: textPrimaryDarkColor,
    onSecondary: textPrimaryDarkColor,
    onSurface: textPrimaryDarkColor,
  ),
  scaffoldBackgroundColor: backgroundDarkColor,
  appBarTheme: _materialDarkTheme.appBarTheme.copyWith(
    backgroundColor: primaryDarkColor,
    foregroundColor: textPrimaryDarkColor,
    surfaceTintColor: primaryDarkColor,
    iconTheme: const IconThemeData(color: textPrimaryDarkColor),
    titleTextStyle: _materialDarkTheme.appBarTheme.titleTextStyle?.copyWith(
      color: textPrimaryDarkColor,
      fontFamily: AppTextStyle.poppinsFontFamily,
      package: 'style',
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryDarkColor,
    foregroundColor: textPrimaryDarkColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryDarkColor,
      foregroundColor: textPrimaryDarkColor,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryDarkColor),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(foregroundColor: primaryDarkColor),
  ),
  bottomNavigationBarTheme: _materialDarkTheme.bottomNavigationBarTheme.copyWith(
    selectedItemColor: primaryDarkColor,
    unselectedItemColor: textSecondaryDarkColor,
    backgroundColor: surfaceDarkColor,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? secondaryColor : null),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? secondaryColor.withValues(alpha: 0.5)
            : null),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? secondaryColor : null),
  ),
);

class AppColorScheme {
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color surface;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textInversePrimary;
  final Color textInverseSecondary;
  final Color textInverseDisabled;
  final Color containerHigh;
  final Color containerNormal;
  final Color containerLow;
  final Color positive;
  final Color alert;
  final Color warning;
  final Color info;
  final Color onPrimary;
  final Color onSecondary;
  final Color onDisabled;
  final ThemeMode themeMode;

  AppColorScheme({
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.surface,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textInversePrimary,
    required this.textInverseSecondary,
    required this.textInverseDisabled,
    required this.containerHigh,
    required this.containerNormal,
    required this.containerLow,
    required this.positive,
    required this.alert,
    required this.warning,
    required this.info,
    required this.onPrimary,
    required this.onSecondary,
    required this.onDisabled,
    required this.themeMode,
  });

  Color get containerNormalOnSurface =>
      Color.alphaBlend(containerNormal, surface);

  Color get containerHighOnSurface => Color.alphaBlend(containerHigh, surface);

  Color get containerLowOnSurface => Color.alphaBlend(containerLow, surface);

  Color get primaryVariantOnSurface =>
      Color.alphaBlend(primaryVariant, surface);
}

final appColorSchemeLight = AppColorScheme(
  primary: primaryLightColor,
  primaryVariant: primaryVariantLightColor,
  secondary: secondaryColor,
  surface: surfaceLightColor,
  outline: outlineLightColor,
  textPrimary: textPrimaryLightColor,
  textSecondary: textSecondaryLightColor,
  textDisabled: textDisabledLightColor,
  textInversePrimary: textPrimaryDarkColor,
  textInverseSecondary: textSecondaryDarkColor,
  textInverseDisabled: textDisabledDarkColor,
  containerHigh: containerHighLightColor,
  containerNormal: containerNormalLightColor,
  containerLow: containerLowLightColor,
  positive: awarenessPositiveColor,
  alert: awarenessAlertColor,
  warning: awarenessWarningColor,
  info: awarenessInfoColor,
  onPrimary: textPrimaryDarkColor,
  onSecondary: textSecondaryDarkColor,
  onDisabled: textDisabledLightColor,
  themeMode: ThemeMode.light,
);

final appColorSchemeDark = AppColorScheme(
  primary: primaryDarkColor,
  primaryVariant: primaryVariantDarkColor,
  secondary: secondaryColor,
  surface: surfaceDarkColor,
  outline: outlineDarkColor,
  textPrimary: textPrimaryDarkColor,
  textSecondary: textSecondaryDarkColor,
  textDisabled: textDisabledDarkColor,
  textInversePrimary: textPrimaryLightColor,
  textInverseSecondary: textSecondaryLightColor,
  textInverseDisabled: textDisabledLightColor,
  containerHigh: containerHighDarkColor,
  containerNormal: containerNormalDarkColor,
  containerLow: containerLowDarkColor,
  positive: awarenessPositiveColor,
  alert: awarenessAlertColor,
  warning: awarenessWarningColor,
  info: awarenessInfoColor,
  onPrimary: textPrimaryLightColor,
  onSecondary: textSecondaryDarkColor,
  onDisabled: textDisabledLightColor,
  themeMode: ThemeMode.dark,
);
