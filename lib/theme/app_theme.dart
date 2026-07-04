import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Brand Colors ────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);
  static const Color purple = Color(0xFF8B5CF6);

  // Light palette
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSub = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightMuted = Color(0xFFF1F5F9);

  // Dark palette
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSub = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkMuted = Color(0xFF1E293B);
}

// ─── Theme Definitions ───────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primary, Color secondary) {
    final base = TextTheme(
      displayLarge: TextStyle(color: primary),
      displayMedium: TextStyle(color: primary),
      displaySmall: TextStyle(color: primary),
      headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: primary),
      bodyMedium: TextStyle(color: primary),
      bodySmall: TextStyle(color: secondary),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: secondary),
      labelSmall: TextStyle(color: secondary),
    );
    return GoogleFonts.interTextTheme(base);
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.info,
      onSecondary: Colors.white,
      error: AppColors.danger,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightMuted,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: _textTheme(AppColors.lightText, AppColors.lightTextSub),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSub,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.info,
      onSecondary: Colors.white,
      error: AppColors.danger,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkMuted,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _textTheme(AppColors.darkText, AppColors.darkTextSub),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextSub,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
  );
}
