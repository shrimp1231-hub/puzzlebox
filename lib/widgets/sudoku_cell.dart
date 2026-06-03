import 'package:flutter/material.dart';
import '../models/sudoku_types.dart';

class SudokuCell extends StatelessWidget {
  final CellState cell;
  final bool isSelected;
  final bool isHighlighted; // same row/col/box as selected
  final bool isSameValue;   // same value as selected (non-zero)
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.isSameValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _boxDecoration(),
        child: Center(child: _buildContent()),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    Color bg;
    if (isSelected) {
      bg = const Color(0xFF7B61FF).withOpacity(0.35);
    } else if (cell.isError) {
      bg = const Color(0xFFEF5350).withOpacity(0.18);
    } else if (isSameValue) {
      bg = const Color(0xFF7B61FF).withOpacity(0.15);
    } else if (isHighlighted) {
      bg = const Color(0xFF2A2A3E);
    } else {
      bg = const Color(0xFF1A1A2E);
    }
    return BoxDecoration(color: bg);
  }

  Widget _buildContent() {
    if (cell.value != 0) {
      return Text(
        '${cell.value}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: cell.isGiven ? FontWeight.w700 : FontWeight.w500,
          color: cell.isError
              ? const Color(0xFFEF5350)
              : cell.isGiven
                  ? Colors.white
                  : const Color(0xFF90CAF9),
        ),
      );
    }
    if (cell.notes.isEmpty) return const SizedBox.shrink();
    return _NotesGrid(notes: cell.notes);
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  const _NotesGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(9, (i) {
          final n = i + 1;
          return Center(
            child: Text(
              notes.contains(n) ? '$n' : '',
              style: const TextStyle(fontSize: 8, color: Colors.white54),
            ),
          );
        }),
      ),
    );
  }
}
