import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_2048_types.dart';
import '../utils/game_2048_logic.dart';

const _saveKey = 'game2048_save_v1';
const _bestKey = 'game2048_best_v1';

enum Game2048Status { idle, playing, won, gameOver }

class Game2048Provider extends ChangeNotifier {
  List<Tile2048> _tiles = [];
  int _score = 0;
  int _bestScore = 0;
  int _nextId = 1;
  Game2048Status _status = Game2048Status.idle;
  bool _continued = false; // user chose to continue after reaching 2048

  List<Tile2048> get tiles => List.unmodifiable(_tiles);
  int get score => _score;
  int get bestScore => _bestScore;
  Game2048Status get status => _status;
  bool get continued => _continued;

  int _genId() => _nextId++;

  @override
  void dispose() {
    super.dispose();
  }

  // ── Game lifecycle ──────────────────────────────────────────────────────────

  Future<void> newGame() async {
    _tiles = [];
    _score = 0;
    _nextId = 1;
    _status = Game2048Status.playing;
    _continued = false;

    final t1 = spawnTile(_tiles, _genId);
    _tiles = [t1!];
    final t2 = spawnTile(_tiles, _genId);
    _tiles = [..._tiles, t2!];

    notifyListeners();
    await _save();
  }

  void move(Direction2048 dir) {
    if (_status != Game2048Status.playing) return;

    // Strip animation flags before processing
    final clean = _tiles.map((t) => t.copyWith(isNew: false, isMerged: false)).toList();
    final (newTiles, gained, moved) = applyMove(clean, dir, _genId);

    if (!moved) return;

    _score += gained;
    if (_score > _bestScore) {
      _bestScore = _score;
      _saveBest();
    }

    // Spawn a new tile
    final spawned = spawnTile(newTiles, _genId);
    _tiles = spawned != null ? [...newTiles, spawned] : newTiles;

    // Check win (first time reaching 2048)
    if (!_continued && _tiles.any((t) => t.value >= 2048)) {
      _status = Game2048Status.won;
    } else if (isGameOver(_tiles)) {
      _status = Game2048Status.gameOver;
    }

    notifyListeners();
    _save();
  }

  void continueAfterWin() {
    _continued = true;
    _status = Game2048Status.playing;
    notifyListeners();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestKey) ?? 0;
    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _score = json['score'] as int;
      _nextId = json['next_id'] as int;
      _continued = json['continued'] as bool? ?? false;
      _status = Game2048Status.values[json['status'] as int];
      _tiles = (json['tiles'] as List)
          .map((t) => Tile2048.fromJson(t as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _saveKey,
      jsonEncode({
        'score': _score,
        'next_id': _nextId,
        'continued': _continued,
        'status': _status.index,
        'tiles': _tiles.map((t) => t.toJson()).toList(),
      }),
    );
  }

  Future<void> _saveBest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestKey, _bestScore);
  }
}
