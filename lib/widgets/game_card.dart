import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_info.dart';
import '../theme/app_theme.dart';

class GameCard extends StatefulWidget {
  final GameInfo game;
  final VoidCallback? onTap;
  final int animationIndex;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return GestureDetector(
      onTapDown: game.isUnlocked ? (_) => setState(() => _pressed = true) : null,
      onTapUp: game.isUnlocked ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: game.isUnlocked ? () => setState(() => _pressed = false) : null,
      onTap: game.isUnlocked ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: game.isUnlocked
                  ? [game.gradientFrom, game.gradientTo]
                  : [
                      game.gradientFrom.withOpacity(0.3),
                      game.gradientTo.withOpacity(0.3),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: game.isUnlocked
                ? [
                    BoxShadow(
                      color: game.gradientFrom.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // 배경 장식 원
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: -30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 카드 내용
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이모지 + 잠금 아이콘
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          game.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                        if (!game.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              game.comingSoonLabel ?? 'Soon',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      game.title,
                      style: TextStyle(
                        color: game.isUnlocked ? Colors.white : Colors.white54,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.subtitle,
                      style: TextStyle(
                        color: game.isUnlocked
                            ? Colors.white.withOpacity(0.75)
                            : Colors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * widget.animationIndex))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut, duration: 400.ms);
  }
}
