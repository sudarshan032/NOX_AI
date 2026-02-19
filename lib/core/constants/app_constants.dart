/// Application-wide constants
///
/// This file contains general constant values used throughout the app.
/// For specific constants, see:
/// - [AppRoutes] for navigation routes
/// - [AppStrings] for UI text
/// - [AppAssets] for asset paths
/// - [AppColors] for color definitions (in theme folder)

class AppConstants {
  AppConstants._();

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Layout Constants
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: API Configuration (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────
  // static const String baseUrl = 'https://api.yourapp.com';
  // static const String apiVersion = 'v1';
  // static const Duration apiTimeout = Duration(seconds: 30);
  //
  // // API Endpoints
  // static const String authEndpoint = '/auth';
  // static const String usersEndpoint = '/users';
  // static const String callsEndpoint = '/calls';
  // static const String tasksEndpoint = '/tasks';
  // static const String memoriesEndpoint = '/memories';
  // static const String calendarEndpoint = '/calendar';
  // static const String notificationsEndpoint = '/notifications';

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Storage Keys (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────
  // static const String authTokenKey = 'auth_token';
  // static const String refreshTokenKey = 'refresh_token';
  // static const String userDataKey = 'user_data';
  // static const String themePreferenceKey = 'theme_preference';
  // static const String onboardingCompleteKey = 'onboarding_complete';
}
