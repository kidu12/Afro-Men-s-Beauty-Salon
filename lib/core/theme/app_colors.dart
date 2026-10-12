import 'package:flutter/material.dart';

class AppColors {
  // Deep Luxury Backgrounds
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF16171B);
  static const Color surfaceElevated = Color(0xFF1E2026);
  static const Color surfaceBorder = Color(0xFF282A33);
  static const Color surfaceHighlight = Color(0xFF2C2F3B);

  // Brand Gold Accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF997D29);
  static const Color goldMuted = Color(0x33D4AF37);

  // Typography Palette
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA0A0AB);
  static const Color textMuted = Color(0xFF6B6B76);
  static const Color textInverse = Color(0xFF0D0D0F);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5C05B), Color(0xFFB88E23)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1C1D22), Color(0xFF141518)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
