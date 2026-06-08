import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';

enum _ButtonVariant { primary, secondary, ghost }

class BoolooButton extends StatelessWidget {
  const BoolooButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.prefixIcon,
    this.isLoading = false,
    this.isDestructive = false,
    super.key,
  });

  factory BoolooButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    bool isLoading = false,
  }) =>
      BoolooButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.primary,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        isLoading: isLoading,
      );

  factory BoolooButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    bool isLoading = false,
  }) =>
      BoolooButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.secondary,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        isLoading: isLoading,
      );

  factory BoolooButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    bool isLoading = false,
    bool isDestructive = false,
  }) =>
      BoolooButton._(
        key: key,
        label: label,
        variant: _ButtonVariant.ghost,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        isLoading: isLoading,
        isDestructive: isDestructive,
      );

  final String label;
  final _ButtonVariant variant;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;
  final bool isLoading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: switch (variant) {
        _ButtonVariant.primary => ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: disabled
                  ? AppColors.blue.withOpacity(0.4)
                  : AppColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              elevation: 0,
            ),
            child: _buildContent(Colors.white),
          ),
        _ButtonVariant.secondary => OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.borderMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            child: _buildContent(AppColors.textPrimary),
          ),
        _ButtonVariant.ghost => TextButton(
            onPressed: disabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            child: _buildContent(isDestructive ? AppColors.error : AppColors.textSecondary),
          ),
      },
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.buttonLabel.copyWith(color: color),
        ),
      ],
    );
  }
}
