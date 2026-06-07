import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.h3)),
        if (trailing != null) trailing!,
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }
    return content;
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.title,
    this.padding,
  });

  final String title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title.toUpperCase(),
      style: AppTypography.micro.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: text);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.sm,
      ),
      child: text,
    );
  }
}
