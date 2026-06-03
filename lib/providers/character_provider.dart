import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_item.dart';

class CharacterProvider extends ChangeNotifier {
  // equipped item id per category; null = none equipped
  Map<ItemCategory, String?> _equipped = {};
  Set<String> _ownedIds = {};

  Map<ItemCategory, String?> get equipped => Map.unmodifiable(_equipped);
  Set<String> get ownedIds => Set.unmodifiable(_ownedIds);

  bool isOwned(String id) => _ownedIds.contains(id);
  bool isEquipped(String id) {
    final item = defaultItemCatalog.where((i) => i.id == id).firstOrNull;
    return item != null && _equipped[item.category] == id;
  }

  CharacterItem? equippedIn(ItemCategory category) {
    final id = _equipped[category];
    if (id == null) return null;
    return defaultItemCatalog.where((i) => i.id == id).firstOrNull;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final equippedRaw = prefs.getString('char_equipped');
    final ownedRaw = prefs.getString('char_owned');

    if (equippedRaw != null) {
      final map = jsonDecode(equippedRaw) as Map<String, dynamic>;
      _equipped = {
        for (final entry in map.entries)
          ItemCategory.values.byName(entry.key): entry.value as String?,
      };
    } else {
      // Default: equip all common (price == 0) items
      _equipped = {
        for (final item in defaultItemCatalog.where((i) => i.price == 0))
          item.category: item.id,
      };
    }

    if (ownedRaw != null) {
      _ownedIds = Set<String>.from(jsonDecode(ownedRaw) as List);
    } else {
      // Own all free items by default
      _ownedIds = defaultItemCatalog
          .where((i) => i.price == 0)
          .map((i) => i.id)
          .toSet();
    }

    notifyListeners();
  }

  Future<void> equip(String itemId) async {
    final item = defaultItemCatalog.where((i) => i.id == itemId).firstOrNull;
    if (item == null || !isOwned(itemId)) return;
    _equipped[item.category] = itemId;
    notifyListeners();
    await _save();
  }

  Future<void> unequip(ItemCategory category) async {
    _equipped[category] = null;
    notifyListeners();
    await _save();
  }

  // Returns false if not enough points
  Future<bool> purchase(String itemId, int currentPoints, void Function(int delta) spendPoints) async {
    final item = defaultItemCatalog.where((i) => i.id == itemId).firstOrNull;
    if (item == null || isOwned(itemId)) return false;
    if (currentPoints < item.price) return false;
    _ownedIds.add(itemId);
    spendPoints(-item.price);
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final equippedMap = {
      for (final entry in _equipped.entries)
        if (entry.value != null) entry.key.name: entry.value,
    };
    await prefs.setString('char_equipped', jsonEncode(equippedMap));
    await prefs.setString('char_owned', jsonEncode(_ownedIds.toList()));
  }
}
