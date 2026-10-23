import 'package:flutter/material.dart';

import '../constants.dart';

ThemeData buildAppTheme() {
  final TextTheme baseText = ThemeData.dark().textTheme;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      secondary: AppColors.focus,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: AppDimens.appBarElevation,
      centerTitle: false,
    ),
    textTheme: baseText.copyWith(
      bodyLarge: const TextStyle(
        fontSize: AppDimens.bodyText,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: AppDimens.bodyText,
        color: AppColors.textSecondary,
      ),
      titleLarge: const TextStyle(
        fontSize: AppDimens.titleText,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: const TextStyle(
        fontSize: AppDimens.titleText,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size.fromHeight(AppDimens.minTouchTarget),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: AppDimens.buttonVerticalPadding,
            horizontal: AppDimens.buttonHorizontalPadding,
          ),
        ),
        backgroundColor:
            const WidgetStatePropertyAll<Color>(AppColors.accent),
        foregroundColor:
            const WidgetStatePropertyAll<Color>(AppColors.background),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(
            fontSize: AppDimens.bodyText,
            fontWeight: FontWeight.w700,
          ),
        ),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size.fromHeight(AppDimens.minTouchTarget),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: AppDimens.buttonVerticalPadding,
            horizontal: AppDimens.buttonHorizontalPadding,
          ),
        ),
        foregroundColor:
            const WidgetStatePropertyAll<Color>(AppColors.textPrimary),
        side: const WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: AppColors.accent),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: AppDimens.bodyText),
        ),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimens.bodyText,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppDimens.bodyText,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        borderSide: const BorderSide(color: AppColors.focus),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimens.bodyText,
      ),
    ),
  );
}
