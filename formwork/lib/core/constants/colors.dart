import 'package:flutter/material.dart';

class AppColors {
  // ===== BASE COLORS =====
  static const Color primary = Color(0xFF00F0FF);
  static const Color secondary = Color(0xFF9D50FF);
  static const Color tertiary = Color(0xFF087DD1);

  // ===== DARK THEME =====
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF121826);
  static const Color darkCard = Color(0xFF1A1F2E);

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ===== LIGHT THEME =====
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFE5E7EB);

  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ===== STATUS COLORS =====
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ===== GRADIENTS =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF087DD1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF9D50FF), Color(0xFF6A11CB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== SPLASH SCREEN COLORS (MATERIAL 3 EQUIVALENTS) =====
  static const Color background = darkBackground;
  static const Color surfaceContainer = Color(0xFF1E2330);
  static const Color outlineVariant = Color(0xFF4B5563);
  static const Color onSurface = Colors.white;
  static const Color onSurfaceVariant = Color(0xFF9CA3AF);
  static const Color surfaceContainerHighest = Color(0xFF333A4D);
  static const Color primaryDim = Color(0xFF00B3BE);
  static const Color primaryContainer = Color(0xFF004D56);
}