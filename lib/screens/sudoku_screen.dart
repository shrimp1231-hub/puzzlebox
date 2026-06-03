import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_types.dart';
import '../models/point_transaction.dart';
import '../providers/sudoku_provider.dart';
import '../providers/point_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../widgets/rewarded_ad_button.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SudokuProvider>();
      await provider.loadSaved();
      if (provider.status == GameStatus.idle && mounted) {
        _showDifficultyPicker(initial: true);
      }
    });
  }

  Future<void> _showDifficultyPicker({bool initial = false}) async {
    final provider = context.read<SudokuProvider>();
    final difficulty = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DifficultyPicker(initial: initial),
    );
    if (difficulty != null) {
      await provider.newGame(difficulty);
    } else if (initial && mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return _SudokuBody(
      onDifficultyPick: _showDifficultyPicker,
      formatTime: _formatTime,
    );
  }
}

class _SudokuBody extends StatelessWidget {
  final Future<void> Function({bool initial}) onDifficultyPick;
  final String Function(int) formatTime;

  const _SudokuBody({
    required this.onDifficultyPick,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuProvider>(
      builder: (context, provider, _) {
        // Show win overlay after build
        if (provider.status == GameStatus.won) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleWin(context, provider);
          });
        }
        if (provider.status == GameStatus.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleGameOver(context, provider);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, provider),
          body: provider.generating
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF7B61FF)),
                      SizedBox(height: 16),
                      Text('퍼즐 생성 중...', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : provider.status == GameStatus.idle
                  ? const SizedBox.shrink()
                  : _buildGameBody(context, provider),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, SudokuProvider provider) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text('스도쿠',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          if (provider.status != GameStatus.idle)
            Text(provider.difficulty.label,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          onPressed: () => onDifficultyPick(),
        ),
      ],
    );
  }

  Widget _buildGameBody(BuildContext context, SudokuProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _StatusBar(provider: provider, formatTime: formatTime),
            const SizedBox(height: 12),
            SudokuBoard(
              board: provider.board,
              selected: provider.selected,
              onCellTap: provider.selectCell,
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.97, 0.97)),
            const SizedBox(height: 20),
            NumberPad(
              remainingCounts: provider.remainingCounts,
              onNumber: provider.inputNumber,
              onErase: provider.erase,
              onUndo: provider.undo,
              onHint: provider.hint,
              onToggleMode: provider.toggleInputMode,
              isNoteMode: provider.inputMode == InputMode.note,
              hintsLeft: provider.hintsLeft,
              canUndo: provider.canUndo,
            ),
            // ── Ad flow: hint exhausted → watch ad for +1 hint ──────────────
            if (provider.hintsLeft == 0 &&
                provider.status == GameStatus.playing) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RewardedAdButton(
                  label: '광고 보고 힌트 받기',
                  icon: Icons.lightbulb_outline_rounded,
                  color: const Color(0xFFFFB300),
                  onRewarded: () => provider.grantHintFromAd(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleWin(BuildContext context, SudokuProvider provider) async {
    // Award points
    final auth = context.read<AuthProvider>();
    final points = context.read<PointProvider>();
    if (auth.user != null) {
      await points.addPoints(
        userId: auth.user!.id,
        type: TransactionType.gameComplete,
        delta: provider.difficulty.pointReward,
        description: '스도쿠 ${provider.difficulty.label} 클리어',
      );
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(
        seconds: provider.seconds,
        pointsEarned: provider.difficulty.pointReward,
        formatTime: formatTime,
        onNewGame: () {
          Navigator.pop(context);
          onDifficultyPick();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleGameOver(BuildContext context, SudokuProvider provider) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GameOverDialog(
        onContinue: () {
          Navigator.pop(context);
          provider.addMistakeChance();
        },
        onNewGame: () {
          Navigator.pop(context);
          onDifficultyPick();
        },
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final SudokuProvider provider;
  final String Function(int) formatTime;

  const _StatusBar({required this.provider, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mistakes
        Row(
          children: List.generate(
            provider.effectiveMistakeLimit + 1,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.favorite_rounded,
                size: 18,
                color: i < (provider.effectiveMistakeLimit - provider.mistakesUsed + 1)
                    ? const Color(0xFFEF5350)
                    : Colors.white12,
              ),
            ),
          ),
        ),
        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            formatTime(provider.seconds),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        // Hints remaining
        Row(
          children: List.generate(
            _maxHints,
            (i) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: i < provider.hintsLeft
                    ? const Color(0xFFFFB300)
                    : Colors.white12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _maxHints = 3;

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
          ...Difficulty.values.map((d) => _DifficultyTile(difficulty: d)),
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
  final Difficulty difficulty;
  const _DifficultyTile({required this.difficulty});

  static const _colors = [Color(0xFF4CAF50), Color(0xFF42A5F5), Color(0xFFFF7043), Color(0xFFAB47BC)];
  static const _descs = ['빈칸 36개', '빈칸 46개', '빈칸 52개', '빈칸 56개'];

  @override
  Widget build(BuildContext context) {
    final color = _colors[difficulty.index];
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
        child: Center(
          child: Text(
            ['😊', '🤔', '😤', '🤯'][difficulty.index],
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(difficulty.label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text('${_descs[difficulty.index]} · +${difficulty.pointReward}P',
          style: const TextStyle(color: Colors.white38, fontSize: 12)),
      onTap: () => Navigator.pop(context, difficulty),
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
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          const Text('클리어!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('시간: ${formatTime(seconds)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('+$pointsEarned P 획득!',
              style: const TextStyle(color: Color(0xFFFFB300), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
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
  final VoidCallback onContinue;
  final VoidCallback onNewGame;

  const _GameOverDialog({required this.onContinue, required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          const Text('게임 오버',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('실수 횟수 초과',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          // ── Ad flow: watch ad to earn +1 mistake chance ──────────────────
          RewardedAdButton(
            label: '광고 보고 계속하기 (+1 기회)',
            icon: Icons.play_circle_outline_rounded,
            color: const Color(0xFF7B61FF),
            onRewarded: () {
              Navigator.pop(context);
              onContinue();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onNewGame,
            child: const Text('새 게임', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
