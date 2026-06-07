import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  static const String _plus = 'PlusJakartaSans';
  static const String _mono = 'DMMonoMedium';

  static const TextStyle displayXL = TextStyle(
    fontFamily: _mono,
    fontSize: 40,
    height: 1.2,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayL = TextStyle(
    fontFamily: _plus,
    fontSize: 32,
    height: 1.25,
    letterSpacing: -0.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _plus,
    fontSize: 24,
    height: 1.33,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _plus,
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _plus,
    fontSize: 17,
    height: 1.41,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _plus,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _plus,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _plus,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: _plus,
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  static const TextStyle scoreNumber = TextStyle(
    fontFamily: _mono,
    fontSize: 36,
    height: 1.1,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _plus,
    fontSize: 15,
    height: 1.33,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
