enum Difficulty { easy, medium, hard, expert }

extension DifficultyLabel on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy: return '쉬움';
      case Difficulty.medium: return '보통';
      case Difficulty.hard: return '어려움';
      case Difficulty.expert: return '전문가';
    }
  }

  int get blankCount {
    switch (this) {
      case Difficulty.easy: return 36;
      case Difficulty.medium: return 46;
      case Difficulty.hard: return 52;
      case Difficulty.expert: return 56;
    }
  }

  int get mistakeLimit {
    switch (this) {
      case Difficulty.easy: return 5;
      case Difficulty.medium: return 3;
      case Difficulty.hard: return 1;
      case Difficulty.expert: return 0;
    }
  }

  int get pointReward {
    switch (this) {
      case Difficulty.easy: return 50;
      case Difficulty.medium: return 100;
      case Difficulty.hard: return 200;
      case Difficulty.expert: return 400;
    }
  }
}

class CellState {
  final int value; // 0 = empty
  final bool isGiven;
  final bool isError;
  final Set<int> notes;

  const CellState({
    this.value = 0,
    this.isGiven = false,
    this.isError = false,
    Set<int>? notes,
  }) : notes = notes ?? const {};

  CellState copyWith({
    int? value,
    bool? isGiven,
    bool? isError,
    Set<int>? notes,
  }) =>
      CellState(
        value: value ?? this.value,
        isGiven: isGiven ?? this.isGiven,
        isError: isError ?? this.isError,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'is_given': isGiven,
        'is_error': isError,
        'notes': notes.toList(),
      };

  factory CellState.fromJson(Map<String, dynamic> json) => CellState(
        value: (json['value'] as num).toInt(),
        isGiven: json['is_given'] as bool,
        isError: json['is_error'] as bool,
        notes: Set<int>.from((json['notes'] as List).cast<int>()),
      );
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 9 + col;
}

enum InputMode { number, note }
enum GameStatus { idle, playing, won, gameOver }
