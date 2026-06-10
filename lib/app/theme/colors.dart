import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color brandPurple = Color(0xFF7C3AED);
  static const Color deepPurple  = Color(0xFF5B21B6);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color teal        = Color(0xFF0D9488);
  static const Color tealLight   = Color(0xFF2DD4BF);

  // ── Blue (primary action in light theme) ───────────────────────────────────
  static const Color blue        = Color(0xFF2563EB);
  static const Color blueDark    = Color(0xFF1D4ED8);
  static const Color blueLight   = Color(0xFFEFF6FF);
  static const Color blueAccent  = Color(0xFF60A5FA);
  static const Color blueMid     = Color(0xFF93C5FD);

  // ── Light Theme Surfaces ───────────────────────────────────────────────────
  static const Color bgPage      = Color(0xFFF8F9FF);
  static const Color bgSurface   = Color(0xFFFFFFFF);
  static const Color bgSurface2  = Color(0xFFF1F5FE);
  static const Color bgSurface3  = Color(0xFFE8EEF9);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  // ── Light Theme Text ───────────────────────────────────────────────────────
  static const Color ink900 = Color(0xFF0F172A);
  static const Color ink700 = Color(0xFF1E293B);
  static const Color ink600 = Color(0xFF475569);
  static const Color ink400 = Color(0xFF94A3B8);
  static const Color ink200 = Color(0xFFCBD5E1);

  // ── Dark Theme Surfaces ────────────────────────────────────────────────────
  static const Color bg900 = Color(0xFF09090B);
  static const Color bg800 = Color(0xFF111113);
  static const Color bg700 = Color(0xFF1A1A1F);
  static const Color bg600 = Color(0xFF26262E);
  static const Color bg500 = Color(0xFF32323C);

  // ── Dark Theme Text (default, used by typography.dart) ────────────────────
  static const Color textPrimary   = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary  = Color(0xFF71717A);
  static const Color textDisabled  = Color(0xFF3F3F46);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Scores ─────────────────────────────────────────────────────────────────
  static const Color scoreExcellent = Color(0xFF10B981);
  static const Color scoreGood      = Color(0xFF2563EB);
  static const Color scoreFair      = Color(0xFFF59E0B);
  static const Color scoreNeedsWork = Color(0xFFEF4444);

  static Color scoreColor(double score) {
    if (score >= 80) return scoreExcellent;
    if (score >= 60) return scoreGood;
    if (score >= 40) return scoreFair;
    return scoreNeedsWork;
  }
}
