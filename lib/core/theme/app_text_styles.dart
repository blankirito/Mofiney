import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  // Display
  static TextStyle get displayHero => GoogleFonts.hankenGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -1.44,
      );

  static TextStyle get displayHeroMobile => GoogleFonts.hankenGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.9,
      );

  // Headlines
  static TextStyle get headlineLarge => GoogleFonts.hankenGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 38 / 30,
        letterSpacing: -0.6,
      );

  static TextStyle get headlineLargeMobile => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.36,
      );

  static TextStyle get headlineMedium => GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        letterSpacing: -0.2,
      );

  static TextStyle get headlineSmall => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        letterSpacing: -0.08,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 26 / 16,
      );

  static TextStyle get bodyMedium => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
      );

  static TextStyle get bodySmall => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        letterSpacing: 0.12,
      );

  // Financial amounts
  static TextStyle get amountLarge => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        letterSpacing: -0.56,
      );

  static TextStyle get amountMedium => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 26 / 18,
        letterSpacing: -0.18,
      );

  static TextStyle get amountSmall => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
      );

  // Labels
  static TextStyle get labelCaps => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 16 / 11,
        letterSpacing: 0.66,
      );
}