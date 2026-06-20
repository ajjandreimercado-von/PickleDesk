import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors matching UI Mockup
  static const Color primaryGreen = Color(0xFF2E7D32); // Vibrant green accent
  static const Color backgroundDark = Color(0xFF0C100D); // Deep dark background
  static const Color surfaceDark = Color(0xFF151C17); // Slightly lighter card surface
  static const Color surfaceLighter = Color(0xFF1E2822); // Hover/Input surface
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8B949E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: surfaceLighter,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyMedium: GoogleFonts.inter(color: textGrey),
        titleMedium: GoogleFonts.inter(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF253028), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF253028)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundDark,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: textGrey, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen);
          }
          return const IconThemeData(color: textGrey);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: backgroundDark,
        selectedIconTheme: const IconThemeData(color: primaryGreen),
        unselectedIconTheme: const IconThemeData(color: textGrey),
        selectedLabelTextStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: const TextStyle(color: textGrey),
        indicatorColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen),
        ),
        labelStyle: const TextStyle(color: textGrey),
        prefixIconColor: textGrey,
      ),
    );
  }
}
