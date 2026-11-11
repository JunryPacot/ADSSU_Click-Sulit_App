import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../services/firebase_service.dart';
import 'item_repository.dart';

class FirebaseItemRepository implements ItemRepository {
  final FirebaseFirestore? _customFirestore;

  FirebaseItemRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (FirebaseService().isInitialized) {
      try {
        return FirebaseFirestore.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Stream<List<ItemModel>> streamItems() {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<ItemModel>> getItems() async {
    final fs = _firestore;
    if (fs == null) return [];
    final snapshot = await fs
        .collection('items')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ItemModel?> getItemById(String id) async {
    final fs = _firestore;
    if (fs == null) return null;
    final doc = await fs.collection('items').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return ItemModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> createItem(ItemModel item) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('items').doc(item.id).set(item.toMap());
  }

  @override
  Future<void> updateItem(ItemModel item) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('items').doc(item.id).update(item.toMap());
  }

  @override
  Future<void> deleteItem(String id) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('items').doc(id).delete();
  }

  @override
  Future<void> toggleSaveItem(String itemId, String userId) async {
    final fs = _firestore;
    if (fs == null) return;
    final ref = fs.collection('users').doc(userId).collection('saved_items').doc(itemId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
