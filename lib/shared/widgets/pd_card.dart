import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Standard dark card with border, matching frontend `Card` component
class PDCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;

  const PDCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
