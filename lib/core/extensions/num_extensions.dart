import 'package:flutter/material.dart';

/// Num extensions for common operations
extension NumExtension on num {
  /// Create SizedBox with this height
  SizedBox get heightBox => SizedBox(height: toDouble());

  /// Create SizedBox with this width
  SizedBox get widthBox => SizedBox(width: toDouble());

  /// Format duration from seconds
  String get durationFromSeconds {
    final minutes = (this / 60).floor();
    final seconds = (this % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
