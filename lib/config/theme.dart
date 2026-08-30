import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Rose-500
  
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: darkSurface,
        background: darkBackground,
        error: error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryDark,
        surface: lightSurface,
        background: lightBackground,
        error: error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
