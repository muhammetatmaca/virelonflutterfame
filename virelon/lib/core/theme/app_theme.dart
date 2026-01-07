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

  // === MODERN TEXT STYLES ===
  
  // Ana başlık - Büyük ve etkileyici (Oyun adı, kazanan ekranı vb.)
  static TextStyle get headline => const TextStyle(
    fontFamily: 'Atarian',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 3,
  );

  // Büyük başlık - Bölüm başlıkları
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: 'Atarian',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1,
  );
  
  // Orta başlık - Kart isimleri, oyuncu isimleri
  static TextStyle get titleMedium => const TextStyle(
    fontFamily: 'Atarian',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Küçük başlık - Alt başlıklar
  static TextStyle get titleSmall => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Normal metin - Açıklamalar, paragraflar
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15,
    color: Colors.white.withOpacity(0.85),
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Küçük metin - Notlar, ipuçları
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13,
    color: Colors.white70,
    fontWeight: FontWeight.w400,
  );

  // Etiket/Badge - Buton içi, chip vb.
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Vurgulu metin - Önemli bilgiler
  static TextStyle get accentStyle => GoogleFonts.exo2(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppTheme.accent,
    letterSpacing: 1,
  );

  // Chip stili - Eski uyumluluk için
  static TextStyle get chip => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppTheme.accent,
    letterSpacing: 0.5,
  );
  
  // Oyuncu isim stili - Belirgin ve okunabilir
  static TextStyle get playerName => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  // Sıra yazısı - "Sıra Sende" vb.
  static TextStyle get turnIndicator => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.9),
  );
  
  // Para göstergesi
  static TextStyle get coinDisplay => GoogleFonts.exo2(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: warning,
  );
}
