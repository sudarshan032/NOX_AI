import 'package:flutter/material.dart';
import 'package:nox_ai/core/theme/app_theme.dart';

/// Standard loading indicator
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? context.gold),
      ),
    );
  }
}
