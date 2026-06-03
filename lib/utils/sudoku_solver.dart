typedef RawBoard = List<List<int>>;

RawBoard _clone(RawBoard board) =>
    board.map((row) => List<int>.from(row)).toList();

bool _isValid(RawBoard board, int row, int col, int num) {
  for (int i = 0; i < 9; i++) {
    if (board[row][i] == num) return false;
    if (board[i][col] == num) return false;
  }
  final br = (row ~/ 3) * 3;
  final bc = (col ~/ 3) * 3;
  for (int r = br; r < br + 3; r++) {
    for (int c = bc; c < bc + 3; c++) {
      if (board[r][c] == num) return false;
    }
  }
  return true;
}

(int, int)? _findEmpty(RawBoard board) {
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      if (board[r][c] == 0) return (r, c);
    }
  }
  return null;
}

RawBoard? solve(RawBoard input) {
  final board = _clone(input);

  bool bt() {
    final empty = _findEmpty(board);
    if (empty == null) return true;
    final (r, c) = empty;
    for (int n = 1; n <= 9; n++) {
      if (_isValid(board, r, c, n)) {
        board[r][c] = n;
        if (bt()) return true;
        board[r][c] = 0;
      }
    }
    return false;
  }

  return bt() ? board : null;
}

// Counts solutions up to [limit]. Used to verify puzzle uniqueness (limit=2).
int countSolutions(RawBoard input, int limit) {
  final board = _clone(input);
  int count = 0;

  void bt() {
    if (count >= limit) return;
    final empty = _findEmpty(board);
    if (empty == null) {
      count++;
      return;
    }
    final (r, c) = empty;
    for (int n = 1; n <= 9; n++) {
      if (_isValid(board, r, c, n)) {
        board[r][c] = n;
        bt();
        board[r][c] = 0;
        if (count >= limit) return;
      }
    }
  }

  bt();
  return count;
}
