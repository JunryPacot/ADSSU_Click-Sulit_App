import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/external_product_model.dart';

/// Central service for persisting application data locally on the device using SharedPreferences.
/// Fulfills Laboratory Exercise 4 Task 2 requirements:
/// - Save relevant records locally (Create)
/// - Retrieve saved info when app reopened (Read)
/// - Update stored info when modified (Update)
/// - Delete stored records when requested (Delete)
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _keyRegisteredUsers = 'adssu_registered_users_v2';
  static const String _keyUserPasswords = 'adssu_user_passwords_v2';
  static const String _keyCurrentEmail = 'current_user_email';
  static const String _keyCustomItems = 'adssu_local_items_v2';
  static const String _keySavedItemIds = 'adssu_saved_item_ids_v2';
  static const String _keySavedExternalProducts = 'adssu_saved_external_products_v2';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== AUTH & USER PERSISTENCE ====================

  /// Saves or updates a registered user in local storage.
  Future<void> saveUser(UserModel user, String password) async {
    try {
      final prefs = await _getPrefs();
      final users = await loadUsers();
      final index = users.indexWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
      if (index != -1) {
        users[index] = user;
      } else {
        users.add(user);
      }

      final jsonList = users.map((u) {
        final m = u.toMap();
        m['id'] = u.id;
        return m;
      }).toList();

      await prefs.setString(_keyRegisteredUsers, jsonEncode(jsonList));

      // Save password mapping
      final passwords = await loadPasswords();
      passwords[user.email.toLowerCase()] = password;
      await prefs.setString(_keyUserPasswords, jsonEncode(passwords));

      debugPrint('[LocalStorage] Saved user: ${user.email}');
    } catch (e) {
      debugPrint('[LocalStorage] Error saving user: $e');
    }
  }

  /// Loads all locally registered users.
  Future<List<UserModel>> loadUsers() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keyRegisteredUsers);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? 'user_${map['studentId']}';
        return UserModel.fromMap(map, id);
      }).toList();
    } catch (e) {
      debugPrint('[LocalStorage] Error loading users: $e');
      return [];
    }
  }

  /// Loads password map for registered accounts.
  Future<Map<String, String>> loadPasswords() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keyUserPasswords);
      if (raw == null || raw.isEmpty) return {};

      final decoded = jsonDecode(raw) as Map;
      return decoded.map((k, v) => MapEntry(k.toString().toLowerCase(), v.toString()));
    } catch (e) {
      return {};
    }
  }

  /// Persists current logged-in user email.
  Future<void> setCurrentUserEmail(String? email) async {
    final prefs = await _getPrefs();
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyCurrentEmail, email);
    } else {
      await prefs.remove(_keyCurrentEmail);
    }
  }

  /// Gets current logged-in user email.
  Future<String?> getCurrentUserEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyCurrentEmail);
  }

  // ==================== MARKETPLACE ITEMS PERSISTENCE ====================

  /// Persists the list of marketplace items (custom, created, edited).
  Future<void> saveItems(List<ItemModel> items) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = items.map((item) {
        final m = item.toMap();
        m['id'] = item.id;
        return m;
      }).toList();
      await prefs.setString(_keyCustomItems, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[LocalStorage] Error saving items: $e');
    }
  }

  /// Loads persisted items from local storage.
  Future<List<ItemModel>> loadItems() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keyCustomItems);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? 'item_local';
        return ItemModel.fromMap(map, id);
      }).toList();
    } catch (e) {
      debugPrint('[LocalStorage] Error loading items: $e');
      return [];
    }
  }

  // ==================== SAVED / WISHLIST ITEMS ====================

  /// Saves bookmarked/saved campus item IDs.
  Future<void> saveSavedItemIds(List<String> ids) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setStringList(_keySavedItemIds, ids);
    } catch (e) {
      debugPrint('[LocalStorage] Error saving wishlist IDs: $e');
    }
  }

  /// Loads saved campus item IDs.
  Future<List<String>> loadSavedItemIds() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(_keySavedItemIds) ?? [];
    } catch (e) {
      return [];
    }
  }

  // ==================== EXTERNAL API PRODUCTS PERSISTENCE (Task 1 + Task 2) ====================

  /// Saves external product saved from API to device storage.
  Future<void> saveExternalProduct(ExternalProductModel product) async {
    try {
      final prefs = await _getPrefs();
      final list = await loadSavedExternalProducts();
      final index = list.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        list[index] = product.copyWith(isSavedLocally: true);
      } else {
        list.add(product.copyWith(isSavedLocally: true));
      }
      final jsonList = list.map((p) => p.toJson()).toList();
      await prefs.setString(_keySavedExternalProducts, jsonEncode(jsonList));
      debugPrint('[LocalStorage] Saved external product #${product.id}');
    } catch (e) {
      debugPrint('[LocalStorage] Error saving external product: $e');
    }
  }

  /// Deletes an external product from local storage.
  Future<void> deleteExternalProduct(int productId) async {
    try {
      final prefs = await _getPrefs();
      final list = await loadSavedExternalProducts();
      list.removeWhere((p) => p.id == productId);
      final jsonList = list.map((p) => p.toJson()).toList();
      await prefs.setString(_keySavedExternalProducts, jsonEncode(jsonList));
      debugPrint('[LocalStorage] Deleted external product #$productId');
    } catch (e) {
      debugPrint('[LocalStorage] Error deleting external product: $e');
    }
  }

  /// Loads all saved external products from local storage.
  Future<List<ExternalProductModel>> loadSavedExternalProducts() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keySavedExternalProducts);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ExternalProductModel.fromJson(map).copyWith(isSavedLocally: true);
      }).toList();
    } catch (e) {
      debugPrint('[LocalStorage] Error loading external products: $e');
      return [];
    }
  }
}
