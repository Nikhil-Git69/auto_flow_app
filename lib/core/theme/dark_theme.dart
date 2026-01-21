import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // primary
    primary: AppColors.primaryDark,
    onPrimary: Color(0xFF00332D),

    primaryContainer: AppColors.primaryVariant,
    onPrimaryContainer: Colors.white,

    // secondary
    secondary: AppColors.secondaryDark,
    onSecondary: Color(0xFF00363A),

    secondaryContainer: AppColors.secondaryVariant,
    onSecondaryContainer: Colors.white,

    // surafce
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,

    // ERROR
    error: AppColors.error,
    onError: Colors.white,
  ),

  scaffoldBackgroundColor: AppColors.backgroundDark,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
    bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
  ),
);
