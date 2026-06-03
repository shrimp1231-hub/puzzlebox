import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum GameId { sudoku, game2048, minesweeper }

class GameInfo {
  final GameId id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color gradientFrom;
  final Color gradientTo;
  final bool isUnlocked;
  final String? comingSoonLabel;
  final int difficulty; // 1-5 stars

  const GameInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientFrom,
    required this.gradientTo,
    this.isUnlocked = true,
    this.comingSoonLabel,
    this.difficulty = 3,
  });
}

final List<GameInfo> allGames = [
  const GameInfo(
    id: GameId.sudoku,
    title: '스도쿠',
    subtitle: '논리력을 키워요',
    emoji: '🔢',
    gradientFrom: AppColors.sudokuFrom,
    gradientTo: AppColors.sudokuTo,
    difficulty: 3,
  ),
  const GameInfo(
    id: GameId.game2048,
    title: '2048',
    subtitle: '숫자를 합쳐요',
    emoji: '🎮',
    gradientFrom: AppColors.game2048From,
    gradientTo: AppColors.game2048To,
    difficulty: 2,
  ),
  const GameInfo(
    id: GameId.minesweeper,
    title: '지뢰찾기',
    subtitle: '지뢰를 피해요',
    emoji: '💣',
    gradientFrom: AppColors.minesweeperFrom,
    gradientTo: AppColors.minesweeperTo,
    difficulty: 4,
  ),
];
