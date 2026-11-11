import 'package:flutter/material.dart';

/// Single source of truth for all application colors.
/// Rules:
/// - Dark green #0E4D2B
/// - Mid green #2E7D4F
/// - Gold #C9A227 (highlights only: Featured tags, center Post button, ratings, DONATE tags)
/// - Text #1F2A22
/// - Muted gray #5E6B62
/// - Background #F3F9F5
/// - White cards (16px radius, soft shadow)
/// Never hardcode colors elsewhere.
class AppColors {
  AppColors._();

  static const Color primaryDarkGreen = Color(0xFF0E4D2B);
  static const Color midGreen = Color(0xFF2E7D4F);
  static const Color accentGold = Color(0xFFC9A227);
  static const Color textDark = Color(0xFF1F2A22);
  static const Color mutedGray = Color(0xFF5E6B62);
  static const Color background = Color(0xFFF3F9F5);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Semantic / helper tints
  static const Color paleGreen = Color(0xFFDCECE1);
  static const Color lightMint = Color(0xFFE9F7EC);
  static const Color statusError = Color(0xFFBA1A1A);
  static const Color statusSuccess = Color(0xFF1E7E34);
  static const Color borderLight = Color(0x1F5E6B62); // 12% opacity
  static const Color shadowTint = Color(0x0F0E4D2B); // 6% dark green tint
}

