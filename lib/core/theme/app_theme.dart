import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/theme_provider.dart';

/// App color scheme for both light and dark themes
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // Dark Theme Colors
  // ─────────────────────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF000000);
  static const darkTextPrimary = Color(0xFFECE4D6);
  static const darkTextSecondary = Color(0xFFB7A58B);
  static const darkGold = Color(0xFFBE8A52);
  static const darkCardBg = Color(0xFF0D0D0B);
  static const darkCardBorder = Color(0xFF1A1A16);

  // ─────────────────────────────────────────────────────────────────────────
  // Light Theme Colors
  // ─────────────────────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF8F6F3);
  static const lightTextPrimary = Color(0xFF1A1A16);
  static const lightTextSecondary = Color(0xFF6B5D4D);
  static const lightGold = Color(0xFFBE8A52);
  static const lightCardBg = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFE8E4DE);

  // Additional light theme colors
  static const lightSurface = Color(0xFFFFFBF7);
  static const lightDivider = Color(0xFFE0DCD6);

  // ─────────────────────────────────────────────────────────────────────────
  // Orb Colors - Voice Assistant
  // ─────────────────────────────────────────────────────────────────────────
  static const darkOrbBg = Color(0xFF0A0908);
  static const lightOrbBg = Color(0xFFFFFBF7);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic Colors (shared across themes)
  // ─────────────────────────────────────────────────────────────────────────
  static const missedRed = Color(0xFFD4614A);
  static const successGreen = Color(0xFF81C784);
  static const infoBlue = Color(0xFF64B5F6);
  static const flaggedRed = Color(0xFF8B2E2E);
  static const signOutRed = Color(0xFFD4614A);
  static const warningOrange = Color(0xFFFFB74D);
}

/// Extension to easily access theme colors from BuildContext
///
/// Usage: context.bg, context.textPrimary, context.gold, etc.
extension AppThemeExtension on BuildContext {
  bool get isDarkMode => ThemeProvider().isDark;

  // Background colors
  Color get bg => isDarkMode ? AppColors.darkBg : AppColors.lightBg;
  Color get cardBg => isDarkMode ? AppColors.darkCardBg : AppColors.lightCardBg;
  Color get cardBorder =>
      isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;

  // Text colors
  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  // Accent colors
  Color get gold => isDarkMode ? AppColors.darkGold : AppColors.lightGold;

  // Orb background color for voice assistant
  Color get orbBg => isDarkMode ? AppColors.darkOrbBg : AppColors.lightOrbBg;

  // Logo path based on theme
  String get logoPath =>
      isDarkMode ? 'assets/brand/logo.png' : 'assets/brand/logo2.png';
}

/// Dark theme data
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBg,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkGold,
    secondary: AppColors.darkGold,
    surface: AppColors.darkCardBg,
    onPrimary: AppColors.darkTextPrimary,
    onSecondary: AppColors.darkTextPrimary,
    onSurface: AppColors.darkTextPrimary,
  ),
  cardColor: AppColors.darkCardBg,
  dividerColor: AppColors.darkCardBorder,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
    bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
    bodySmall: TextStyle(color: AppColors.darkTextSecondary),
  ),
  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Add more theme customizations (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────
  // appBarTheme: const AppBarTheme(
  //   backgroundColor: AppColors.darkBg,
  //   foregroundColor: AppColors.darkTextPrimary,
  //   elevation: 0,
  // ),
  // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //   backgroundColor: AppColors.darkCardBg,
  //   selectedItemColor: AppColors.darkGold,
  //   unselectedItemColor: AppColors.darkTextSecondary,
  // ),
  // inputDecorationTheme: InputDecorationTheme(
  //   filled: true,
  //   fillColor: AppColors.darkCardBg,
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12),
  //     borderSide: const BorderSide(color: AppColors.darkCardBorder),
  //   ),
  // ),
);

/// Light theme data
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBg,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightGold,
    secondary: AppColors.lightGold,
    surface: AppColors.lightCardBg,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightTextPrimary,
  ),
  cardColor: AppColors.lightCardBg,
  dividerColor: AppColors.lightCardBorder,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
    bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
    bodySmall: TextStyle(color: AppColors.lightTextSecondary),
  ),
  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Add more theme customizations (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────
  // appBarTheme: const AppBarTheme(
  //   backgroundColor: AppColors.lightBg,
  //   foregroundColor: AppColors.lightTextPrimary,
  //   elevation: 0,
  // ),
  // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //   backgroundColor: AppColors.lightCardBg,
  //   selectedItemColor: AppColors.lightGold,
  //   unselectedItemColor: AppColors.lightTextSecondary,
  // ),
  // inputDecorationTheme: InputDecorationTheme(
  //   filled: true,
  //   fillColor: AppColors.lightCardBg,
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12),
  //     borderSide: const BorderSide(color: AppColors.lightCardBorder),
  //   ),
  // ),
);
