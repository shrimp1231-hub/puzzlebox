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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: _buildGameGrid(),
            ),
          ],
        ),
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

  SliverGrid _buildGameGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.9,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SudokuScreen()),
        );
      case GameId.game2048:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Game2048Screen()),
        );
      case GameId.minesweeper:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MinesweeperScreen()),
        );
    }
  }
}
