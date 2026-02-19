/// String extensions for common operations
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize each word
  String get titleCase => split(' ').map((word) => word.capitalized).join(' ');

  /// Check if string is valid email
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Check if string is valid phone
  bool get isValidPhone => RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(this);

  /// Truncate string with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}
