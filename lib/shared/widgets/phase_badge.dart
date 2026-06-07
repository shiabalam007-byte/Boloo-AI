import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';

class PhaseBadge extends StatelessWidget {
  const PhaseBadge({
    super.key,
    required this.phase,
  });

  final String phase;

  String get _label {
    switch (phase) {
      case 'foundation': return '🌱 Foundation';
      case 'professional': return '💼 Professional';
      case 'interview': return '🎯 Interview Mastery';
      case 'workplace': return '🏢 Workplace';
      case 'confidence': return '🔥 Confidence';
      default: return phase;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        _label,
        style: AppTypography.caption.copyWith(
          color: AppColors.lightPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GoalPill extends StatelessWidget {
  const GoalPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}

class DayBadge extends StatelessWidget {
  const DayBadge({
    super.key,
    required this.day,
    required this.currentDay,
  });

  final int day;
  final int currentDay;

  @override
  Widget build(BuildContext context) {
    final isCurrent = day == currentDay;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCurrent ? 'Day $day of 30' : 'Day $day',
        style: AppTypography.micro.copyWith(color: AppColors.lightPurple),
      ),
    );
  }
}
