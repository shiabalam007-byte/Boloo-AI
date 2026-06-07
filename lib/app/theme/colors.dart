import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color brandPurple = Color(0xFF7C3AED);
  static const Color deepPurple = Color(0xFF5B21B6);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF2DD4BF);

  static const Color bg900 = Color(0xFF09090B);
  static const Color bg800 = Color(0xFF111113);
  static const Color bg700 = Color(0xFF1A1A1F);
  static const Color bg600 = Color(0xFF26262E);
  static const Color bg500 = Color(0xFF32323C);

  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF3F3F46);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color scoreExcellent = Color(0xFF10B981);
  static const Color scoreGood = Color(0xFFA78BFA);
  static const Color scoreFair = Color(0xFFF59E0B);
  static const Color scoreNeedsWork = Color(0xFFEF4444);

  static Color scoreColor(double score) {
    if (score >= 80) return scoreExcellent;
    if (score >= 60) return scoreGood;
    if (score >= 40) return scoreFair;
    return scoreNeedsWork;
  }
}
