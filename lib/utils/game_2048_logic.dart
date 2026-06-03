import 'dart:math';
import '../models/game_2048_types.dart';

/// Returns (newTiles, scoreGained, didMove).
(List<Tile2048>, int, bool) applyMove(
  List<Tile2048> tiles,
  Direction2048 dir,
  int Function() nextId,
) {
  final result = <Tile2048>[];
  int scoreGained = 0;
  bool moved = false;

  final isHorizontal = dir == Direction2048.left || dir == Direction2048.right;
  final reverse = dir == Direction2048.right || dir == Direction2048.down;

  for (int line = 0; line < 4; line++) {
    // Collect tiles in this row (horizontal) or column (vertical)
    List<Tile2048> lineTiles;
    if (isHorizontal) {
      lineTiles = tiles.where((t) => t.row == line).toList()
        ..sort((a, b) => a.col.compareTo(b.col));
    } else {
      lineTiles = tiles.where((t) => t.col == line).toList()
        ..sort((a, b) => a.row.compareTo(b.row));
    }

    if (reverse) lineTiles = lineTiles.reversed.toList();

    // Merge adjacent equal tiles
    final merged = <Tile2048>[];
    int i = 0;
    while (i < lineTiles.length) {
      if (i + 1 < lineTiles.length &&
          lineTiles[i].value == lineTiles[i + 1].value) {
        final newValue = lineTiles[i].value * 2;
        scoreGained += newValue;
        merged.add(lineTiles[i].copyWith(value: newValue, isMerged: true));
        i += 2;
      } else {
        merged.add(lineTiles[i].copyWith(isMerged: false));
        i++;
      }
    }

    // Assign final positions
    for (int j = 0; j < merged.length; j++) {
      final slot = reverse ? (3 - j) : j;
      final newRow = isHorizontal ? line : slot;
      final newCol = isHorizontal ? slot : line;
      final tile = merged[j];

      if (tile.row != newRow || tile.col != newCol || tile.isMerged) {
        moved = true;
      }

      result.add(tile.copyWith(row: newRow, col: newCol, isNew: false));
    }
  }

  return (result, scoreGained, moved);
}

/// Adds a random tile (90% = 2, 10% = 4) to an empty cell.
/// Returns null if no empty cells.
Tile2048? spawnTile(List<Tile2048> tiles, int Function() nextId, {Random? rng}) {
  final random = rng ?? Random();
  final occupied = {for (final t in tiles) (t.row, t.col)};
  final empties = [
    for (int r = 0; r < 4; r++)
      for (int c = 0; c < 4; c++)
        if (!occupied.contains((r, c))) (r, c),
  ];
  if (empties.isEmpty) return null;
  final (row, col) = empties[random.nextInt(empties.length)];
  final value = random.nextDouble() < 0.9 ? 2 : 4;
  return Tile2048(id: nextId(), value: value, row: row, col: col, isNew: true);
}

/// True if no valid moves remain (board is full and no adjacent equals).
bool isGameOver(List<Tile2048> tiles) {
  if (tiles.length < 16) return false;
  final grid = List.generate(4, (_) => List.filled(4, 0));
  for (final t in tiles) grid[t.row][t.col] = t.value;
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (c + 1 < 4 && grid[r][c] == grid[r][c + 1]) return false;
      if (r + 1 < 4 && grid[r][c] == grid[r + 1][c]) return false;
    }
  }
  return true;
}
