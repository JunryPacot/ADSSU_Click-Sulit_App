import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/firebase_service.dart';
import 'item_repository.dart';

class RtdbItemRepository implements ItemRepository {
  DatabaseReference get _ref => FirebaseService().database.ref('items');
  DatabaseReference get _savedRef => FirebaseService().database.ref('saved_items');

  @override
  Stream<List<ItemModel>> streamItems() {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <ItemModel>[];
      final items = <ItemModel>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              items.add(ItemModel.fromMap(m, key.toString()));
            } catch (e) {
              if (kDebugMode) debugPrint('[RtdbItemRepository] Parse error: $e');
            }
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final map = val[i];
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              items.add(ItemModel.fromMap(m, 'item_$i'));
            } catch (_) {}
          }
        }
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  @override
  Future<List<ItemModel>> getItems() async {
    if (!FirebaseService().isInitialized) return [];
    try {
      final snapshot = await _ref.get();
      final val = snapshot.value;
      if (val == null) return [];
      final items = <ItemModel>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              items.add(ItemModel.fromMap(m, key.toString()));
            } catch (_) {}
          }
        });
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final map = val[i];
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              items.add(ItemModel.fromMap(m, 'item_$i'));
            } catch (_) {}
          }
        }
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      if (kDebugMode) debugPrint('[RtdbItemRepository] getItems error: $e');
      return [];
    }
  }

  @override
  Future<ItemModel?> getItemById(String id) async {
    if (!FirebaseService().isInitialized) return null;
    try {
      final snapshot = await _ref.child(id).get();
      final val = snapshot.value;
      if (val == null || val is! Map) return null;
      final m = <String, dynamic>{};
      val.forEach((k, v) {
        if (k != null) m[k.toString()] = v;
      });
      return ItemModel.fromMap(m, id);
    } catch (e) {
      if (kDebugMode) debugPrint('[RtdbItemRepository] getItemById error: $e');
      return null;
    }
  }

  @override
  Future<void> createItem(ItemModel item) async {
    if (!FirebaseService().isInitialized) return;
    final data = item.toMap();
    data.removeWhere((key, value) => value == null);
    await _ref.child(item.id).set(data);
    if (kDebugMode) debugPrint('[RtdbItemRepository] Item saved to RTDB: ${item.id}');
  }

  @override
  Future<void> updateItem(ItemModel item) async {
    if (!FirebaseService().isInitialized) return;
    final data = item.toMap();
    data.removeWhere((key, value) => value == null);
    await _ref.child(item.id).update(data);
  }

  @override
  Future<void> deleteItem(String id) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(id).remove();
  }

  @override
  Future<void> toggleSaveItem(String itemId, String userId) async {
    if (!FirebaseService().isInitialized) return;
    final userSavedRef = _savedRef.child(userId).child(itemId);
    final snap = await userSavedRef.get();
    if (snap.exists) {
      await userSavedRef.remove();
    } else {
      await userSavedRef.set({
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }
}
