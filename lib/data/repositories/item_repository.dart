import '../models/item_model.dart';

abstract class ItemRepository {
  Stream<List<ItemModel>> streamItems();
  Future<List<ItemModel>> getItems();
  Future<ItemModel?> getItemById(String id);
  Future<void> createItem(ItemModel item);
  Future<void> updateItem(ItemModel item);
  Future<void> deleteItem(String id);
  Future<void> toggleSaveItem(String itemId, String userId);
}

