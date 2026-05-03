import 'package:flutter/material.dart';

/// Central place for all compile-time constants.
/// Never import this into UI widgets directly – use providers instead.
class AppConstants {
  AppConstants._();

  // ── Supabase ──────────────────────────────────────────────────────────────
  // Keys injected at build time via --dart-define. Never hardcode these.
  // Run: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // See .env.example for full usage instructions.
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const String appNameEn = 'Sovereign Maareg Fund';
  static const String appNameAr = 'صندوق المعارج السيادي';
  static const String contactEmail = 'abdallahnooh7@gmail.com';
  static const String contactPhone = '+201009086283';
  static const String contactLocation = 'Nasr City, Cairo, Egypt';
  static const String contactLocationAr = 'مدينة نصر، القاهرة، مصر';
  static const String privacyPolicyUrl = 'https://sovereignmaareg.com/privacy';
  static const String termsUrl = 'https://sovereignmaareg.com/terms';

  // ── Colors  (matching web palette exactly) ────────────────────────────────
  // Hero / dark background: #050B14
  static const Color colorBackground = Color(0xFF050B14);
  // Card dark background: #0A1628
  static const Color colorCard = Color(0xFF0A1628);
  // Surface (light sections): #FAF9F6
  static const Color colorSurface = Color(0xFFFAF9F6);
  // Primary blue: #2563EB  (blue-600)
  static const Color colorPrimary = Color(0xFF2563EB);
  // Blue-400 accent
  static const Color colorAccent = Color(0xFF60A5FA);
  // Indigo-400
  static const Color colorIndigo = Color(0xFF818CF8);
  // Emerald-400
  static const Color colorEmerald = Color(0xFF34D399);
  // Slate-800 border
  static const Color colorBorder = Color(0xFF1E293B);
  // Slate-400 body text
  static const Color colorBodyText = Color(0xFF94A3B8);
  // White text
  static const Color colorWhite = Color(0xFFFFFFFF);
  // Purple (lead form accent, from website's #7C3AED)
  static const Color colorPurple = Color(0xFF7C3AED);
  // Light surface bg (Services section, white)
  static const Color colorWhiteSurface = Color(0xFFFFFFFF);
  // Slate-900 (HowItWorks bg)
  static const Color colorDarkSurface = Color(0xFF0F172A);

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingHuge = 64.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 9999.0;

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Duration durationVerySlow = Duration(milliseconds: 900);

  // ── Trust Stats (from TrustSection) ──────────────────────────────────────
  static const String statInvestors = '10,000+';
  static const String statJurisdictions = '50+';
  static const String statSuccessRate = '99.9%';
  static const String statAssets = '\$5B+';
}
