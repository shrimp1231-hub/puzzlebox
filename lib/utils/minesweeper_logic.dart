import 'dart:collection';
import 'dart:math';
import '../models/minesweeper_types.dart';

typedef Grid = List<List<MineCell>>;

Grid createEmptyGrid(int rows, int cols) =>
    List.generate(rows, (_) => List.generate(cols, (_) => const MineCell()));

/// Places mines after first click. The 3×3 area around (safeRow, safeCol)
/// is guaranteed mine-free.
Grid placeMines(
  Grid grid,
  int rows,
  int cols,
  int mineCount,
  int safeRow,
  int safeCol,
  Random rng,
) {
  final safeZone = <(int, int)>{};
  for (int r = safeRow - 1; r <= safeRow + 1; r++) {
    for (int c = safeCol - 1; c <= safeCol + 1; c++) {
      if (r >= 0 && r < rows && c >= 0 && c < cols) safeZone.add((r, c));
    }
  }

  final candidates = [
    for (int r = 0; r < rows; r++)
      for (int c = 0; c < cols; c++)
        if (!safeZone.contains((r, c))) (r, c),
  ]..shuffle(rng);

  final mineSet = candidates.take(mineCount).toSet();

  // Build grid with mines
  final withMines = List.generate(rows, (r) => List.generate(cols, (c) {
        return MineCell(hasMine: mineSet.contains((r, c)));
      }));

  // Calculate adjacentMines for each cell
  return List.generate(rows, (r) => List.generate(cols, (c) {
        if (withMines[r][c].hasMine) return withMines[r][c];
        int adj = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && withMines[nr][nc].hasMine) {
              adj++;
            }
          }
        }
        return withMines[r][c].copyWith(adjacentMines: adj);
      }));
}

/// Reveals a cell. If adjacentMines == 0, BFS-floods to reveal all connected empties.
/// Returns null if the cell is a mine (game over trigger).
Grid? revealCell(Grid grid, int rows, int cols, int row, int col) {
  final cell = grid[row][col];
  if (cell.status != CellStatus.hidden) return grid;
  if (cell.hasMine) return null; // caller handles game over

  var current = _copyGrid(grid, rows, cols);
  final queue = Queue<(int, int)>();
  queue.add((row, col));

  while (queue.isNotEmpty) {
    final (r, c) = queue.removeFirst();
    final cur = current[r][c];
    if (cur.status == CellStatus.revealed || cur.hasMine) continue;
    current[r][c] = cur.copyWith(status: CellStatus.revealed);
    if (cur.adjacentMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = r + dr;
          final nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols &&
              current[nr][nc].status == CellStatus.hidden) {
            queue.add((nr, nc));
          }
        }
      }
    }
  }

  return current;
}

/// Chord: when a revealed number has exactly [adjacentMines] flags around it,
/// reveal all remaining hidden neighbors. Returns null on mine hit.
Grid? chordReveal(Grid grid, int rows, int cols, int row, int col) {
  final cell = grid[row][col];
  if (cell.status != CellStatus.revealed || cell.adjacentMines == 0) return grid;

  int flags = 0;
  final hiddenNeighbors = <(int, int)>[];
  for (int dr = -1; dr <= 1; dr++) {
    for (int dc = -1; dc <= 1; dc++) {
      if (dr == 0 && dc == 0) continue;
      final nr = row + dr;
      final nc = col + dc;
      if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
      final n = grid[nr][nc];
      if (n.status == CellStatus.flagged) flags++;
      if (n.status == CellStatus.hidden) hiddenNeighbors.add((nr, nc));
    }
  }

  if (flags != cell.adjacentMines) return grid;

  var current = grid;
  for (final (r, c) in hiddenNeighbors) {
    if (current[r][c].hasMine) return null; // hit a mine
    final result = revealCell(current, rows, cols, r, c);
    if (result == null) return null;
    current = result;
  }
  return current;
}

/// Reveals all mines on game over.
Grid revealAllMines(Grid grid, int rows, int cols, int explodedRow, int explodedCol) {
  return List.generate(rows, (r) => List.generate(cols, (c) {
        final cell = grid[r][c];
        if (r == explodedRow && c == explodedCol) {
          return cell.copyWith(status: CellStatus.revealed, isExploded: true);
        }
        if (cell.hasMine && cell.status != CellStatus.flagged) {
          return cell.copyWith(status: CellStatus.revealed);
        }
        return cell;
      }));
}

/// True when every non-mine cell is revealed.
bool checkWin(Grid grid, int rows, int cols) {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final cell = grid[r][c];
      if (!cell.hasMine && cell.status != CellStatus.revealed) return false;
    }
  }
  return true;
}

Grid _copyGrid(Grid grid, int rows, int cols) =>
    List.generate(rows, (r) => List.from(grid[r]));
