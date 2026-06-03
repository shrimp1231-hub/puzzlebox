import 'package:flutter/foundation.dart';
import '../models/point_transaction.dart';
import '../repositories/point_repository.dart';

class PointProvider extends ChangeNotifier {
  final PointRepository _repository;

  int _totalPoints = 0;
  List<PointTransaction> _history = [];
  bool _loading = false;

  PointProvider(this._repository);

  int get totalPoints => _totalPoints;
  List<PointTransaction> get history => List.unmodifiable(_history);
  bool get isLoading => _loading;

  Future<void> loadPoints(String userId) async {
    _loading = true;
    notifyListeners();
    _totalPoints = await _repository.getTotalPoints(userId);
    _history = await _repository.getHistory(userId);
    _loading = false;
    notifyListeners();
  }

  Future<void> addPoints({
    required String userId,
    required TransactionType type,
    required int delta,
    required String description,
  }) async {
    final tx = PointTransaction(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      delta: delta,
      description: description,
      createdAt: DateTime.now(),
    );
    _totalPoints = await _repository.addPoints(userId, tx);
    _history.insert(0, tx);
    if (_history.length > 100) _history.removeLast();
    notifyListeners();
  }

  void reset() {
    _totalPoints = 0;
    _history = [];
    notifyListeners();
  }
}
