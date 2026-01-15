import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    // PRIMARY (Teal)
    primary: AppColors.primary,
    onPrimary: Colors.white,

    primaryContainer: Color(0xFFB2DFDB),
    onPrimaryContainer: Color(0xFF00332D),

    // SECONDARY
    secondary: AppColors.secondary,
    onSecondary: Colors.white,

    secondaryContainer: Color(0xFFB2EBF2),
    onSecondaryContainer: Color(0xFF004D40),

    // SURFACE & BACKGROUND
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimary,

    // ERROR
    error: AppColors.error,
    onError: Colors.white,
  ),

  scaffoldBackgroundColor: AppColors.backgroundLight,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceLight,
    elevation: 0,
    centerTitle: true,
    foregroundColor: AppColors.textPrimary,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
  ),
);
