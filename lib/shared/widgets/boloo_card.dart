import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/dimensions.dart';

class BolooCard extends StatelessWidget {
  const BolooCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.radiusLg;
    final container = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color ?? AppColors.bg700,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.bg500),
      ),
      child: child,
    );

    if (onTap == null) return container;

    return GestureDetector(onTap: onTap, child: container);
  }
}

class BolooHighlightCard extends StatelessWidget {
  const BolooHighlightCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BolooCard(
      padding: padding,
      color: AppColors.brandPurple.withOpacity(0.15),
      borderColor: AppColors.brandPurple.withOpacity(0.4),
      onTap: onTap,
      child: child,
    );
  }
}
