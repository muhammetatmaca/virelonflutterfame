import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0F0F1A);
  static const Color primary = Color(0xFF7000FF); // Electric Purple
  static const Color accent = Color(0xFF00F0FF);  // Cyan Neon
  static const Color danger = Color(0xFFFF0055);  // Neon Red
  static const Color success = Color(0xFF00FF9D); // Neon Green
  static const Color warning = Color(0xFFFFD600); // Neon Yellow
  static const Color surface = Color(0xFF1F1F2E);
  
  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF05050A),
      Color(0xFF13132B),
      Color(0xFF0A0014),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 2,
    shadows: [
      const BoxShadow(color: primary, blurRadius: 20, spreadRadius: 0),
    ]
  );
  
  static TextStyle get headline => GoogleFonts.orbitron(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 4,
    shadows: [
      const BoxShadow(color: accent, blurRadius: 24, spreadRadius: 2),
    ]
  );

  static TextStyle get titleMedium => GoogleFonts.rajdhani(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get body => GoogleFonts.rajdhani(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get chip => GoogleFonts.orbitron(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: accent,
  );
}
