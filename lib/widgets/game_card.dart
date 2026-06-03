import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_info.dart';

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
                      color: game.gradientFrom.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
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
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: -24,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 카드 내용
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 60% — 이모지 영역
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            game.emoji,
                            style: TextStyle(
                              fontSize: game.isUnlocked ? 52 : 40,
                            ),
                          ),
                        ),
                        if (!game.isUnlocked)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          ),
                      ],
                    ),
                  ),

                  // 하단 40% — 게임 정보
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            game.title,
                            style: TextStyle(
                              color: game.isUnlocked ? Colors.white : Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 난이도 별점
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < game.difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 11,
                                color: game.isUnlocked
                                    ? Colors.white.withOpacity(i < game.difficulty ? 0.9 : 0.3)
                                    : Colors.white24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 플레이 버튼
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(game.isUnlocked ? 0.22 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(game.isUnlocked ? 0.3 : 0.1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                game.isUnlocked ? '플레이' : '잠금',
                                style: TextStyle(
                                  color: game.isUnlocked ? Colors.white : Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
