import 'package:flutter/material.dart';
import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/core/constants/app_constants.dart';

/// Standard app card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = AppConstants.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: context.cardBorder),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
