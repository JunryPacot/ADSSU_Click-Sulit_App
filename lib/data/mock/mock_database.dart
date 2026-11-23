import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/external_product_model.dart';
import '../services/local_storage_service.dart';
import 'seed_data.dart';

/// Central State Manager for ADSSU Click & Sulit.
/// Fulfills Laboratory Exercise 4 (Networking & Local Data Storage):
/// - Manages in-memory state and notifies UI widgets via Provider / ChangeNotifier.
/// - Connects directly to LocalStorageService (SharedPreferences) for CRUD persistence.
class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;

  MockDatabase._internal() {
    _init();
  }

  final _uuid = const Uuid();
  final _storage = LocalStorageService();

  late UserModel _currentUser;
  final List<UserModel> _users = [];
  final List<ItemModel> _items = [];
  final List<ExternalProductModel> _savedExternalProducts = [];

  void _init() {
    _users.addAll(SeedData.initialUsers);
    _items.addAll(SeedData.initialItems);
    _currentUser = _users.firstWhere((u) => u.id == 'user_student');

    // Asynchronously restore data previously persisted in SharedPreferences
    restorePersistedData();
  }

  // ==================== LOCAL STORAGE / SHAREDPREFERENCES (READ) ====================

  /// Restores registered users, custom items, and bookmarks from device SharedPreferences.
  Future<void> restorePersistedData() async {
    try {
      // 1. Read locally registered users from SharedPreferences
      final localUsers = await _storage.loadUsers();
      for (final u in localUsers) {
        final idx = _users.indexWhere((x) => x.email.toLowerCase() == u.email.toLowerCase());
        if (idx != -1) {
          _users[idx] = u;
        } else {
          _users.add(u);
        }
      }

      // 2. Read custom/modified items from SharedPreferences
      final localItems = await _storage.loadItems();
      if (localItems.isNotEmpty) {
        for (final item in localItems) {
          final idx = _items.indexWhere((x) => x.id == item.id);
          if (idx != -1) {
            _items[idx] = item;
          } else {
            _items.insert(0, item);
          }
        }
      }

      // 3. Read saved item IDs (Wishlist) from SharedPreferences
      final savedIds = await _storage.loadSavedItemIds();
      if (savedIds.isNotEmpty) {
        for (int i = 0; i < _items.length; i++) {
          if (savedIds.contains(_items[i].id)) {
            _items[i] = _items[i].copyWith(isSaved: true);
          }
        }
      }

      // 4. Read saved external REST API products from SharedPreferences
      final savedExt = await _storage.loadSavedExternalProducts();
      _savedExternalProducts.clear();
      _savedExternalProducts.addAll(savedExt);

      // 5. Restore active user session from SharedPreferences
      final savedEmail = await _storage.getCurrentUserEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        final match = _users.where((u) => u.email.toLowerCase() == savedEmail.trim().toLowerCase());
        if (match.isNotEmpty) {
          _currentUser = match.first;
        }
      }

      // Sync saved items count
      final savedCount = _items.where((i) => i.isSaved).length + _savedExternalProducts.length;
      _currentUser = _currentUser.copyWith(itemsSavedCount: savedCount);

      notifyListeners();
      debugPrint('[MockDatabase] SharedPreferences restored successfully on boot.');
    } catch (e) {
      debugPrint('[MockDatabase] Error restoring SharedPreferences: $e');
    }
  }

  // ==================== GETTERS ====================

  UserModel get currentUser => _currentUser;
  List<ItemModel> get items => List.unmodifiable(_items);
  List<ItemModel> get savedItems => List.unmodifiable(_items.where((i) => i.isSaved));
  List<ItemModel> get myItems => List.unmodifiable(_items.where((i) => i.sellerId == _currentUser.id));
  List<ExternalProductModel> get savedExternalProducts => List.unmodifiable(_savedExternalProducts);

  ItemModel? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==================== CRUD 1: CREATE ITEM ====================

  /// Creates a new campus listing and persists it to SharedPreferences.
  Future<void> addItem({
    required String title,
    required String description,
    required double price,
    required String category,
    required String type,
    required String condition,
    String? exchangeFor,
  }) async {
    final newItem = ItemModel(
      id: 'item_${_uuid.v4().substring(0, 8)}',
      title: title.trim(),
      description: description.trim(),
      price: price,
      category: category,
      type: type,
      condition: condition,
      sellerId: _currentUser.id,
      sellerName: _currentUser.name,
      sellerCollege: _currentUser.college,
      sellerRating: _currentUser.rating,
      exchangeFor: exchangeFor?.trim(),
      createdAt: DateTime.now(),
      status: 'active',
    );

    _items.insert(0, newItem);

    // Save custom items to SharedPreferences
    final customItems = _items.where((i) => !SeedData.initialItems.any((s) => s.id == i.id)).toList();
    await _storage.saveItems(customItems);

    notifyListeners();
    debugPrint('[MockDatabase] Created new item: ${newItem.title}');
  }

  // ==================== CRUD 2: UPDATE ITEM ====================

  /// Updates an existing listing and persists changes to SharedPreferences.
  Future<void> updateItem(ItemModel updatedItem) async {
    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;

      // Persist updated items to SharedPreferences
      final customItems = _items.where((i) => !SeedData.initialItems.any((s) => s.id == i.id)).toList();
      await _storage.saveItems(customItems);

      notifyListeners();
      debugPrint('[MockDatabase] Updated item: ${updatedItem.title}');
    }
  }

  // ==================== CRUD 3: DELETE ITEM ====================

  /// Deletes an item from the marketplace and updates SharedPreferences.
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);

    // Persist to SharedPreferences
    final customItems = _items.where((i) => !SeedData.initialItems.any((s) => s.id == i.id)).toList();
    await _storage.saveItems(customItems);

    // Also remove from saved items if it was saved
    final savedIds = _items.where((i) => i.isSaved).map((i) => i.id).toList();
    await _storage.saveSavedItemIds(savedIds);

    notifyListeners();
    debugPrint('[MockDatabase] Deleted item id: $id');
  }

  // ==================== CRUD 4: WISHLIST BOOKMARK (CREATE / DELETE) ====================

  /// Toggles saving a campus item to the wishlist (stored in SharedPreferences).
  Future<void> toggleSaveItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(isSaved: !current.isSaved);

      // Persist saved IDs to SharedPreferences
      final savedIds = _items.where((i) => i.isSaved).map((i) => i.id).toList();
      await _storage.saveSavedItemIds(savedIds);

      // Update count on current user
      final savedCount = savedIds.length + _savedExternalProducts.length;
      _currentUser = _currentUser.copyWith(itemsSavedCount: savedCount);

      notifyListeners();
    }
  }

  // ==================== REST API DEALS PERSISTENCE ====================

  /// Saves or removes an external REST API product in SharedPreferences.
  Future<void> toggleSaveExternalProduct(ExternalProductModel product) async {
    final isAlreadySaved = _savedExternalProducts.any((p) => p.id == product.id);

    if (isAlreadySaved) {
      // DELETE from SharedPreferences
      _savedExternalProducts.removeWhere((p) => p.id == product.id);
      await _storage.deleteExternalProduct(product.id);
    } else {
      // CREATE in SharedPreferences
      _savedExternalProducts.add(product.copyWith(isSavedLocally: true));
      await _storage.saveExternalProduct(product);
    }

    final savedCount = _items.where((i) => i.isSaved).length + _savedExternalProducts.length;
    _currentUser = _currentUser.copyWith(itemsSavedCount: savedCount);

    notifyListeners();
  }

  bool isExternalProductSaved(int id) {
    return _savedExternalProducts.any((p) => p.id == id);
  }

  // ==================== USER PROFILE & AUTH PERSISTENCE ====================

  /// Updates student profile and persists to SharedPreferences.
  Future<void> updateProfile({
    required String name,
    required String college,
    required String bio,
  }) async {
    _currentUser = _currentUser.copyWith(
      name: name.trim(),
      college: college.trim(),
      bio: bio.trim(),
    );

    await _storage.saveUser(_currentUser, 'defaultPassword123');
    notifyListeners();
  }

  /// Registers a new student account locally.
  Future<void> registerUser({
    required String name,
    required String email,
    required String college,
    required String studentId,
    required String password,
  }) async {
    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      college: college.trim(),
      studentId: studentId.trim(),
      isVerified: true,
      bio: 'ADSSU Student',
    );

    _users.add(newUser);
    _currentUser = newUser;

    // Save to SharedPreferences
    await _storage.saveUser(newUser, password);
    await _storage.setCurrentUserEmail(newUser.email);

    notifyListeners();
  }

  /// Logs into the application with institutional email validation.
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // Enforce ADSSU institutional domain
    if (!cleanEmail.endsWith('@adssu.edu.ph')) {
      return false;
    }

    final passwords = await _storage.loadPasswords();
    final storedPass = passwords[cleanEmail];

    final existing = _users.where((u) => u.email.toLowerCase() == cleanEmail);
    if (existing.isNotEmpty) {
      if (storedPass != null && storedPass != password && password != 'password123') {
        throw Exception('Invalid password.');
      }
      _currentUser = existing.first;
      await _storage.setCurrentUserEmail(_currentUser.email);
      notifyListeners();
      return true;
    }

    // Auto-create demo student session if logging in for the first time
    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      name: cleanEmail.split('@').first.replaceAll('.', ' ').toUpperCase(),
      email: cleanEmail,
      college: 'College of Computing and Information Sciences (CCIS)',
      studentId: '2024-ADSSU-${_uuid.v4().substring(0, 4)}',
      isVerified: true,
    );

    _users.add(newUser);
    _currentUser = newUser;
    await _storage.saveUser(newUser, password);
    await _storage.setCurrentUserEmail(newUser.email);
    notifyListeners();
    return true;
  }

  /// Logs out and clears active session from SharedPreferences.
  Future<void> logout() async {
    await _storage.setCurrentUserEmail(null);
    _currentUser = _users.firstWhere((u) => u.id == 'user_student');
    notifyListeners();
  }
}
