import 'package:flutter/material.dart';

/// Design tokens and color palette for Picky X (Memory Match)
class AppColors {
  AppColors._();

  // Backgrounds & Surface
  static const Color backgroundDark = Color(0xFF0F0E26);
  static const Color backgroundSurface = Color(0xFF1B1938);
  static const Color surfaceCard = Color(0xFF27244D);
  static const Color surfaceCardBack = Color(0xFF35306B);
  static const Color surfaceCardBorder = Color(0xFF4E478C);

  // Brand / Theme Colors
  static const Color primaryPurple = Color(0xFF7346F6);
  static const Color primaryPurpleLight = Color(0xFF9069F8);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color accentPink = Color(0xFFFF3366);
  static const Color accentYellow = Color(0xFFFFCC00);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentCyan = Color(0xFF00E5FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B0D9);
  static const Color textMuted = Color(0xFF7B75A6);

  // Status & Card Effects
  static const Color cardMatchedGlow = Color(0xFF00E676);
  static const Color cardRevealedBorder = Color(0xFFFFCC00);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141233),
      Color(0xFF0A091A),
    ],
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7A00),
      Color(0xFFFF3366),
    ],
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3E377D),
      Color(0xFF262153),
    ],
  );
}
