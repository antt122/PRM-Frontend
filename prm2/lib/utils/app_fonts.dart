import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Font families - using Google Fonts that are similar to SF Pro
  static const String sfProDisplay = 'Inter'; // Similar to SF Pro Display
  static const String sfProText = 'Inter'; // Similar to SF Pro Text

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text styles for different UI elements - using Google Fonts
  static TextStyle get largeTitle =>
      GoogleFonts.inter(fontSize: 34, fontWeight: bold, letterSpacing: -0.5);

  static TextStyle get title1 =>
      GoogleFonts.inter(fontSize: 28, fontWeight: bold, letterSpacing: -0.3);

  static TextStyle get title2 =>
      GoogleFonts.inter(fontSize: 22, fontWeight: bold, letterSpacing: -0.2);

  static TextStyle get title3 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: semibold,
    letterSpacing: -0.1,
  );

  static TextStyle get headline => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: semibold,
    letterSpacing: -0.1,
  );

  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 17, fontWeight: regular, letterSpacing: -0.1);

  static TextStyle get callout =>
      GoogleFonts.inter(fontSize: 16, fontWeight: regular, letterSpacing: -0.1);

  static TextStyle get subhead =>
      GoogleFonts.inter(fontSize: 15, fontWeight: regular, letterSpacing: -0.1);

  static TextStyle get footnote =>
      GoogleFonts.inter(fontSize: 13, fontWeight: regular, letterSpacing: -0.1);

  static TextStyle get caption1 =>
      GoogleFonts.inter(fontSize: 12, fontWeight: regular, letterSpacing: 0.0);

  static TextStyle get caption2 =>
      GoogleFonts.inter(fontSize: 11, fontWeight: regular, letterSpacing: 0.0);
}
