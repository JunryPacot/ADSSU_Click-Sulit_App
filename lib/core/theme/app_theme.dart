import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryDarkGreen,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryDarkGreen,
        onPrimary: AppColors.cardWhite,
        secondary: AppColors.midGreen,
        onSecondary: AppColors.cardWhite,
        tertiary: AppColors.accentGold,
        onTertiary: AppColors.textDark,
        error: AppColors.statusError,
        onError: AppColors.cardWhite,
        surface: AppColors.cardWhite,
        onSurface: AppColors.textDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.carlito(
          color: AppColors.mutedGray,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.carlito(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        labelMedium: GoogleFonts.carlito(
          color: AppColors.mutedGray,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.carlito(
          color: AppColors.mutedGray,
          fontSize: 10,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.merriweather(
          color: AppColors.primaryDarkGreen,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.mutedGray.withAlpha(180), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.statusError),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          foregroundColor: AppColors.cardWhite,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.carlito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: AppColors.shadowTint,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.textDark.withAlpha(10),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    const BoxShadow(
      color: Color(0x2E0E4D2B), // 18% dark green
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];
}
