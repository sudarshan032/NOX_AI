import 'package:flutter/material.dart';

/// BuildContext extensions for common operations
///
/// Provides convenient access to theme, media query, and navigation from context.
extension ContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  /// Pop navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  /// Push replacement named route
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(
        this,
      ).pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);
}
