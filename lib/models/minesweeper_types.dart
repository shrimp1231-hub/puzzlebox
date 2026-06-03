enum MinesweeperDifficulty { easy, medium, expert }

extension MinesweeperDifficultyExt on MinesweeperDifficulty {
  String get label {
    switch (this) {
      case MinesweeperDifficulty.easy: return '쉬움';
      case MinesweeperDifficulty.medium: return '보통';
      case MinesweeperDifficulty.expert: return '전문가';
    }
  }

  int get rows {
    switch (this) {
      case MinesweeperDifficulty.easy: return 9;
      case MinesweeperDifficulty.medium: return 16;
      case MinesweeperDifficulty.expert: return 20;
    }
  }

  int get cols {
    switch (this) {
      case MinesweeperDifficulty.easy: return 9;
      case MinesweeperDifficulty.medium: return 16;
      case MinesweeperDifficulty.expert: return 20;
    }
  }

  int get mineCount {
    switch (this) {
      case MinesweeperDifficulty.easy: return 10;
      case MinesweeperDifficulty.medium: return 40;
      case MinesweeperDifficulty.expert: return 70;
    }
  }

  int get pointReward {
    switch (this) {
      case MinesweeperDifficulty.easy: return 30;
      case MinesweeperDifficulty.medium: return 100;
      case MinesweeperDifficulty.expert: return 250;
    }
  }
}

enum CellStatus { hidden, revealed, flagged }

class MineCell {
  final bool hasMine;
  final CellStatus status;
  final int adjacentMines; // 0–8
  final bool isExploded;   // the mine that was clicked

  const MineCell({
    this.hasMine = false,
    this.status = CellStatus.hidden,
    this.adjacentMines = 0,
    this.isExploded = false,
  });

  MineCell copyWith({
    bool? hasMine,
    CellStatus? status,
    int? adjacentMines,
    bool? isExploded,
  }) =>
      MineCell(
        hasMine: hasMine ?? this.hasMine,
        status: status ?? this.status,
        adjacentMines: adjacentMines ?? this.adjacentMines,
        isExploded: isExploded ?? this.isExploded,
      );

  Map<String, dynamic> toJson() => {
        'has_mine': hasMine,
        'status': status.index,
        'adjacent_mines': adjacentMines,
        'is_exploded': isExploded,
      };

  factory MineCell.fromJson(Map<String, dynamic> json) => MineCell(
        hasMine: json['has_mine'] as bool,
        status: CellStatus.values[json['status'] as int],
        adjacentMines: json['adjacent_mines'] as int,
        isExploded: json['is_exploded'] as bool? ?? false,
      );
}

// Number colors tuned for dark theme
const List<int> numberColors = [
  0x00000000, // 0 — not shown
  0xFF64B5F6, // 1 — light blue
  0xFF81C784, // 2 — light green
  0xFFEF5350, // 3 — red
  0xFFAB47BC, // 4 — purple
  0xFFFF7043, // 5 — deep orange
  0xFF26C6DA, // 6 — cyan
  0xFFFFF176, // 7 — yellow
  0xFFBDBDBD, // 8 — gray
];
