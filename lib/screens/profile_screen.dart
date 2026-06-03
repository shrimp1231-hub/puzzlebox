import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/point_provider.dart';
import '../models/point_transaction.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      await context.read<PointProvider>().loadPoints(auth.user!.id);
    }
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
        title: const Text('프로필', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<AuthProvider, PointProvider>(
          builder: (context, auth, points, _) {
            if (auth.state == AuthState.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!auth.isAuthenticated) {
              return _buildSignInView(context, auth);
            }
            return _buildProfileView(context, auth, points);
          },
        ),
      ),
    );
  }

  Widget _buildSignInView(BuildContext context, AuthProvider auth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 2),
              ),
              child: const Center(child: Text('🐱', style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 24),
            const Text('로그인하고\n기록을 저장하세요', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 8),
            const Text('포인트, 출석, 게임 기록이 저장됩니다', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 32),
            if (auth.state == AuthState.loading)
              const CircularProgressIndicator()
            else
              _GoogleSignInButton(onPressed: () => auth.signInWithGoogle()),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(auth.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, AuthProvider auth, PointProvider points) {
    final user = auth.user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 20),
          _StatsRow(user: user, totalPoints: points.totalPoints),
          const SizedBox(height: 24),
          _PointHistorySection(history: points.history),
          const SizedBox(height: 32),
          _SignOutButton(onPressed: () async {
            await auth.signOut();
            context.read<PointProvider>().reset();
          }),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
            SizedBox(width: 12),
            Text('Google로 계속하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF2A2A3E),
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl as String) : null,
            child: user.avatarUrl == null
                ? const Text('🐱', style: TextStyle(fontSize: 32))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName as String,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user.email as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('출석 ${user.streakDays}일 연속 🔥',
                      style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic user;
  final int totalPoints;
  const _StatsRow({required this.user, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: '총 포인트', value: '$totalPoints P', icon: '⭐'),
        const SizedBox(width: 12),
        _StatCard(label: '게임 플레이', value: '${user.gamesPlayed}회', icon: '🎮'),
        const SizedBox(width: 12),
        _StatCard(label: '출석', value: '${user.streakDays}일', icon: '🔥'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PointHistorySection extends StatelessWidget {
  final List<PointTransaction> history;
  const _PointHistorySection({required this.history});

  String _label(TransactionType type) {
    switch (type) {
      case TransactionType.gameComplete: return '게임 완료';
      case TransactionType.dailyBonus: return '일일 보너스';
      case TransactionType.streakBonus: return '연속 출석';
      case TransactionType.achievement: return '업적';
      case TransactionType.spend: return '사용';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('포인트 내역', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text('게임을 플레이하면 포인트가 쌓여요!',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),
          )
        else
          ...history.map((tx) => _HistoryTile(tx: tx, label: _label(tx.type))),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PointTransaction tx;
  final String label;
  const _HistoryTile({required this.tx, required this.label});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.delta >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${tx.delta} P',
            style: TextStyle(
              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SignOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white54,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('로그아웃', style: TextStyle(fontSize: 15)),
      ),
    );
  }
}
