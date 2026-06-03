import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_info.dart';
import '../providers/auth_provider.dart';
import '../providers/point_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_card.dart';
import '../widgets/stat_chip.dart';
import 'profile_screen.dart';
import 'sudoku_screen.dart';
import 'character_screen.dart';
import 'game_2048_screen.dart';
import 'minesweeper_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      await context.read<PointProvider>().loadPoints(auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경 라디알 핫스팟
          _Hotspot(color: AppColors.hotspot1, opacity: 0.08, left: -120, top: -120),
          _Hotspot(color: AppColors.hotspot2, opacity: 0.05, right: -120, bottom: -120),
          // 메인 콘텐츠
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildStatsRow()),
                SliverToBoxAdapter(child: _buildFeaturedCard(context)),
                SliverToBoxAdapter(child: _buildSectionLabel('전체 게임')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: _buildGameGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.sudokuFrom, AppColors.sudokuTo],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🧩', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '퍼즐박스',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => Text(
                    auth.isAuthenticated
                        ? '${auth.user!.displayName}님, 오늘도 두뇌 운동 해볼까요? 🧠'
                        : '오늘도 두뇌 운동 해볼까요? 🧠',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) => Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: auth.user?.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(auth.user!.avatarUrl!, fit: BoxFit.cover),
                        )
                      : const Text('🐱', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: -0.1, end: 0, curve: Curves.easeOut, duration: 400.ms),
    );
  }

  Widget _buildStatsRow() {
    return Consumer2<AuthProvider, PointProvider>(
      builder: (context, auth, points, _) {
        final streakDays = auth.user?.streakDays ?? 1;
        final totalPoints = points.totalPoints;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StatChip(label: '오늘 플레이', value: '${auth.user?.gamesPlayed ?? 0}판', icon: Icons.sports_esports_rounded),
                const SizedBox(width: 8),
                StatChip(label: '포인트', value: '${totalPoints}P', icon: Icons.stars_rounded),
                const SizedBox(width: 8),
                StatChip(label: '출석', value: '${streakDays}일', icon: Icons.local_fire_department_rounded),
              ],
            ),
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 350.ms)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOut, duration: 350.ms),
        );
      },
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final game = allGames[0]; // 스도쿠 — 인기 1위
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () => _onGameTap(context, game),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [game.gradientFrom, game.gradientTo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: game.gradientFrom.withOpacity(0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 배경 장식
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 인기 뱃지
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('인기 게임', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              // 이모지
              Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(game.emoji, style: const TextStyle(fontSize: 72)),
                ),
              ),
              // 텍스트 영역
              Positioned(
                left: 20,
                bottom: 20,
                right: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < game.difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 13,
                          color: Colors.white.withOpacity(i < game.difficulty ? 0.9 : 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        '지금 플레이',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut, duration: 400.ms),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  SliverGrid _buildGameGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.8, // 4:5 세로형
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = allGames[index];
          return GameCard(
            game: game,
            animationIndex: index,
            onTap: () => _onGameTap(context, game),
          );
        },
        childCount: allGames.length,
      ),
    );
  }

  void _onGameTap(BuildContext context, GameInfo game) {
    switch (game.id) {
      case GameId.sudoku:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SudokuScreen()));
      case GameId.game2048:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const Game2048Screen()));
      case GameId.minesweeper:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MinesweeperScreen()));
    }
  }
}

class _Hotspot extends StatelessWidget {
  final Color color;
  final double opacity;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  const _Hotspot({
    required this.color,
    required this.opacity,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent],
            radius: 1.0,
          ),
        ),
      ),
    );
  }
}
