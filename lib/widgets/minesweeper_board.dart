import 'package:flutter/material.dart';
import '../models/minesweeper_types.dart';
import '../providers/minesweeper_provider.dart';
import 'minesweeper_cell.dart';

class MinesweeperBoard extends StatelessWidget {
  final MinesweeperProvider provider;

  const MinesweeperBoard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final rows = provider.rows;
    final cols = provider.cols;
    final grid = provider.grid;
    final gameOver = provider.status == MinesweeperStatus.gameOver;
    final boardWidth = cols * cellSize;
    final boardHeight = rows * cellSize;

    return InteractiveViewer(
      minScale: 0.4,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          width: boardWidth,
          height: boardHeight,
          color: const Color(0xFF1A1A2E),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(cols, (c) {
                  return MinesweeperCell(
                    key: ValueKey('$r-$c'),
                    cell: grid[r][c],
                    gameOver: gameOver,
                    onTap: () => provider.revealCell(r, c),
                    onLongPress: () => provider.toggleFlag(r, c),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }
}
