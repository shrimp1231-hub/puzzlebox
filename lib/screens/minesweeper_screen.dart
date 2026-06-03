import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/minesweeper_types.dart';
import '../models/point_transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/minesweeper_provider.dart';
import '../providers/point_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/minesweeper_board.dart';

class MinesweeperScreen extends StatefulWidget {
  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  bool _winHandled = false;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MinesweeperProvider>();
      await provider.loadSaved();
      if (provider.status == MinesweeperStatus.idle && mounted) {
        await _showDifficultyPicker(initial: true);
      }
    });
  }

  Future<void> _showDifficultyPicker({bool initial = false}) async {
    final provider = context.read<MinesweeperProvider>();
    final difficulty = await showModalBottomSheet<MinesweeperDifficulty>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DifficultyPicker(initial: initial),
    );
    if (difficulty != null) {
      _winHandled = false;
      _gameOverHandled = false;
      await provider.newGame(difficulty);
    } else if (initial && mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

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
        title: Consumer<MinesweeperProvider>(
          builder: (_, p, __) => Column(
            children: [
              const Text('지뢰찾기',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              if (p.status != MinesweeperStatus.idle)
                Text(p.difficulty.label,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _showDifficultyPicker(),
          ),
        ],
      ),
      body: Consumer<MinesweeperProvider>(
        builder: (context, provider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.status == MinesweeperStatus.won && !_winHandled) {
              _winHandled = true;
              _handleWin(context, provider);
            }
            if (provider.status == MinesweeperStatus.gameOver && !_gameOverHandled) {
              _gameOverHandled = true;
              _handleGameOver(context, provider);
            }
          });

          if (provider.status == MinesweeperStatus.idle || provider.grid.isEmpty) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            top: false,
            child: Column(
              children: [
                _StatusBar(provider: provider, formatTime: _formatTime),
                Expanded(
                  child: MinesweeperBoard(provider: provider)
                      .animate()
                      .fadeIn(duration: 300.ms),
                ),
                _HintRow(minesPlaced: provider.minesPlaced),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleWin(BuildContext context, MinesweeperProvider provider) async {
    final auth = context.read<AuthProvider>();
    final points = context.read<PointProvider>();
    if (auth.user != null) {
      await points.addPoints(
        userId: auth.user!.id,
        type: TransactionType.gameComplete,
        delta: provider.difficulty.pointReward,
        description: '지뢰찾기 ${provider.difficulty.label} 클리어',
      );
    }
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(
        seconds: provider.seconds,
        pointsEarned: provider.difficulty.pointReward,
        formatTime: _formatTime,
        onNewGame: () {
          Navigator.pop(context);
          _showDifficultyPicker();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleGameOver(BuildContext context, MinesweeperProvider provider) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GameOverDialog(
        onNewGame: () {
          Navigator.pop(context);
          _showDifficultyPicker();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final MinesweeperProvider provider;
  final String Function(int) formatTime;

  const _StatusBar({required this.provider, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine counter
          _Pill(
            icon: '💣',
            text: '${provider.minesRemaining}',
            color: const Color(0xFFEF5350),
          ),
          // Smiley / status
          GestureDetector(
            onTap: () {},
            child: Text(
              provider.status == MinesweeperStatus.won
                  ? '😎'
                  : provider.status == MinesweeperStatus.gameOver
                      ? '😵'
                      : '😊',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          // Timer
          _Pill(
            icon: '⏱',
            text: formatTime(provider.seconds),
            color: const Color(0xFF64B5F6),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  const _Pill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final bool minesPlaced;
  const _HintRow({required this.minesPlaced});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Text(
        minesPlaced ? '탭: 열기  ·  길게 탭: 깃발' : '첫 번째 칸을 탭하세요',
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  final bool initial;
  const _DifficultyPicker({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(initial ? '난이도를 선택하세요' : '새 게임 시작',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...MinesweeperDifficulty.values.map((d) => _DifficultyTile(difficulty: d)),
          if (!initial) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final MinesweeperDifficulty difficulty;
  const _DifficultyTile({required this.difficulty});

  static const _emojis = ['😊', '🤔', '🤯'];
  static const _colors = [Color(0xFF4CAF50), Color(0xFF42A5F5), Color(0xFFAB47BC)];

  @override
  Widget build(BuildContext context) {
    final color = _colors[difficulty.index];
    final d = difficulty;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(child: Text(_emojis[d.index], style: const TextStyle(fontSize: 20))),
      ),
      title: Text(d.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${d.rows}×${d.cols} · 지뢰 ${d.mineCount}개 · +${d.pointReward}P',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      onTap: () => Navigator.pop(context, d),
    );
  }
}

class _WinDialog extends StatelessWidget {
  final int seconds;
  final int pointsEarned;
  final String Function(int) formatTime;
  final VoidCallback onNewGame;
  final VoidCallback onExit;

  const _WinDialog({
    required this.seconds,
    required this.pointsEarned,
    required this.formatTime,
    required this.onNewGame,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😎', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          const Text('클리어!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('시간: ${formatTime(seconds)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('+$pointsEarned P',
              style: const TextStyle(
                  color: Color(0xFFFFB300), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white54),
                  child: const Text('나가기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNewGame,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B61FF)),
                  child: const Text('다시 하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameOverDialog extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onExit;
  const _GameOverDialog({required this.onNewGame, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💥', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          const Text('지뢰 폭발!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onNewGame,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                minimumSize: const Size(double.infinity, 44)),
            child: const Text('다시 하기'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onExit,
            child: const Text('나가기', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
