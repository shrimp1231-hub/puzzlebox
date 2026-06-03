import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character_item.dart';
import '../models/point_transaction.dart';
import '../providers/character_provider.dart';
import '../providers/point_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ItemCategory> _categories = ItemCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('캐릭터 꾸미기',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Consumer<PointProvider>(
            builder: (_, points, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                backgroundColor: const Color(0xFF1E3A5F),
                label: Text('${points.totalPoints} P',
                    style: const TextStyle(color: Color(0xFF64B5F6), fontWeight: FontWeight.bold)),
                avatar: const Icon(Icons.stars_rounded, color: Color(0xFF64B5F6), size: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _CharacterPreview(),
            const SizedBox(height: 8),
            _CategoryTabBar(controller: _tabController, categories: _categories),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((cat) => _ItemGrid(category: cat)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (_, char, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7B61FF).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Character placeholder: emoji layers for equipped items
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _buildCharacterEmoji(char),
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '픽셀 에셋 연동 예정',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              // Equipped item badges
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: _EquippedBadgeRow(char: char),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildCharacterEmoji(CharacterProvider char) {
    final outfit = char.equippedIn(ItemCategory.outfit);
    if (outfit?.id == 'outfit_004') return '🧝';
    if (outfit?.id == 'outfit_003') return '🧙';
    return '🐱';
  }
}

class _EquippedBadgeRow extends StatelessWidget {
  final CharacterProvider char;
  const _EquippedBadgeRow({required this.char});

  @override
  Widget build(BuildContext context) {
    final equippedItems = ItemCategory.values
        .map((cat) => char.equippedIn(cat))
        .where((item) => item != null && item.price > 0)
        .toList();

    if (equippedItems.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: equippedItems.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Color(item!.rarity.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(item.rarity.color).withOpacity(0.5)),
            ),
            child: Text(item.name,
                style: TextStyle(color: Color(item.rarity.color), fontSize: 10)),
          ),
        )).toList(),
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  final TabController controller;
  final List<ItemCategory> categories;
  const _CategoryTabBar({required this.controller, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        indicator: BoxDecoration(
          color: const Color(0xFF7B61FF).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        tabs: categories.map((cat) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cat.emoji),
              const SizedBox(width: 4),
              Text(cat.label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  final ItemCategory category;
  const _ItemGrid({required this.category});

  @override
  Widget build(BuildContext context) {
    final items = defaultItemCatalog.where((i) => i.category == category).toList();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _ItemCard(item: items[index]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final CharacterItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CharacterProvider, PointProvider>(
      builder: (context, char, points, _) {
        final owned = char.isOwned(item.id);
        final equipped = char.isEquipped(item.id);
        final rarityColor = Color(item.rarity.color);

        return GestureDetector(
          onTap: () => _onTap(context, char, points, owned, equipped),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: equipped
                  ? rarityColor.withOpacity(0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: equipped ? rarityColor : Colors.white10,
                width: equipped ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Asset placeholder
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.category.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.name,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 2),
                const SizedBox(height: 3),
                Text(item.rarity.label,
                    style: TextStyle(color: rarityColor, fontSize: 10)),
                const SizedBox(height: 4),
                if (equipped)
                  const Text('착용 중', style: TextStyle(color: Colors.greenAccent, fontSize: 10))
                else if (owned)
                  const Text('보유 중', style: TextStyle(color: Colors.white38, fontSize: 10))
                else
                  Text('${item.price} P',
                      style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTap(
    BuildContext context,
    CharacterProvider char,
    PointProvider points,
    bool owned,
    bool equipped,
  ) async {
    if (equipped) {
      await char.unequip(item.category);
      return;
    }
    if (owned) {
      await char.equip(item.id);
      return;
    }
    // Purchase flow
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id ?? 'guest-001';
    if (points.totalPoints < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포인트가 부족합니다. 게임을 플레이해서 포인트를 모아보세요!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        content: Text('${item.price} P를 사용해서 구매할까요?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('구매', style: TextStyle(color: Color(0xFF64B5F6))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await char.purchase(item.id, points.totalPoints, (delta) {
        points.addPoints(
          userId: userId,
          type: TransactionType.spend,
          delta: delta,
          description: '${item.name} 구매',
        );
      });
    }
  }
}
