import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';

class ScorePill extends StatelessWidget {
  const ScorePill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label:${value.toInt()}',
        style: AppTypography.micro.copyWith(
          color: color,
          fontFamily: 'DMMonoMedium',
        ),
      ),
    );
  }
}

class ScoreChip extends StatelessWidget {
  const ScoreChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${value.toInt()}',
        style: AppTypography.caption.copyWith(
          color: color,
          fontFamily: 'DMMonoMedium',
        ),
      ),
    );
  }
}

class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 100.0,
  });

  final String label;
  final double value;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(value);
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label, style: AppTypography.body),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.bg500,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${value.toInt()}',
            style: AppTypography.caption.copyWith(
              color: color,
              fontFamily: 'DMMonoMedium',
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
