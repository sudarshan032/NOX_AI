/// Application string constants
///
/// Centralized string definitions for UI labels, messages, and text.
/// For internationalization, replace with intl package or flutter_localizations.
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Demo App';
  static const String appVersion = '1.0.0';

  // Common Labels
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';

  // Navigation Labels
  static const String home = 'Home';
  static const String tasks = 'Tasks';
  static const String calls = 'Calls';
  static const String calendar = 'Calendar';
  static const String profile = 'Profile';
  static const String memories = 'Memories';
  static const String notifications = 'Notifications';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';

  // Empty States
  static const String noTasks = 'No tasks yet';
  static const String noCalls = 'No calls yet';
  static const String noMemories = 'No memories yet';
  static const String noNotifications = 'No notifications yet';

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Add more strings as needed
  // ─────────────────────────────────────────────────────────────────────────
}
