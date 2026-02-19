import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION IMPORTS (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:nox_ai/core/constants/app_constants.dart';

/// Theme mode notifier for app-wide theme switching
///
/// Uses singleton pattern to maintain single source of truth for theme state.
/// In production, consider replacing with Riverpod StateNotifier for better
/// dependency injection and testability.
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Persist theme preference (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────
  // Future<void> loadThemePreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isDarkMode = prefs.getBool(AppConstants.themePreferenceKey) ?? true;
  //   _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  //   notifyListeners();
  // }
  //
  // Future<void> saveThemePreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(AppConstants.themePreferenceKey, isDark);
  // }
}
