import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4352A5);
  static const Color primaryContainerColor = Color(0xFF5C6BC0);
  static const Color secondaryColor = Color(0xFF21638D);
  static const Color tertiaryColor = Color(0xFF6B4F72);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color onSurfaceColor = Color(0xFF191C1D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: const Color(0xFFF8F6FF),
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        outline: const Color(0xFF767683),
        surfaceContainerHighest: const Color(0xFFE1E3E4),
      ),
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        labelMedium: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        color: const Color(0xFFEDEEEF), // Surface Container
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: primaryContainerColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: Color(0xFF454651));
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Basic dark theme placeholder, can be refined later
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
    );
  }
}
