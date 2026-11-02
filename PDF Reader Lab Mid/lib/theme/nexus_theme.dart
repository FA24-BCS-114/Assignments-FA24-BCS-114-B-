import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NexusTheme114 {
  NexusTheme114._();

  static ThemeData get darkTheme {
    final scheme = ColorScheme.dark(
      primary: AppConstants114.secondaryBlue,
      onPrimary: Colors.white,
      secondary: AppConstants114.accentCyan,
      onSecondary: AppConstants114.darkBackground,
      surface: AppConstants114.cardSurface,
      onSurface: AppConstants114.textPrimary,
      error: AppConstants114.dangerRose,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppConstants114.darkBackground,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants114.primaryNavy,
        foregroundColor: AppConstants114.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppConstants114.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppConstants114.borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants114.cardSurface,
        hintStyle: const TextStyle(color: AppConstants114.textSoftGrey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppConstants114.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppConstants114.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppConstants114.accentCyan, width: 1.5),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppConstants114.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppConstants114.borderSubtle),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants114.primaryNavy,
        contentTextStyle: const TextStyle(color: AppConstants114.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppConstants114.secondaryBlue),
        ),
      ),
    );
  }

  static ThemeData get lightFallbackTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants114.secondaryBlue,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
    );
  }
}
