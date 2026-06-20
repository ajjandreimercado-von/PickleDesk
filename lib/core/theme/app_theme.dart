import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colors (exactly from frontend theme.css) ──────────────────────────
  static const Color background    = Color(0xFF111410);
  static const Color surface       = Color(0xFF1d201c);
  static const Color surface2      = Color(0xFF282b26);
  static const Color surface3      = Color(0xFF333631);
  static const Color border        = Color(0xFF42493e);
  static const Color primary       = Color(0xFFa1d494);
  static const Color primaryDark   = Color(0xFF2d5a27);
  static const Color primaryDeep   = Color(0xFF3b6934);
  static const Color primaryFg     = Color(0xFF0a3909);
  static const Color text1         = Color(0xFFe2e3dc);
  static const Color text2         = Color(0xFFc2c9bb);
  static const Color text3         = Color(0xFF8c9387);
  static const Color winBg         = Color(0xFF2d5a27);
  static const Color loseBg        = Color(0xFF3d1f2a);
  static const Color loseText      = Color(0xFFffaac8);
  static const Color accentPurple  = Color(0xFF474649);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryDark,
        surface: surface,
        onPrimary: primaryFg,
        onSecondary: text1,
        onSurface: text1,
        error: loseText,
      ),
      scaffoldBackgroundColor: background,

      // Typography – Montserrat for headings, Inter for body
      textTheme: TextTheme(
        displayLarge:  GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w700, fontSize: 48),
        displayMedium: GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w700, fontSize: 36),
        displaySmall:  GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w700, fontSize: 32),
        headlineLarge: GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium:GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w700, fontSize: 22),
        headlineSmall: GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:    GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w600, fontSize: 17),
        titleMedium:   GoogleFonts.montserrat(color: text1, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:    GoogleFonts.montserrat(color: text2, fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:     GoogleFonts.inter(color: text1, fontWeight: FontWeight.w400, fontSize: 15),
        bodyMedium:    GoogleFonts.inter(color: text2, fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall:     GoogleFonts.inter(color: text3, fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge:    GoogleFonts.inter(color: text2, fontWeight: FontWeight.w500, fontSize: 13),
        labelMedium:   GoogleFonts.inter(color: text3, fontWeight: FontWeight.w500, fontSize: 11),
        labelSmall:    GoogleFonts.inter(color: text3, fontWeight: FontWeight.w500, fontSize: 10),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xE0111410),
        foregroundColor: text1,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          color: text1,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryFg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text1,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: primaryFg,
        shape: CircleBorder(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Color(0xF51d201c),
        indicatorColor: Colors.transparent,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final c = states.contains(WidgetState.selected) ? primary : text2;
          return GoogleFonts.inter(color: c, fontSize: 11, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final c = states.contains(WidgetState.selected) ? primary : text2;
          return IconThemeData(color: c, size: 22);
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: background,
        selectedIconTheme: const IconThemeData(color: primary),
        unselectedIconTheme: const IconThemeData(color: text2),
        selectedLabelTextStyle: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w500, fontSize: 14),
        unselectedLabelTextStyle: GoogleFonts.inter(color: text2, fontWeight: FontWeight.w500, fontSize: 14),
        indicatorColor: Colors.transparent,
      ),

      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary),
        ),
        hintStyle: GoogleFonts.inter(color: border, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: text2, fontSize: 13),
        prefixIconColor: text3,
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : border),
        thumbColor: WidgetStateProperty.all(Colors.white),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: GoogleFonts.inter(color: text2, fontSize: 13, fontWeight: FontWeight.w500),
        side: const BorderSide(color: border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
