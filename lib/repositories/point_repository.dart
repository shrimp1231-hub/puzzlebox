import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/point_transaction.dart';

abstract class PointRepository {
  Future<int> getTotalPoints(String userId);
  Future<List<PointTransaction>> getHistory(String userId, {int limit = 20});
  Future<int> addPoints(String userId, PointTransaction tx);
}

class LocalPointRepository implements PointRepository {
  static const _keyPrefix = 'points_';
  static const _historyPrefix = 'history_';

  String _pointsKey(String userId) => '$_keyPrefix$userId';
  String _historyKey(String userId) => '$_historyPrefix$userId';

  @override
  Future<int> getTotalPoints(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey(userId)) ?? 0;
  }

  @override
  Future<List<PointTransaction>> getHistory(String userId, {int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey(userId));
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.take(limit).map(PointTransaction.fromJson).toList();
  }

  @override
  Future<int> addPoints(String userId, PointTransaction tx) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_pointsKey(userId)) ?? 0;
    final next = (current + tx.delta).clamp(0, 9999999);

    final raw = prefs.getString(_historyKey(userId));
    final list = raw != null
        ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.insert(0, tx.toJson());
    if (list.length > 100) list.removeLast();

    await prefs.setInt(_pointsKey(userId), next);
    await prefs.setString(_historyKey(userId), jsonEncode(list));
    return next;
  }
}
