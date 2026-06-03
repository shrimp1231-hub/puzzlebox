import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_types.dart';
import '../utils/sudoku_generator.dart';
import '../utils/sudoku_solver.dart';

const _saveKey = 'sudoku_save_v1';
const _maxHints = 3;
const _maxHistory = 20;

typedef Board = List<List<CellState>>;

class SudokuProvider extends ChangeNotifier {
  Board _board = [];
  RawBoard _solution = [];
  Difficulty _difficulty = Difficulty.easy;

  Position? _selected;
  InputMode _inputMode = InputMode.number;
  GameStatus _status = GameStatus.idle;

  int _hintsLeft = _maxHints;
  int _mistakesUsed = 0;
  int _extraMistakeChances = 0;
  int _seconds = 0;

  final List<Board> _history = [];
  Timer? _timer;

  bool _generating = false;

  // Getters
  Board get board => _board;
  RawBoard get solution => _solution;
  Difficulty get difficulty => _difficulty;
  Position? get selected => _selected;
  InputMode get inputMode => _inputMode;
  GameStatus get status => _status;
  int get hintsLeft => _hintsLeft;
  int get mistakesUsed => _mistakesUsed;
  int get seconds => _seconds;
  bool get canUndo => _history.isNotEmpty;
  bool get generating => _generating;
  int get effectiveMistakeLimit => _difficulty.mistakeLimit + _extraMistakeChances;

  Map<int, int> get remainingCounts {
    final counts = {for (int i = 1; i <= 9; i++) i: 9};
    for (final row in _board) {
      for (final cell in row) {
        if (cell.value != 0) {
          counts[cell.value] = (counts[cell.value] ?? 9) - 1;
        }
      }
    }
    return counts;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Generation ──────────────────────────────────────────────────────────────

  Future<void> newGame(Difficulty difficulty) async {
    _generating = true;
    notifyListeners();

    _timer?.cancel();
    _difficulty = difficulty;

    // Run generator in a separate compute to avoid blocking UI
    final result = await compute(_generateInBackground, difficulty.index);
    final rawPuzzle = result[0] as RawBoard;
    final rawSolution = result[1] as RawBoard;

    _board = _rawToBoard(rawPuzzle);
    _solution = rawSolution;
    _selected = null;
    _inputMode = InputMode.number;
    _status = GameStatus.playing;
    _hintsLeft = _maxHints;
    _mistakesUsed = 0;
    _extraMistakeChances = 0;
    _seconds = 0;
    _history.clear();
    _generating = false;

    _startTimer();
    notifyListeners();
    await _save();
  }

  // ── Cell selection & input ──────────────────────────────────────────────────

  void selectCell(Position pos) {
    _selected = (_selected == pos) ? null : pos;
    notifyListeners();
  }

  void inputNumber(int n) {
    if (_selected == null || _status != GameStatus.playing) return;
    final pos = _selected!;
    final cell = _board[pos.row][pos.col];
    if (cell.isGiven) return;

    _pushHistory();

    if (_inputMode == InputMode.note) {
      final notes = Set<int>.from(cell.notes);
      if (notes.contains(n)) {
        notes.remove(n);
      } else {
        notes.add(n);
      }
      _setCell(pos, cell.copyWith(value: 0, notes: notes));
    } else {
      final prevValue = cell.value;
      _setCell(pos, cell.copyWith(value: n, notes: {}));
      _clearRelatedNotes(pos, n);
      _revalidate();

      // Mistake tracking (only when placing a wrong non-zero value for the first time)
      if (n != _solution[pos.row][pos.col] && n != prevValue) {
        _mistakesUsed++;
        if (_mistakesUsed > effectiveMistakeLimit) {
          _status = GameStatus.gameOver;
          _timer?.cancel();
        }
      }
      if (_checkWon()) {
        _status = GameStatus.won;
        _timer?.cancel();
      }
    }
    notifyListeners();
    _save();
  }

  void erase() {
    if (_selected == null || _status != GameStatus.playing) return;
    final pos = _selected!;
    final cell = _board[pos.row][pos.col];
    if (cell.isGiven || cell.value == 0) return;
    _pushHistory();
    _setCell(pos, cell.copyWith(value: 0, notes: {}, isError: false));
    _revalidate();
    notifyListeners();
    _save();
  }

  void toggleInputMode() {
    _inputMode = _inputMode == InputMode.number ? InputMode.note : InputMode.number;
    notifyListeners();
  }

  void hint() {
    if (_hintsLeft <= 0 || _status != GameStatus.playing) return;
    final empties = <Position>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_board[r][c].isGiven && _board[r][c].value == 0) {
          empties.add(Position(r, c));
        }
      }
    }
    if (empties.isEmpty) return;
    empties.shuffle();
    final pos = empties.first;
    _pushHistory();
    _hintsLeft--;
    final correct = _solution[pos.row][pos.col];
    _setCell(pos, CellState(value: correct, isGiven: false));
    _clearRelatedNotes(pos, correct);
    _revalidate();
    _selected = pos;
    if (_checkWon()) {
      _status = GameStatus.won;
      _timer?.cancel();
    }
    notifyListeners();
    _save();
  }

  void undo() {
    if (_history.isEmpty) return;
    _board = _history.removeLast();
    notifyListeners();
    _save();
  }

  void addMistakeChance() {
    _extraMistakeChances++;
    if (_status == GameStatus.gameOver) {
      _status = GameStatus.playing;
      _startTimer();
    }
    notifyListeners();
  }

  // Called after user watches a rewarded ad when hints are exhausted.
  void grantHintFromAd() {
    _hintsLeft = 1;
    notifyListeners();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _difficulty = Difficulty.values[json['difficulty'] as int];
      _solution = (json['solution'] as List)
          .map((row) => (row as List).map((v) => v as int).toList())
          .toList();
      _board = (json['board'] as List)
          .map((row) => (row as List).map((c) => CellState.fromJson(c as Map<String, dynamic>)).toList())
          .toList();
      _hintsLeft = json['hints_left'] as int;
      _seconds = json['seconds'] as int;
      _mistakesUsed = json['mistakes_used'] as int;
      _extraMistakeChances = json['extra_chances'] as int;
      _status = GameStatus.values[json['status'] as int];
      _history.clear();
      if (_status == GameStatus.playing) _startTimer();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_board.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'difficulty': _difficulty.index,
      'solution': _solution,
      'board': _board.map((row) => row.map((c) => c.toJson()).toList()).toList(),
      'hints_left': _hintsLeft,
      'seconds': _seconds,
      'mistakes_used': _mistakesUsed,
      'extra_chances': _extraMistakeChances,
      'status': _status.index,
    };
    await prefs.setString(_saveKey, jsonEncode(json));
  }

  // ── Internal helpers ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
  }

  void _setCell(Position pos, CellState state) {
    _board = [
      for (int r = 0; r < 9; r++)
        [
          for (int c = 0; c < 9; c++)
            (r == pos.row && c == pos.col) ? state : _board[r][c],
        ],
    ];
  }

  void _clearRelatedNotes(Position pos, int value) {
    _board = [
      for (int r = 0; r < 9; r++)
        [
          for (int c = 0; c < 9; c++)
            _shouldClearNote(r, c, pos, value)
                ? _board[r][c].copyWith(notes: Set<int>.from(_board[r][c].notes)..remove(value))
                : _board[r][c],
        ],
    ];
  }

  bool _shouldClearNote(int r, int c, Position pos, int value) {
    if (r == pos.row && c == pos.col) return false;
    if (!_board[r][c].notes.contains(value)) return false;
    return r == pos.row ||
        c == pos.col ||
        (r ~/ 3 == pos.row ~/ 3 && c ~/ 3 == pos.col ~/ 3);
  }

  void _revalidate() {
    _board = [
      for (int r = 0; r < 9; r++)
        [
          for (int c = 0; c < 9; c++)
            _board[r][c].value == 0 || _board[r][c].isGiven
                ? _board[r][c].copyWith(isError: false)
                : _board[r][c].copyWith(isError: _hasConflict(r, c, _board[r][c].value)),
        ],
    ];
  }

  bool _hasConflict(int row, int col, int value) {
    for (int i = 0; i < 9; i++) {
      if (i != col && _board[row][i].value == value) return true;
      if (i != row && _board[i][col].value == value) return true;
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if ((r != row || c != col) && _board[r][c].value == value) return true;
      }
    }
    return false;
  }

  bool _checkWon() =>
      _board.every((row) => row.every((cell) => cell.value != 0 && !cell.isError));

  void _pushHistory() {
    _history.add(_board.map((row) => List<CellState>.from(row)).toList());
    if (_history.length > _maxHistory) _history.removeAt(0);
  }

  static Board _rawToBoard(RawBoard raw) => [
        for (int r = 0; r < 9; r++)
          [
            for (int c = 0; c < 9; c++)
              CellState(value: raw[r][c], isGiven: raw[r][c] != 0),
          ],
      ];
}

// Top-level function for compute() isolation
List<RawBoard> _generateInBackground(int difficultyIndex) {
  final difficulty = Difficulty.values[difficultyIndex];
  final (puzzle, solution) = generatePuzzle(difficulty);
  return [puzzle, solution];
}
