import 'package:flutter/material.dart';
import '../models/minesweeper_types.dart';

const double cellSize = 36.0;

class MinesweeperCell extends StatelessWidget {
  final MineCell cell;
  final bool gameOver;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MinesweeperCell({
    super.key,
    required this.cell,
    required this.gameOver,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: Container(
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: _backgroundColor(),
            borderRadius: BorderRadius.circular(4),
            boxShadow: cell.status == CellStatus.hidden && !gameOver
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(1, 1),
                      blurRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Center(child: _buildContent()),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    if (cell.isExploded) return const Color(0xFFB71C1C);
    switch (cell.status) {
      case CellStatus.hidden:
        return const Color(0xFF2A2A4E);
      case CellStatus.flagged:
        return const Color(0xFF2A2A4E);
      case CellStatus.revealed:
        return cell.hasMine
            ? const Color(0xFF4A1010)
            : const Color(0xFF0F0F1A);
    }
  }

  Widget _buildContent() {
    switch (cell.status) {
      case CellStatus.flagged:
        return const Text('🚩', style: TextStyle(fontSize: 16));
      case CellStatus.hidden:
        return const SizedBox.shrink();
      case CellStatus.revealed:
        if (cell.hasMine) {
          return Text(
            cell.isExploded ? '💥' : '💣',
            style: const TextStyle(fontSize: 16),
          );
        }
        if (cell.adjacentMines == 0) return const SizedBox.shrink();
        return Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(numberColors[cell.adjacentMines]),
          ),
        );
    }
  }
}
