/// Application-wide constants
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
  // API Configuration
  // For local dev on Android emulator use: http://10.0.2.2:8010
  // For real device on same Wi-Fi use: http://<your-machine-ip>:8010
  // For production use: https://api.yourdomain.com
  // ─────────────────────────────────────────────────────────────────────────
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://56.228.26.195:8010',
  );
  static const String apiVersion = 'api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String callsEndpoint = '/calls';
  static const String tasksEndpoint = '/tasks';
  static const String memoriesEndpoint = '/memory';
  static const String calendarEndpoint = '/calendar';
  static const String approvalsEndpoint = '/approvals';
  static const String dailyBriefEndpoint = '/daily-brief';
  static const String preferencesEndpoint = '/preferences';
  static const String googleEndpoint = '/google';

  // Google Sign-In: Web client ID (used as serverClientId for auth code exchange)
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '1076376370479-iarepk0o00lqqc5ghl1k4kc8arlmc6uk.apps.googleusercontent.com',
  );

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String phoneKey = 'phone_number';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themePreferenceKey = 'theme_preference';
}
