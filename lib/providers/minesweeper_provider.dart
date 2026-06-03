import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/minesweeper_types.dart';
import '../utils/minesweeper_logic.dart' as logic;

const _saveKey = 'minesweeper_save_v1';

enum MinesweeperStatus { idle, playing, won, gameOver }

class MinesweeperProvider extends ChangeNotifier {
  Grid _grid = [];
  MinesweeperDifficulty _difficulty = MinesweeperDifficulty.easy;
  MinesweeperStatus _status = MinesweeperStatus.idle;
  bool _minesPlaced = false;
  int _flagCount = 0;
  int _seconds = 0;
  Timer? _timer;

  Grid get grid => _grid;
  MinesweeperDifficulty get difficulty => _difficulty;
  MinesweeperStatus get status => _status;
  int get rows => _difficulty.rows;
  int get cols => _difficulty.cols;
  int get minesRemaining => _difficulty.mineCount - _flagCount;
  int get seconds => _seconds;
  bool get minesPlaced => _minesPlaced;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  Future<void> newGame(MinesweeperDifficulty difficulty) async {
    _timer?.cancel();
    _difficulty = difficulty;
    _grid = logic.createEmptyGrid(difficulty.rows, difficulty.cols);
    _status = MinesweeperStatus.playing;
    _minesPlaced = false;
    _flagCount = 0;
    _seconds = 0;
    notifyListeners();
    await _save();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void revealCell(int row, int col) {
    if (_status != MinesweeperStatus.playing) return;
    final cell = _grid[row][col];

    // Start timer on first action
    if (!_minesPlaced) {
      _grid = logic.placeMines(_grid, rows, cols, _difficulty.mineCount, row, col, Random());
      _minesPlaced = true;
      _startTimer();
    }

    // Chord on already-revealed number
    if (cell.status == CellStatus.revealed && cell.adjacentMines > 0) {
      final result = logic.chordReveal(_grid, rows, cols, row, col);
      if (result == null) {
        _triggerGameOver(row, col);
        return;
      }
      _grid = result;
      if (logic.checkWin(_grid, rows, cols)) _triggerWin();
      notifyListeners();
      _save();
      return;
    }

    if (cell.status != CellStatus.hidden) return;

    if (cell.hasMine) {
      _triggerGameOver(row, col);
      return;
    }

    final result = logic.revealCell(_grid, rows, cols, row, col);
    if (result == null) {
      _triggerGameOver(row, col);
      return;
    }
    _grid = result;
    if (logic.checkWin(_grid, rows, cols)) _triggerWin();
    notifyListeners();
    _save();
  }

  void toggleFlag(int row, int col) {
    if (_status != MinesweeperStatus.playing) return;
    final cell = _grid[row][col];
    if (cell.status == CellStatus.revealed) return;

    if (cell.status == CellStatus.flagged) {
      _grid[row][col] = cell.copyWith(status: CellStatus.hidden);
      _flagCount--;
    } else {
      _grid[row][col] = cell.copyWith(status: CellStatus.flagged);
      _flagCount++;
    }
    notifyListeners();
    _save();
  }

  void _triggerGameOver(int row, int col) {
    _timer?.cancel();
    _status = MinesweeperStatus.gameOver;
    _grid = logic.revealAllMines(_grid, rows, cols, row, col);
    notifyListeners();
    _save();
  }

  void _triggerWin() {
    _timer?.cancel();
    _status = MinesweeperStatus.won;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _difficulty = MinesweeperDifficulty.values[json['difficulty'] as int];
      _status = MinesweeperStatus.values[json['status'] as int];
      _minesPlaced = json['mines_placed'] as bool;
      _flagCount = json['flag_count'] as int;
      _seconds = json['seconds'] as int;
      final rawGrid = json['grid'] as List;
      _grid = rawGrid
          .map((row) => (row as List)
              .map((c) => MineCell.fromJson(c as Map<String, dynamic>))
              .toList())
          .toList();
      if (_status == MinesweeperStatus.playing && _minesPlaced) _startTimer();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_grid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _saveKey,
      jsonEncode({
        'difficulty': _difficulty.index,
        'status': _status.index,
        'mines_placed': _minesPlaced,
        'flag_count': _flagCount,
        'seconds': _seconds,
        'grid': _grid
            .map((row) => row.map((c) => c.toJson()).toList())
            .toList(),
      }),
    );
  }
}
