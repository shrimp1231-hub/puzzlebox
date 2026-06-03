import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/point_transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/game_2048_provider.dart';
import '../providers/point_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_2048_board.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  bool _winHandled = false;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<Game2048Provider>();
      await provider.loadSaved();
      if (provider.status == Game2048Status.idle && mounted) {
        await provider.newGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('2048',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _confirmNewGame(context),
          ),
        ],
      ),
      body: Consumer<Game2048Provider>(
        builder: (context, provider, _) {
          // Handle overlays after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.status == Game2048Status.won && !_winHandled) {
              _winHandled = true;
              _showWinDialog(context, provider);
            }
            if (provider.status == Game2048Status.gameOver && !_gameOverHandled) {
              _gameOverHandled = true;
              _showGameOverDialog(context, provider);
            }
            if (provider.status == Game2048Status.playing) {
              _winHandled = false;
              _gameOverHandled = false;
            }
          });

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _ScoreRow(provider: provider),
                  const SizedBox(height: 16),
                  _HintText(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: Game2048Board(
                        tiles: provider.tiles,
                        onSwipe: provider.move,
                      ).animate().fadeIn(duration: 300.ms),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmNewGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('새 게임', style: TextStyle(color: Colors.white)),
        content: const Text('현재 게임을 포기하고 새로 시작할까요?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('새 게임', style: TextStyle(color: Color(0xFF64B5F6))),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _winHandled = false;
      _gameOverHandled = false;
      await context.read<Game2048Provider>().newGame();
    }
  }

  Future<void> _showWinDialog(BuildContext context, Game2048Provider provider) async {
    // Award points
    final auth = context.read<AuthProvider>();
    final points = context.read<PointProvider>();
    if (auth.user != null) {
      await points.addPoints(
        userId: auth.user!.id,
        type: TransactionType.gameComplete,
        delta: 500,
        description: '2048 달성!',
      );
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            const Text('2048 달성!',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('점수: ${provider.score}',
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('+500 P',
                style: TextStyle(
                    color: Color(0xFFFFB300),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                provider.continueAfterWin();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('계속하기'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _winHandled = false;
                _gameOverHandled = false;
                await provider.newGame();
              },
              child: const Text('새 게임', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGameOverDialog(
      BuildContext context, Game2048Provider provider) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😔', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            const Text('게임 오버',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('최종 점수: ${provider.score}',
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            if (provider.score == provider.bestScore && provider.score > 0) ...[
              const SizedBox(height: 4),
              const Text('🎉 최고 기록!',
                  style: TextStyle(color: Color(0xFFFFB300), fontSize: 14)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _winHandled = false;
                _gameOverHandled = false;
                await provider.newGame();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('다시 하기'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('나가기', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final Game2048Provider provider;
  const _ScoreRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoreCard(
            label: '점수',
            value: provider.score,
            color: const Color(0xFF7B61FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ScoreCard(
            label: '최고 점수',
            value: provider.bestScore,
            color: const Color(0xFFFFB300),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ScoreCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _HintText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '스와이프해서 타일을 이동하세요',
      style: TextStyle(color: Colors.white38, fontSize: 12),
    );
  }
}
