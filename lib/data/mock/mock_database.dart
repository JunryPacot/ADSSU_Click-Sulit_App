import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/campus_constants.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/request_model.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';
import '../models/report_model.dart';
import '../models/payment_model.dart';
import '../models/external_product_model.dart';
import '../services/local_storage_service.dart';
import 'seed_data.dart';

/// Central State and Data Manager for ADSSU Click & Sulit.
/// Operates locally using LocalStorageService (SharedPreferences) for data persistence.
/// Completely decoupled from remote databases/Firebase.
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
  final List<RequestModel> _requests = [];
  final List<ChatThread> _chats = [];
  final List<ReviewModel> _reviews = [];
  final List<ReportModel> _reports = [];
  final List<PaymentModel> _payments = [];
  final List<ExternalProductModel> _savedExternalProducts = [];

  // OTP in-memory registry for verification & password reset
  final Map<String, String> _pendingOtps = {};

  // Current session meet-up selection state
  String _selectedBuilding = CampusConstants.meetUpBuildings.first;
  String _specificLocationText = '';
  String? _meetUpPhotoPath;

  void _init() {
    _users.addAll(SeedData.initialUsers);
    _items.addAll(SeedData.initialItems);
    _requests.addAll(SeedData.initialRequests);
    _chats.addAll(SeedData.initialChats);
    _reviews.addAll(SeedData.initialReviews);
    _reports.addAll(SeedData.initialReports);
    _payments.addAll(SeedData.initialPayments);
    _currentUser = _users.firstWhere((u) => u.id == 'user_student');

    // Asynchronously restore persisted data from SharedPreferences
    restorePersistedData();
  }

  /// Restores registered users, customized items, wishlist bookmarks, and active session
  Future<void> restorePersistedData() async {
    try {
      // 1. Load locally registered users
      final localUsers = await _storage.loadUsers();
      for (final u in localUsers) {
        final idx = _users.indexWhere((x) => x.email.toLowerCase() == u.email.toLowerCase());
        if (idx != -1) {
          _users[idx] = u;
        } else {
          _users.add(u);
        }
      }

      // 2. Load custom/modified items
      final localItems = await _storage.loadItems();
      if (localItems.isNotEmpty) {
        // Prepend custom items
        for (final item in localItems) {
          final idx = _items.indexWhere((x) => x.id == item.id);
          if (idx != -1) {
            _items[idx] = item;
          } else {
            _items.insert(0, item);
          }
        }
      }

      // 3. Load saved item IDs (Wishlist)
      final savedIds = await _storage.loadSavedItemIds();
      if (savedIds.isNotEmpty) {
        for (int i = 0; i < _items.length; i++) {
          if (savedIds.contains(_items[i].id)) {
            _items[i] = _items[i].copyWith(isSaved: true);
          }
        }
      }

      // 4. Load saved external API products
      final savedExt = await _storage.loadSavedExternalProducts();
      _savedExternalProducts.clear();
      _savedExternalProducts.addAll(savedExt);

      // 5. Restore active user session
      final savedEmail = await _storage.getCurrentUserEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        final clean = savedEmail.trim().toLowerCase();
        final match = _users.where((u) => u.email.toLowerCase() == clean);
        if (match.isNotEmpty) {
          _currentUser = match.first;
        }
      }

      // Sync items saved count for current user
      final savedCount = _items.where((i) => i.isSaved).length + _savedExternalProducts.length;
      _currentUser = _currentUser.copyWith(itemsSavedCount: savedCount);

      notifyListeners();
      debugPrint('[MockDatabase] Successfully restored persistent data from local storage.');
    } catch (e) {
      debugPrint('[MockDatabase] Error restoring local data: $e');
    }
  }

  // ==================== GETTERS ====================

  UserModel get currentUser => _currentUser;
  bool get isAdmin => _currentUser.email.toLowerCase() == CampusConstants.demoAdminEmail.toLowerCase();
  List<UserModel> get users => List.unmodifiable(_users);
  List<ItemModel> get items => List.unmodifiable(_items);
  List<RequestModel> get requests => List.unmodifiable(_requests);
  List<ChatThread> get chats => List.unmodifiable(_chats);
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  List<ReportModel> get reports => List.unmodifiable(_reports);
  List<PaymentModel> get payments => List.unmodifiable(_payments);
  List<ExternalProductModel> get savedExternalProducts => List.unmodifiable(_savedExternalProducts);

  ItemModel? getItemById(String id) {
    final match = _items.where((i) => i.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  UserModel? getUserById(String id) {
    final match = _users.where((u) => u.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  RequestModel? getRequestById(String id) {
    final match = _requests.where((r) => r.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  List<ItemModel> getMyListings([String? userId]) {
    final uid = userId ?? _currentUser.id;
    return _items.where((i) => i.sellerId == uid).toList();
  }

  String get selectedBuilding => _selectedBuilding;
  String get specificLocationText => _specificLocationText;
  String? get meetUpPhotoPath => _meetUpPhotoPath;

  // ==================== AUTHENTICATION & SESSION ====================

  /// Validates user credentials against local registered accounts & demo users
  Future<bool> login(String email, String password) async {
    final clean = email.trim().toLowerCase();
    if (!clean.endsWith('@adssu.edu.ph')) {
      return false;
    }

    // Check account existence
    final isRegistered = await isEmailRegistered(clean);
    final isAdminUser = clean == CampusConstants.demoAdminEmail.toLowerCase();

    if (!isRegistered && !isAdminUser) {
      throw Exception('No account found for $clean. You haven\'t registered this email yet. Please create an account first.');
    }

    // Verify password
    final passwords = await _storage.loadPasswords();
    final storedPassword = passwords[clean];

    bool isPasswordValid = false;
    if (storedPassword != null && storedPassword == password) {
      isPasswordValid = true;
    } else if (clean == CampusConstants.demoAdminEmail.toLowerCase()) {
      isPasswordValid = (password == CampusConstants.adminPassword || password == 'admin123');
    } else if (password == 'password123' || password == 'AdssuSecure123!') {
      // Default fallback demo credentials
      isPasswordValid = true;
    }

    if (!isPasswordValid) {
      throw Exception('Incorrect password. Please verify your password or tap Forgot Password.');
    }

    // Find and set current user
    final idx = _users.indexWhere((u) => u.email.toLowerCase() == clean);
    if (idx != -1) {
      _currentUser = _users[idx];
    } else {
      _currentUser = UserModel(
        id: 'user_${_uuid.v4().substring(0, 8)}',
        name: clean.split('@').first.toUpperCase(),
        email: clean,
        college: CampusConstants.colleges.first,
        studentId: '2024-ADSSU-0001',
        isVerified: true,
      );
      _users.add(_currentUser);
    }

    await _storage.setCurrentUserEmail(clean);
    notifyListeners();
    return true;
  }

  /// Logs out current user and clears session
  void logout() {
    _currentUser = UserModel.guest;
    _storage.setCurrentUserEmail(null);
    notifyListeners();
  }

  /// Registers a new user and persists account to SharedPreferences
  Future<void> registerUser({
    required String name,
    required String email,
    required String college,
    required String studentId,
    required String password,
    String? profilePhoto,
  }) async {
    final clean = email.trim().toLowerCase();
    if (!clean.endsWith('@adssu.edu.ph')) {
      throw ArgumentError('Only official @adssu.edu.ph institutional emails are permitted.');
    }

    final isExisting = _users.any((u) => u.email.toLowerCase() == clean && u.id != 'user_guest');
    if (isExisting) {
      throw Exception('This email is already registered. Please sign in instead.');
    }

    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      email: clean,
      college: college,
      studentId: studentId.trim(),
      isVerified: true,
      isSellerMember: false,
      profilePhoto: profilePhoto,
      bio: 'ADSSU Student • $college',
    );

    // Save to local storage for permanent persistence across app restarts
    await _storage.saveUser(newUser, password);
    await _storage.setCurrentUserEmail(clean);

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    debugPrint('[MockDatabase] User successfully registered and persisted locally: $clean');
  }

  /// Checks whether an email address is already registered
  Future<bool> isEmailRegistered(String email) async {
    final clean = email.trim().toLowerCase();
    final local = _users.any((u) => u.email.toLowerCase() == clean && u.id != 'user_guest');
    if (local) return true;

    final storedUsers = await _storage.loadUsers();
    return storedUsers.any((u) => u.email.toLowerCase() == clean);
  }

  // ==================== OTP & VERIFICATION ====================

  /// Generates a 6-digit OTP code stored in memory
  Future<String> sendVerificationOtp(String email) async {
    final clean = email.trim().toLowerCase();
    final rng = Random();
    final code = (100000 + rng.nextInt(900000)).toString();
    _pendingOtps[clean] = code;
    debugPrint('[MockDatabase OTP] Generated verification code for $clean: $code');
    return code;
  }

  /// Verifies entered OTP code against memory or demo default
  Future<bool> verifyEmailOtp({
    required String email,
    required String enteredCode,
  }) async {
    final clean = email.trim().toLowerCase();
    final expectedCode = _pendingOtps[clean];

    // Accept generated code or fallback default '123456' for ease of testing
    if (enteredCode == expectedCode || enteredCode == '123456') {
      _pendingOtps.remove(clean);
      _currentUser = _currentUser.copyWith(isVerified: true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String> sendForgotPasswordOtp(String email) async {
    return sendVerificationOtp(email);
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final clean = email.trim().toLowerCase();
    final passwords = await _storage.loadPasswords();
    passwords[clean] = newPassword;

    final idx = _users.indexWhere((u) => u.email.toLowerCase() == clean);
    if (idx != -1) {
      await _storage.saveUser(_users[idx], newPassword);
    }
    notifyListeners();
    return true;
  }

  // ==================== PROFILE MANAGEMENT (UPDATE CRUD) ====================

  /// Updates user profile and persists changes locally
  Future<void> updateProfile({
    String? name,
    String? college,
    String? studentId,
    String? bio,
    String? profilePhoto,
  }) async {
    _currentUser = _currentUser.copyWith(
      name: name,
      college: college,
      studentId: studentId,
      bio: bio,
      profilePhoto: profilePhoto,
    );

    final idx = _users.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _users[idx] = _currentUser;
    }

    final passwords = await _storage.loadPasswords();
    final pass = passwords[_currentUser.email.toLowerCase()] ?? 'password123';
    await _storage.saveUser(_currentUser, pass);

    notifyListeners();
  }

  void activateFreeSellerMembership() {
    _currentUser = _currentUser.copyWith(isSellerMember: true);
    final idx = _users.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) _users[idx] = _currentUser;
    notifyListeners();
  }

  // ==================== MARKETPLACE ITEMS (CRUD) ====================

  /// Toggle saving/bookmarking an item (Wishlist persistence)
  void toggleSaveItem(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final item = _items[index];
      _items[index] = item.copyWith(isSaved: !item.isSaved);

      // Save updated wishlist IDs locally
      final savedIds = _items.where((i) => i.isSaved).map((i) => i.id).toList();
      _storage.saveSavedItemIds(savedIds);

      final totalSaved = savedIds.length + _savedExternalProducts.length;
      _currentUser = _currentUser.copyWith(itemsSavedCount: totalSaved);
      notifyListeners();
    }
  }

  /// Create new item listing and persist locally (CREATE CRUD)
  Future<bool> addItem({
    required String title,
    required String description,
    required double price,
    required String category,
    required String type,
    required String condition,
    String? exchangeFor,
    String? meetUpPreference,
    String? imageUrl,
    List<String> images = const [],
    int quantity = 1,
  }) async {
    final newItem = ItemModel(
      id: 'item_${_uuid.v4().substring(0, 8)}',
      title: title,
      description: description,
      price: price,
      category: category,
      type: type,
      condition: condition,
      sellerId: _currentUser.id,
      sellerName: _currentUser.name,
      sellerCollege: _currentUser.college,
      sellerRating: _currentUser.rating,
      createdAt: DateTime.now(),
      status: 'active',
      imageUrl: imageUrl ?? (images.isNotEmpty ? images.first : null),
      images: images,
      quantity: quantity,
      exchangeFor: exchangeFor,
      meetUpPreference: meetUpPreference,
    );

    _items.insert(0, newItem);
    await _storage.saveItems(_items);
    notifyListeners();
    return true;
  }

  /// Update an existing item (UPDATE CRUD)
  void updateItem(ItemModel updated) {
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      _storage.saveItems(_items);
      notifyListeners();
    }
  }

  /// Delete an item listing (DELETE CRUD)
  void deleteItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    _storage.saveItems(_items);

    // Also remove from saved items if present
    final savedIds = _items.where((i) => i.isSaved).map((i) => i.id).toList();
    _storage.saveSavedItemIds(savedIds);

    notifyListeners();
  }

  void markItemDone(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(status: 'completed');
      _storage.saveItems(_items);
      notifyListeners();
    }
  }

  // ==================== EXTERNAL API PRODUCTS PERSISTENCE (Task 1 + Task 2) ====================

  /// Checks if an external API product is saved in local storage
  bool isExternalProductSaved(int productId) {
    return _savedExternalProducts.any((p) => p.id == productId);
  }

  /// Toggles saving an external product from API into local device storage
  Future<void> toggleSaveExternalProduct(ExternalProductModel product) async {
    final isSaved = isExternalProductSaved(product.id);
    if (isSaved) {
      _savedExternalProducts.removeWhere((p) => p.id == product.id);
      await _storage.deleteExternalProduct(product.id);
    } else {
      final savedProduct = product.copyWith(isSavedLocally: true);
      _savedExternalProducts.add(savedProduct);
      await _storage.saveExternalProduct(savedProduct);
    }

    final totalSaved = _items.where((i) => i.isSaved).length + _savedExternalProducts.length;
    _currentUser = _currentUser.copyWith(itemsSavedCount: totalSaved);
    notifyListeners();
  }

  /// Deletes an external product record directly from local storage
  Future<void> deleteExternalProduct(int productId) async {
    _savedExternalProducts.removeWhere((p) => p.id == productId);
    await _storage.deleteExternalProduct(productId);
    final totalSaved = _items.where((i) => i.isSaved).length + _savedExternalProducts.length;
    _currentUser = _currentUser.copyWith(itemsSavedCount: totalSaved);
    notifyListeners();
  }

  // ==================== MEET-UP & TRANSACTION FLOW ====================

  void setMeetUpDetails({
    required String building,
    required String specificLocation,
    String? photoPath,
  }) {
    _selectedBuilding = building;
    _specificLocationText = specificLocation;
    _meetUpPhotoPath = photoPath;
    notifyListeners();
  }

  Future<bool> sendRequest({
    required String itemId,
    required String type,
    String? note,
    String? exchangeOfferedItemId,
    String? exchangeOfferedTitle,
    String? exchangeOfferedCondition,
    double? cashAddition,
    String? donationReason,
    String? urgencyLevel,
  }) async {
    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return false;
    final item = _items[itemIndex];

    final newRequest = RequestModel(
      id: 'req_${_uuid.v4().substring(0, 8)}',
      itemId: itemId,
      itemTitle: item.title,
      itemPrice: item.price,
      itemType: type,
      buyerId: _currentUser.id,
      buyerName: _currentUser.name,
      buyerCollege: _currentUser.college,
      sellerId: item.sellerId,
      sellerName: item.sellerName,
      offeredItemId: exchangeOfferedItemId,
      offeredItemTitle: exchangeOfferedTitle,
      meetUpBuilding: _selectedBuilding,
      exactLocation: _specificLocationText,
      hasLocationPhoto: _meetUpPhotoPath != null,
      status: 'pending',
      createdAt: DateTime.now(),
      commissionAmount: item.price * 0.03,
      sellerEarnings: item.price * 0.97,
    );

    _requests.insert(0, newRequest);
    notifyListeners();
    return true;
  }

  Future<bool> createRequest({
    required ItemModel item,
    String? note,
    String? offeredItemId,
    String? offeredItemTitle,
    String? exchangeOfferedItemId,
    String? exchangeOfferedTitle,
    String? exchangeOfferedCondition,
    double? cashAddition,
    String? donationReason,
    String? urgencyLevel,
  }) async {
    return sendRequest(
      itemId: item.id,
      type: item.type,
      note: note,
      exchangeOfferedItemId: offeredItemId ?? exchangeOfferedItemId,
      exchangeOfferedTitle: offeredItemTitle ?? exchangeOfferedTitle,
      exchangeOfferedCondition: exchangeOfferedCondition,
      cashAddition: cashAddition,
      donationReason: donationReason,
      urgencyLevel: urgencyLevel,
    );
  }

  void acceptRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: 'accepted');
      final itemIdx = _items.indexWhere((i) => i.id == _requests[index].itemId);
      if (itemIdx != -1) {
        _items[itemIdx] = _items[itemIdx].copyWith(status: 'reserved');
        _storage.saveItems(_items);
      }
      notifyListeners();
    }
  }

  void declineRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: 'declined');
      notifyListeners();
    }
  }

  void completeTransaction(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: 'completed');
      final itemIdx = _items.indexWhere((i) => i.id == _requests[index].itemId);
      if (itemIdx != -1) {
        final currentQty = _items[itemIdx].quantity;
        if (currentQty <= 1) {
          _items[itemIdx] = _items[itemIdx].copyWith(
            status: 'completed',
            quantity: 0,
          );
        } else {
          _items[itemIdx] = _items[itemIdx].copyWith(
            quantity: currentQty - 1,
          );
        }
        _storage.saveItems(_items);
      }
      _currentUser = _currentUser.copyWith(
        dealsCompleted: _currentUser.dealsCompleted + 1,
      );
      notifyListeners();
    }
  }

  // ==================== CHAT & MESSAGING ====================

  void sendMessage(String threadId, String text) {
    final index = _chats.indexWhere((c) => c.id == threadId);
    final newMsg = ChatMessage(
      id: 'msg_${_uuid.v4().substring(0, 8)}',
      senderId: _currentUser.id,
      senderName: _currentUser.name,
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    if (index != -1) {
      final thread = _chats[index];
      final updatedMessages = List<ChatMessage>.from(thread.messages)..add(newMsg);
      _chats[index] = thread.copyWith(
        messages: updatedMessages,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
    } else {
      _chats.insert(
        0,
        ChatThread(
          id: threadId,
          otherUserId: 'user_student',
          otherUserName: 'Fellow Student',
          otherUserCollege: 'CA',
          relatedItemTitle: 'Campus Item',
          relatedItemId: 'item_1',
          lastMessage: text,
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          messages: [newMsg],
        ),
      );
    }
    notifyListeners();
  }

  // ==================== REVIEWS & REPORTS ====================

  void addReview({
    String? sellerId,
    String? targetUserId,
    String? itemId,
    required double rating,
    required String comment,
    String? itemTitle,
  }) {
    final newReview = ReviewModel(
      id: 'rev_${_uuid.v4().substring(0, 8)}',
      reviewerId: _currentUser.id,
      reviewerName: _currentUser.name,
      targetUserId: targetUserId ?? sellerId ?? '',
      itemTitle: itemTitle ?? 'Campus Item',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, newReview);
    notifyListeners();
  }

  void addReport({
    required String itemId,
    required String reason,
    required String details,
    String? itemTitle,
    String? sellerId,
    String? sellerName,
  }) {
    final item = getItemById(itemId);
    final newReport = ReportModel(
      id: 'rep_${_uuid.v4().substring(0, 8)}',
      itemId: itemId,
      itemTitle: itemTitle ?? item?.title ?? 'Reported Item',
      reportedByUserId: _currentUser.id,
      reportedByUserName: _currentUser.name,
      sellerId: sellerId ?? item?.sellerId ?? 'user_reported',
      sellerName: sellerName ?? item?.sellerName ?? 'Reported User',
      reason: reason,
      details: details,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _reports.insert(0, newReport);
    notifyListeners();
  }

  // ==================== PAYMENTS & MEMBERSHIPS ====================

  void submitSellerMembershipPayment(String referenceNumber) {
    final newPayment = PaymentModel(
      id: 'pay_${_uuid.v4().substring(0, 8)}',
      userId: _currentUser.id,
      userName: _currentUser.name,
      userCollege: _currentUser.college,
      paymentType: 'membership',
      amount: 49.0,
      referenceNumber: referenceNumber,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _payments.insert(0, newPayment);
    notifyListeners();
  }

  void submitBoostPayment({
    required String itemId,
    String? planName,
    double? amount,
    dynamic plan,
    required String referenceNumber,
    String? itemTitle,
  }) {
    final effectivePlanName = planName ?? (plan != null ? (plan as dynamic).name?.toString() : null) ?? 'Featured Boost';
    final effectiveAmount = amount ?? (plan != null ? ((plan as dynamic).price is num ? ((plan as dynamic).price as num).toDouble() : 49.0) : 49.0);

    final newPayment = PaymentModel(
      id: 'pay_${_uuid.v4().substring(0, 8)}',
      userId: _currentUser.id,
      userName: _currentUser.name,
      userCollege: _currentUser.college,
      paymentType: 'boost',
      amount: effectiveAmount,
      referenceNumber: referenceNumber,
      relatedItemId: itemId,
      relatedItemTitle: itemTitle ?? 'Featured Item',
      boostDuration: effectivePlanName,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _payments.insert(0, newPayment);
    notifyListeners();
  }

  // ==================== ADMIN ACTIONS ====================

  void adminApproveVerification(String userId) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isVerified: true);
      notifyListeners();
    }
  }

  void adminRejectVerification(String userId) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isVerified: false);
      notifyListeners();
    }
  }

  void adminResolveReport(String reportId, String action) {
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(
        status: 'resolved_removed',
      );
      notifyListeners();
    }
  }

  void adminApprovePayment(String paymentId) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(status: 'approved');
      final p = _payments[idx];

      if (p.paymentType == 'membership') {
        final uIdx = _users.indexWhere((u) => u.id == p.userId);
        if (uIdx != -1) {
          _users[uIdx] = _users[uIdx].copyWith(isSellerMember: true);
          if (_currentUser.id == p.userId) {
            _currentUser = _users[uIdx];
          }
        }
      } else if (p.relatedItemId != null) {
        final iIdx = _items.indexWhere((i) => i.id == p.relatedItemId);
        if (iIdx != -1) {
          _items[iIdx] = _items[iIdx].copyWith(isFeatured: true);
          _storage.saveItems(_items);
        }
      }
      notifyListeners();
    }
  }

  void adminRejectPayment(String paymentId, String reason) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(
        status: 'rejected',
        rejectionReason: reason,
      );
      notifyListeners();
    }
  }
}
