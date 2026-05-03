import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Defines the single dark ThemeData used throughout the app.
/// Light-surface sections are painted via custom widget backgrounds,
/// not a separate MaterialTheme, keeping things simple and consistent.
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.colorBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.colorPrimary,
        secondary: AppConstants.colorAccent,
        tertiary: AppConstants.colorEmerald,
        surface: AppConstants.colorCard,
        onPrimary: AppConstants.colorWhite,
        onSecondary: AppConstants.colorWhite,
        onSurface: AppConstants.colorWhite,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppConstants.colorWhite,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppConstants.colorWhite),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.colorCard,
        selectedItemColor: AppConstants.colorPrimary,
        unselectedItemColor: AppConstants.colorBodyText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.colorCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppConstants.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppConstants.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(
            color: AppConstants.colorPrimary,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.manrope(
          color: AppConstants.colorBodyText,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.manrope(
          color: AppConstants.colorBodyText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.colorPrimary,
          foregroundColor: AppConstants.colorWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXl,
            vertical: AppConstants.spacingMd,
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppConstants.colorCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: const BorderSide(color: AppConstants.colorBorder),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppConstants.colorBorder,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display sizes – hero headings
      displayLarge: GoogleFonts.manrope(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: AppConstants.colorWhite,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppConstants.colorWhite,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppConstants.colorWhite,
        height: 1.2,
      ),
      // Headline – section titles
      headlineLarge: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppConstants.colorWhite,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppConstants.colorWhite,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppConstants.colorWhite,
      ),
      // Title – card titles
      titleLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorWhite,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorWhite,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorBodyText,
        letterSpacing: 0.5,
      ),
      // Body
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.5,
      ),
      // Label / Mono tags
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.5,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.0,
      ),
    );
  }

  static ThemeData darkArabic() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.colorBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.colorPrimary,
        secondary: AppConstants.colorAccent,
        tertiary: AppConstants.colorEmerald,
        surface: AppConstants.colorCard,
        onPrimary: AppConstants.colorWhite,
        onSecondary: AppConstants.colorWhite,
        onSurface: AppConstants.colorWhite,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: _buildArabicTextTheme(),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppConstants.colorWhite,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(color: AppConstants.colorWhite),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.colorCard,
        selectedItemColor: AppConstants.colorPrimary,
        unselectedItemColor: AppConstants.colorBodyText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.colorCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppConstants.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppConstants.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(
            color: AppConstants.colorPrimary,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppConstants.colorBodyText,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppConstants.colorBodyText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.colorPrimary,
          foregroundColor: AppConstants.colorWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          textStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXl,
            vertical: AppConstants.spacingMd,
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppConstants.colorCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          side: const BorderSide(color: AppConstants.colorBorder),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppConstants.colorBorder,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildArabicTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppConstants.colorWhite,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppConstants.colorWhite,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppConstants.colorWhite,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppConstants.colorWhite,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppConstants.colorWhite,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorWhite,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorWhite,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorWhite,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorBodyText,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.5,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.2,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: AppConstants.colorBodyText,
        letterSpacing: 1.0,
      ),
    );
  }

  /// Returns the Arabic font (Cairo style) overrides.
  /// Apply to any Text widget that renders Arabic content manually if needed.
  static TextStyle arabicBody({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppConstants.colorBodyText,
    double height = 1.85,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle arabicHeading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppConstants.colorWhite,
    double height = 1.5,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
