import 'package:flutter/material.dart';

class AppColors {
  // 허브 배경
  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceVariant = Color(0xFF16213E);
  static const border = Color(0xFF2A2A4A);

  // 게임 카드 색상
  static const sudokuFrom = Color(0xFF6C63FF);
  static const sudokuTo = Color(0xFF3B82F6);
  static const game2048From = Color(0xFFFF6B6B);
  static const game2048To = Color(0xFFFECA57);
  static const minesweeperFrom = Color(0xFF48CAE4);
  static const minesweeperTo = Color(0xFF023E8A);

  // UI 요소
  static const textPrimary = Color(0xFFE8E8F0);
  static const textSecondary = Color(0xFF9090B0);
  static const accent = Color(0xFF6C63FF);
  static const accentGlow = Color(0x336C63FF);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      );
}
