import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_2048_types.dart';

const _gap = 8.0;
const _radius = 8.0;

class Game2048Board extends StatelessWidget {
  final List<Tile2048> tiles;
  final void Function(Direction2048) onSwipe;

  const Game2048Board({
    super.key,
    required this.tiles,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onVerticalDragEnd: (d) {
          if (d.primaryVelocity == null) return;
          if (d.primaryVelocity! < -200) onSwipe(Direction2048.up);
          if (d.primaryVelocity! > 200) onSwipe(Direction2048.down);
        },
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity == null) return;
          if (d.primaryVelocity! < -200) onSwipe(Direction2048.left);
          if (d.primaryVelocity! > 200) onSwipe(Direction2048.right);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            final cellSize = (size - _gap * 5) / 4;
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A4E), width: 2),
              ),
              child: Stack(
                children: [
                  // Background grid
                  Padding(
                    padding: const EdgeInsets.all(_gap),
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: _gap,
                      mainAxisSpacing: _gap,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        16,
                        (_) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F1A),
                            borderRadius: BorderRadius.circular(_radius),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tiles
                  ...tiles.map((tile) => _Tile2048Widget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        cellSize: cellSize,
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Tile2048Widget extends StatelessWidget {
  final Tile2048 tile;
  final double cellSize;

  const _Tile2048Widget({
    super.key,
    required this.tile,
    required this.cellSize,
  });

  double _pos(int index) => _gap + index * (cellSize + _gap);

  @override
  Widget build(BuildContext context) {
    Widget content = _TileContent(tile: tile, cellSize: cellSize);

    if (tile.isMerged) {
      content = content
          .animate()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: 100.ms,
            curve: Curves.easeOut,
          );
    } else if (tile.isNew) {
      content = content
          .animate()
          .scale(
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            duration: 120.ms,
            curve: Curves.elasticOut,
          );
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeInOut,
      left: _pos(tile.col),
      top: _pos(tile.row),
      width: cellSize,
      height: cellSize,
      child: content,
    );
  }
}

class _TileContent extends StatelessWidget {
  final Tile2048 tile;
  final double cellSize;

  const _TileContent({required this.tile, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    final bg = Color(tileColor(tile.value));
    final useLight = tileUseLightText(tile.value);
    final textColor = useLight ? Colors.white : const Color(0xFF776e65);
    final fontSize = tile.value >= 1000
        ? cellSize * 0.28
        : tile.value >= 100
            ? cellSize * 0.34
            : cellSize * 0.42;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: tile.value >= 2048
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${tile.value}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
