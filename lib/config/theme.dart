import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 메인 그라데이션 컬러
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  // 카테고리별 그라데이션
  static const Map<String, List<Color>> categoryGradients = {
    '건강': [Color(0xFFFA709A), Color(0xFFFEE140)],
    '운동': [Color(0xFF30E8BF), Color(0xFFFF8235)],
    '지출': [Color(0xFF667EEA), Color(0xFF764BA2)],
    '학습': [Color(0xFFF093FB), Color(0xFFF5576C)],
    '취미': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    '수면': [Color(0xFF43E97B), Color(0xFF38F9D7)],
    '식사': [Color(0xFFFFD89B), Color(0xFF19547B)],
  };

  // 텍스트 스타일
  static TextStyle heading1 = GoogleFonts.notoSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF2D3436),
  );

  static TextStyle heading2 = GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF2D3436),
  );

  static TextStyle heading3 = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2D3436),
  );

  static TextStyle bodyLarge = GoogleFonts.notoSans(
    fontSize: 16,
    color: const Color(0xFF636E72),
  );

  static TextStyle bodyMedium = GoogleFonts.notoSans(
    fontSize: 14,
    color: const Color(0xFF636E72),
  );

  static TextStyle caption = GoogleFonts.notoSans(
    fontSize: 12,
    color: const Color(0xFFB2BEC3),
  );

  // 카드 스타일
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colors[0].withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // 전체 테마
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF667EEA),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: heading2,
      iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 8,
      backgroundColor: Color(0xFF667EEA),
    ),
  );
}