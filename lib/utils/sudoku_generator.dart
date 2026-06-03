import 'dart:math';
import '../models/sudoku_types.dart';
import 'sudoku_solver.dart';

List<T> _shuffle<T>(List<T> list, Random rng) {
  final a = List<T>.from(list);
  for (int i = a.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

RawBoard _makeFullBoard(Random rng) {
  final board = List.generate(9, (_) => List.filled(9, 0));

  bool isValid(int r, int c, int n) {
    for (int i = 0; i < 9; i++) {
      if (board[r][i] == n || board[i][c] == n) return false;
    }
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (int rr = br; rr < br + 3; rr++) {
      for (int cc = bc; cc < bc + 3; cc++) {
        if (board[rr][cc] == n) return false;
      }
    }
    return true;
  }

  bool fill(int pos) {
    if (pos == 81) return true;
    final r = pos ~/ 9;
    final c = pos % 9;
    for (final n in _shuffle([1, 2, 3, 4, 5, 6, 7, 8, 9], rng)) {
      if (isValid(r, c, n)) {
        board[r][c] = n;
        if (fill(pos + 1)) return true;
        board[r][c] = 0;
      }
    }
    return false;
  }

  fill(0);
  return board;
}

/// Returns (puzzle, solution). Puzzle has empty cells (0) according to difficulty.
/// NOTE: For expert difficulty, uniqueness checking can be slow (~1-2s).
/// In production, run this in a Dart Isolate via compute().
(RawBoard, RawBoard) generatePuzzle(Difficulty difficulty, {Random? rng}) {
  final random = rng ?? Random();
  final solution = _makeFullBoard(random);
  final puzzle = solution.map((row) => List<int>.from(row)).toList();

  final positions = _shuffle(
    [for (int i = 0; i < 81; i++) (i ~/ 9, i % 9)],
    random,
  );

  int removed = 0;
  final target = difficulty.blankCount;

  for (final (r, c) in positions) {
    if (removed >= target) break;
    final backup = puzzle[r][c];
    puzzle[r][c] = 0;
    if (countSolutions(puzzle, 2) == 1) {
      removed++;
    } else {
      puzzle[r][c] = backup;
    }
  }

  return (puzzle, solution);
}
