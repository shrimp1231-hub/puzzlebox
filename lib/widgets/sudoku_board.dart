import 'package:flutter/material.dart';
import '../models/sudoku_types.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends StatelessWidget {
  final List<List<CellState>> board;
  final Position? selected;
  final void Function(Position) onCellTap;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.selected,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7B61FF), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CustomPaint(
            painter: _GridLinesPainter(),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                return SudokuCell(
                  cell: board[row][col],
                  isSelected: selected?.row == row && selected?.col == col,
                  isHighlighted: _isHighlighted(row, col),
                  isSameValue: _isSameValue(row, col),
                  onTap: () => onCellTap(Position(row, col)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _isHighlighted(int row, int col) {
    if (selected == null) return false;
    return row == selected!.row ||
        col == selected!.col ||
        (row ~/ 3 == selected!.row ~/ 3 && col ~/ 3 == selected!.col ~/ 3);
  }

  bool _isSameValue(int row, int col) {
    if (selected == null) return false;
    final selVal = board[selected!.row][selected!.col].value;
    if (selVal == 0) return false;
    final thisVal = board[row][col].value;
    return thisVal == selVal &&
        !(row == selected!.row && col == selected!.col);
  }
}

class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = const Color(0xFF2A2A3E)
      ..strokeWidth = 0.5;
    final thickPaint = Paint()
      ..color = const Color(0xFF7B61FF).withOpacity(0.5)
      ..strokeWidth = 1.5;

    final cellSize = size.width / 9;

    for (int i = 1; i < 9; i++) {
      final x = cellSize * i;
      final y = cellSize * i;
      final paint = i % 3 == 0 ? thickPaint : thinPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinesPainter _) => false;
}
