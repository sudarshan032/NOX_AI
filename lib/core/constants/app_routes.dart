/// Route names for navigation
///
/// Centralized route definitions for type-safe navigation.
/// Used with Navigator 1.0 or GoRouter in production.
class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String onboardingHowItWorks = '/onboarding/how-it-works';
  static const String onboardingMeetAgent = '/onboarding/meet-agent';
  static const String onboardingStayInControl = '/onboarding/stay-in-control';

  // Authentication
  static const String createAccount = '/auth/create-account';
  static const String emailVerification = '/auth/email-verification';
  static const String otpVerification = '/auth/otp-verification';

  // Main App
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String callLogs = '/calls';
  static const String callDetail = '/calls/:id';
  static const String memories = '/memories';
  static const String calendar = '/calendar';
  static const String notifications = '/notifications';
  static const String profileSettings = '/profile/settings';
}
