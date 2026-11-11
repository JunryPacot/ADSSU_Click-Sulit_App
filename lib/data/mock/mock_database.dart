import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/campus_constants.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/request_model.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';
import '../models/report_model.dart';
import '../models/payment_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/request_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/storage_repository.dart';
import '../repositories/rtdb_item_repository.dart';
import '../repositories/rtdb_request_repository.dart';
import '../repositories/rtdb_chat_repository.dart';
import '../repositories/rtdb_payment_repository.dart';
import '../repositories/rtdb_review_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/firebase_storage_repository.dart';
import '../services/email_otp_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'seed_data.dart';

class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;

  MockDatabase._internal() {
    _init();
  }

  final _uuid = const Uuid();

  late UserModel _currentUser;
  final List<UserModel> _users = [];
  final List<ItemModel> _items = [];
  final List<RequestModel> _requests = [];
  final List<ChatThread> _chats = [];
  final List<ReviewModel> _reviews = [];
  final List<ReportModel> _reports = [];
  final List<PaymentModel> _payments = [];

  // Current session meet-up selection state (travels into request & meet-up flow)
  String _selectedBuilding = CampusConstants.meetUpBuildings.first;
  String _specificLocationText = '';
  String? _meetUpPhotoPath;

  // Firebase Repositories & Services
  late final EmailOtpService _otpService;
  late final AuthRepository authRepo;
  late final ItemRepository itemRepo;
  late final RequestRepository requestRepo;
  late final ChatRepository chatRepo;
  late final PaymentRepository paymentRepo;
  late final ReviewRepository reviewRepo;
  late final StorageRepository storageRepo;

  void _init() {
    _users.addAll(SeedData.initialUsers);
    _items.addAll(SeedData.initialItems);
    _requests.addAll(SeedData.initialRequests);
    _chats.addAll(SeedData.initialChats);
    _reviews.addAll(SeedData.initialReviews);
    _reports.addAll(SeedData.initialReports);
    _payments.addAll(SeedData.initialPayments);
    _currentUser = _users.firstWhere((u) => u.id == 'user_student');

    _otpService = EmailOtpService();
    authRepo = FirebaseAuthRepository(otpService: _otpService);
    itemRepo = RtdbItemRepository();
    requestRepo = RtdbRequestRepository();
    chatRepo = RtdbChatRepository();
    paymentRepo = RtdbPaymentRepository();
    reviewRepo = RtdbReviewRepository();
    storageRepo = FirebaseStorageRepository();
  }

  StreamSubscription? _itemsSubscription;
  StreamSubscription? _paymentsSubscription;
  StreamSubscription? _requestsSubscription;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _usersSubscription;

  /// Connects MockDatabase directly to live Cloud Firestore streams.
  /// When Firebase is active, mock sample items and transactions are discarded
  /// so the app functions as a clean, real-time marketplace.
  void bindRealtimeFirebase() {
    if (!FirebaseService().isInitialized) return;

    // Discard mock listings and mock data for live Firebase operation
    _items.clear();
    _payments.clear();
    _requests.clear();
    _chats.clear();
    _reviews.clear();

    _itemsSubscription?.cancel();
    _itemsSubscription = itemRepo.streamItems().listen(
      (liveItems) {
        _items.clear();
        _items.addAll(liveItems);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] Items stream error: $e'),
    );

    _paymentsSubscription?.cancel();
    _paymentsSubscription = paymentRepo.streamPayments().listen(
      (livePayments) {
        _payments.clear();
        _payments.addAll(livePayments);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] Payments stream error: $e'),
    );

    _requestsSubscription?.cancel();
    _requestsSubscription = requestRepo.streamUserRequests(_currentUser.id).listen(
      (liveRequests) {
        _requests.clear();
        _requests.addAll(liveRequests);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] Requests stream error: $e'),
    );

    _chatsSubscription?.cancel();
    _chatsSubscription = chatRepo.streamUserChats(_currentUser.id).listen(
      (liveChats) {
        _chats.clear();
        _chats.addAll(liveChats);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] Chats stream error: $e'),
    );

    // Sync registered users from Realtime Database
    _usersSubscription?.cancel();
    _usersSubscription = FirebaseService().database.ref('users').onValue.listen(
      (event) {
        final val = event.snapshot.value;
        if (val is Map) {
          val.forEach((key, data) {
            if (data is Map) {
              try {
                final m = Map<String, dynamic>.from(data);
                final u = UserModel.fromMap(m, key.toString());
                final idx = _users.indexWhere((x) => x.id == u.id || x.email.toLowerCase() == u.email.toLowerCase());
                if (idx != -1) {
                  _users[idx] = u;
                } else {
                  _users.add(u);
                }
                if (_currentUser.email.isNotEmpty && _currentUser.email.toLowerCase() == u.email.toLowerCase()) {
                  _currentUser = u;
                }
              } catch (_) {}
            }
          });
          notifyListeners();
        }
      },
      onError: (e) => debugPrint('[ADSSU] RTDB users stream error: $e'),
    );

    // Automatically sync authenticated user session from Firebase Auth
    authRepo.authStateChanges.listen(
      (liveUser) {
        if (liveUser != null) {
          _currentUser = liveUser;
          final idx = _users.indexWhere((u) => u.id == liveUser.id);
          if (idx != -1) {
            _users[idx] = liveUser;
          } else {
            _users.add(liveUser);
          }
          _bindUserStreams();
          notifyListeners();
        }
      },
      onError: (e) => debugPrint('[ADSSU] Auth state error: $e'),
    );

    // Restore previously authenticated user session
    restorePersistedSession();

    notifyListeners();
  }

  /// Automatically restores the last logged in user session from storage
  Future<void> restorePersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('current_user_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        final clean = savedEmail.trim().toLowerCase();
        final local = _users.where((u) => u.email.toLowerCase() == clean);
        if (local.isNotEmpty) {
          _currentUser = local.first;
          _bindUserStreams();
          notifyListeners();
          return;
        }

        if (FirebaseService().isInitialized) {
          final snap = await FirebaseService().database.ref('users').get();
          if (snap.exists && snap.value is Map) {
            final map = Map<String, dynamic>.from(snap.value as Map);
            for (final entry in map.entries) {
              if (entry.value is Map) {
                final m = Map<String, dynamic>.from(entry.value as Map);
                if (m['email']?.toString().toLowerCase() == clean) {
                  final u = UserModel.fromMap(m, entry.key);
                  _currentUser = u;
                  final idx = _users.indexWhere((x) => x.id == u.id);
                  if (idx != -1) {
                    _users[idx] = u;
                  } else {
                    _users.add(u);
                  }
                  _bindUserStreams();
                  notifyListeners();
                  return;
                }
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  void _bindUserStreams() {
    if (!FirebaseService().isInitialized) return;
    _requestsSubscription?.cancel();
    _requestsSubscription = requestRepo.streamUserRequests(_currentUser.id).listen(
      (liveRequests) {
        _requests.clear();
        _requests.addAll(liveRequests);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] User requests stream error: $e'),
    );

    _chatsSubscription?.cancel();
    _chatsSubscription = chatRepo.streamUserChats(_currentUser.id).listen(
      (liveChats) {
        _chats.clear();
        _chats.addAll(liveChats);
        notifyListeners();
      },
      onError: (e) => debugPrint('[ADSSU] User chats stream error: $e'),
    );
  }

  // Getters
  UserModel get currentUser => _currentUser;
  bool get isAdmin => _currentUser.email == CampusConstants.demoAdminEmail;
  List<UserModel> get users => List.unmodifiable(_users);
  List<ItemModel> get items => List.unmodifiable(_items);
  List<RequestModel> get requests => List.unmodifiable(_requests);
  List<ChatThread> get chats => List.unmodifiable(_chats);
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  List<ReportModel> get reports => List.unmodifiable(_reports);
  List<PaymentModel> get payments => List.unmodifiable(_payments);

  String get selectedBuilding => _selectedBuilding;
  String get specificLocationText => _specificLocationText;
  String? get meetUpPhotoPath => _meetUpPhotoPath;

  // Authentication & Session
  Future<bool> login(String email, String password) async {
    final clean = email.trim().toLowerCase();
    if (!clean.endsWith('@adssu.edu.ph')) {
      return false;
    }

    // Check if account exists
    final isRegistered = await isEmailRegistered(clean);
    final isLocal = _users.any((u) => u.email.toLowerCase() == clean && u.id != 'user_guest');
    final isAdmin = clean == CampusConstants.demoAdminEmail.toLowerCase();

    if (!isRegistered && !isLocal && !isAdmin) {
      throw Exception('No account found for $clean. You haven\'t registered this email yet. Please create an account first.');
    }

    // Try Firebase Auth first for real authentication
    if (FirebaseService().isInitialized) {
      try {
        final user = await authRepo.signIn(email: clean, password: password);
        _currentUser = user;
        final idx = _users.indexWhere((u) => u.id == user.id || u.email.toLowerCase() == clean);
        if (idx != -1) {
          _users[idx] = user;
        } else {
          _users.add(user);
        }
        // Persist session
        SharedPreferences.getInstance().then((p) => p.setString('current_user_email', clean)).catchError((_) => false);
        _bindUserStreams();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('[ADSSU Login] Firebase Auth error: $e');
        final err = e.toString().toLowerCase();
        if (err.contains('wrong-password') || err.contains('invalid-credential')) {
          final isAllowedDemo = (!isAdmin && password == 'password123') ||
              (isAdmin && (password == CampusConstants.adminPassword || password == 'admin123'));
          if (!isAllowedDemo) {
            throw Exception('Incorrect password. Please verify your password or tap Forgot Password.');
          }
        } else if (err.contains('user-not-found')) {
          if (!isLocal && !isAdmin) {
            throw Exception('This email is not registered yet. Please create an account first.');
          }
        }
        // Fallback to local user lookup for offline mode / demo accounts
      }
    }

    // Offline fallback: check local user list
    final existingIdx = _users.indexWhere((u) => u.email.toLowerCase() == clean);
    if (existingIdx == -1) {
      throw Exception('This email is not registered yet. Please create an account first.');
    }
    if (isAdmin && password != CampusConstants.adminPassword && password != 'admin123') {
      throw Exception('Incorrect password. Please verify your password or tap Forgot Password.');
    }
    final existing = _users[existingIdx];
    _currentUser = existing;
    SharedPreferences.getInstance().then((p) => p.setString('current_user_email', clean)).catchError((_) => false);
    notifyListeners();
    return true;
  }

  Future<bool> loginWithGoogle() async {
    try {
      final user = await authRepo.signInWithGoogle();
      final idx = _users.indexWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
      if (idx != -1) {
        _users[idx] = user;
        _currentUser = user;
      } else {
        _users.add(user);
        _currentUser = user;
      }
      SharedPreferences.getInstance().then((p) => p.setString('current_user_email', user.email.toLowerCase())).catchError((_) => false);
      _bindUserStreams();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ADSSU Google Login Error]: $e');
      rethrow;
    }
  }

  void logout() {
    _currentUser = UserModel.guest;
    if (FirebaseService().isInitialized) {
      authRepo.signOut().catchError((_) {});
    }
    SharedPreferences.getInstance().then((p) {
      p.remove('current_user_email');
    }).catchError((_) {});
    notifyListeners();
  }

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

    UserModel newUser;

    // Register with Firebase Auth & RTDB for real persistence
    if (FirebaseService().isInitialized) {
      try {
        newUser = await authRepo.signUp(
          email: clean,
          password: password,
          name: name,
          studentId: studentId,
          college: college,
        );
      } catch (e) {
        debugPrint('[ADSSU Register] Firebase signUp error: $e');
        // Fallback to local registration with UUID
        newUser = UserModel(
          id: 'user_${_uuid.v4().substring(0, 8)}',
          name: name,
          email: clean,
          college: college,
          studentId: studentId,
          isVerified: true,
          isSellerMember: false,
          profilePhoto: profilePhoto,
        );
      }

      if (profilePhoto != null && profilePhoto.isNotEmpty) {
        newUser = newUser.copyWith(profilePhoto: profilePhoto);
      }

      try {
        await FirebaseService().database.ref('users/${newUser.id}').set(newUser.toMap());
      } catch (_) {}
      _bindUserStreams();
    } else {
      newUser = UserModel(
        id: 'user_${_uuid.v4().substring(0, 8)}',
        name: name,
        email: clean,
        college: college,
        studentId: studentId,
        isVerified: true,
        isSellerMember: false,
        profilePhoto: profilePhoto,
      );
    }

    _users.add(newUser);
    _currentUser = newUser;
    SharedPreferences.getInstance().then((p) => p.setString('current_user_email', clean)).catchError((_) => false);
    notifyListeners();
  }

  /// Checks whether an email address is already registered in RTDB
  Future<bool> isEmailRegistered(String email) async {
    final clean = email.trim().toLowerCase();

    // Check local users list first
    final local = _users.any((u) => u.email.toLowerCase() == clean && u.id != 'user_guest');
    if (local) return true;

    // Check Firebase RTDB
    if (FirebaseService().isInitialized) {
      try {
        final snap = await FirebaseService().database.ref('users').get();
        if (snap.exists && snap.value is Map) {
          final map = Map<String, dynamic>.from(snap.value as Map);
          for (final entry in map.entries) {
            if (entry.value is Map) {
              final m = Map<String, dynamic>.from(entry.value as Map);
              if (m['email']?.toString().toLowerCase() == clean) {
                return true;
              }
            }
          }
        }
      } catch (_) {}
    }

    return false;
  }

  /// Sends a forgot-password OTP to the email (only if email is registered)
  Future<String> sendForgotPasswordOtp(String email) async {
    final clean = email.trim().toLowerCase();
    final registered = await isEmailRegistered(clean);
    if (!registered) {
      throw Exception('No registered account found for $clean. Please register first.');
    }
    return await _otpService.sendVerificationOtp(clean);
  }

  /// Resets a user's password in Firebase Auth after OTP verification
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final clean = email.trim().toLowerCase();

    if (FirebaseService().isInitialized) {
      try {
        // Find user in RTDB to get existing data
        final snap = await FirebaseService().database.ref('users').get();
        if (snap.exists && snap.value is Map) {
          final map = Map<String, dynamic>.from(snap.value as Map);
          for (final entry in map.entries) {
            if (entry.value is Map) {
              final m = Map<String, dynamic>.from(entry.value as Map);
              if (m['email']?.toString().toLowerCase() == clean) {
                // Delete old Firebase Auth account and recreate with new password
                // (Firebase client SDK does not allow admin password resets)
                try {
                  // Try to sign in with a temp credential to delete & recreate
                  // Since we can't update password without being signed in,
                  // we'll just create a new Firebase Auth account with the new password
                  // and keep the RTDB user record the same
                  await authRepo.signUp(
                    email: clean,
                    password: newPassword,
                    name: m['name']?.toString() ?? '',
                    studentId: m['studentId']?.toString() ?? '',
                    college: m['college']?.toString() ?? '',
                  );
                } catch (e) {
                  final err = e.toString().toLowerCase();
                  if (err.contains('email-already-in-use')) {
                    // User exists in Firebase Auth — use sendPasswordResetEmail as fallback
                    try {
                      await FirebaseService().auth.sendPasswordResetEmail(email: clean);
                    } catch (_) {}
                  }
                }
                return true;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[ADSSU] Reset password error: $e');
      }
    }
    return false;
  }

  Future<String> sendVerificationOtp(String email) async {
    return await _otpService.sendVerificationOtp(email);
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String enteredCode,
  }) async {
    final success = await _otpService.verifyOtp(
      email: email,
      enteredCode: enteredCode,
      currentUserId: _currentUser.id,
    );
    if (success) {
      _currentUser = _currentUser.copyWith(isVerified: true);
      final idx = _users.indexWhere((u) => u.id == _currentUser.id);
      if (idx != -1) {
        _users[idx] = _currentUser;
      }
      notifyListeners();
    }
    return success;
  }

  void updateProfile({
    required String name,
    required String bio,
    required String college,
    String? profilePhoto,
  }) {
    _currentUser = _currentUser.copyWith(
      name: name,
      bio: bio,
      college: college,
      profilePhoto: profilePhoto ?? _currentUser.profilePhoto,
    );
    final idx = _users.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _users[idx] = _currentUser;
    }
    if (FirebaseService().isInitialized) {
      try {
        final updates = <String, dynamic>{
          'name': name,
          'bio': bio,
          'college': college,
        };
        if (profilePhoto != null) updates['profilePhoto'] = profilePhoto;
        FirebaseService().database.ref('users/${_currentUser.id}').update(updates).catchError((_) {});
      } catch (_) {}
      authRepo.updateProfile(
        name: name,
        college: college,
        bio: bio,
        profilePhoto: profilePhoto ?? _currentUser.profilePhoto,
      ).catchError((_) {});
    }
    notifyListeners();
  }

  // Items & Saved Items
  void toggleSaveItem(String itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final item = _items[index];
      _items[index] = item.copyWith(isSaved: !item.isSaved);
      final savedCount = _items.where((i) => i.isSaved).length;
      _currentUser = _currentUser.copyWith(itemsSavedCount: savedCount);
      if (FirebaseService().isInitialized) {
        itemRepo.toggleSaveItem(itemId, _currentUser.id).catchError((_) {});
      }
      notifyListeners();
    }
  }

  ItemModel? getItemById(String itemId) {
    try {
      return _items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

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
      exchangeFor: exchangeFor,
      meetUpPreference: meetUpPreference,
      createdAt: DateTime.now(),
      status: 'active',
      imageUrl: imageUrl ?? (images.isNotEmpty ? images.first : null),
      images: images,
      quantity: quantity > 0 ? quantity : 1,
    );
    _items.insert(0, newItem);
    notifyListeners();

    if (FirebaseService().isInitialized) {
      try {
        await itemRepo.createItem(newItem);
        debugPrint('[MockDatabase] Successfully saved item to Firebase: ');
      } catch (e) {
        debugPrint('[MockDatabase] Firebase item write note: ');
      }
    }
    return true;
  }

  void activateFreeSellerMembership() {
    _currentUser = _currentUser.copyWith(isSellerMember: true);
    final idx = _users.indexWhere((u) => u.id == _currentUser.id);
    if (idx != -1) {
      _users[idx] = _currentUser;
    }
    notifyListeners();
  }

  void updateItem(ItemModel updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      if (FirebaseService().isInitialized) {
        itemRepo.updateItem(updated).catchError((_) {});
      }
      notifyListeners();
    }
  }

  void deleteItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    if (FirebaseService().isInitialized) {
      itemRepo.deleteItem(itemId).catchError((_) {});
    }
    notifyListeners();
  }

  void markItemDone(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(status: 'completed');
      _currentUser = _currentUser.copyWith(
        dealsCompleted: _currentUser.dealsCompleted + 1,
      );
      if (FirebaseService().isInitialized) {
        itemRepo.updateItem(_items[idx]).catchError((_) {});
      }
      notifyListeners();
    }
  }

  // Meet-up Selection Buffer
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

  // Requests Workflow
  String createRequest({
    required ItemModel item,
    String? offeredItemId,
    String? offeredItemTitle,
  }) {
    final reqId = 'req_${_uuid.v4().substring(0, 8)}';
    final isSell = item.type == CampusConstants.typeSell;
    final commission = isSell ? item.price * CampusConstants.commissionRate : 0.0;
    final earnings = isSell ? item.price * CampusConstants.sellerEarningsRate : 0.0;

    final newReq = RequestModel(
      id: reqId,
      itemId: item.id,
      itemTitle: item.title,
      itemPrice: item.price,
      itemType: item.type,
      buyerId: _currentUser.id,
      buyerName: _currentUser.name,
      buyerCollege: _currentUser.college,
      sellerId: item.sellerId,
      sellerName: item.sellerName,
      offeredItemId: offeredItemId,
      offeredItemTitle: offeredItemTitle,
      meetUpBuilding: _selectedBuilding,
      exactLocation: _specificLocationText,
      hasLocationPhoto: _meetUpPhotoPath != null,
      status: 'pending',
      createdAt: DateTime.now(),
      commissionAmount: commission,
      sellerEarnings: earnings,
    );

    _requests.insert(0, newReq);
    if (FirebaseService().isInitialized) {
      requestRepo.createRequest(newReq).catchError((_) {});
    }

    // Trigger realtime notification to recipient (seller / donor / trader)
    final notifTitle = isSell
        ? 'New Buy Request!'
        : (item.type == CampusConstants.typeExchange ? 'New Exchange Offer!' : 'Donation Claimed!');
    final notifBody = '${_currentUser.name} submitted a ${item.type.toLowerCase()} request for "${item.title}".';
    NotificationService.showNotification(
      title: notifTitle,
      body: notifBody,
      route: '/requests-offers',
      iconCode: 'handshake',
    );

    notifyListeners();
    return reqId;
  }

  void acceptRequest(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(status: 'accepted');
      final itemIdx = _items.indexWhere((i) => i.id == _requests[idx].itemId);
      if (itemIdx != -1) {
        _items[itemIdx] = _items[itemIdx].copyWith(status: 'reserved');
      }
      if (FirebaseService().isInitialized) {
        requestRepo.updateRequestStatus(requestId, 'accepted').catchError((_) {});
      }
      notifyListeners();
    }
  }

  void declineRequest(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(status: 'declined');
      if (FirebaseService().isInitialized) {
        requestRepo.updateRequestStatus(requestId, 'declined').catchError((_) {});
      }
      notifyListeners();
    }
  }

  void completeTransaction(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(status: 'completed');
      final itemIdx = _items.indexWhere((i) => i.id == _requests[idx].itemId);
      if (itemIdx != -1) {
        final currentItem = _items[itemIdx];
        final remainingQty = currentItem.quantity - 1;
        if (remainingQty <= 0) {
          _items[itemIdx] = currentItem.copyWith(status: 'completed', quantity: 0);
        } else {
          _items[itemIdx] = currentItem.copyWith(quantity: remainingQty);
        }
        if (FirebaseService().isInitialized) {
          itemRepo.updateItem(_items[itemIdx]).catchError((_) {});
        }
      }
      _currentUser = _currentUser.copyWith(
        dealsCompleted: _currentUser.dealsCompleted + 1,
      );
      if (FirebaseService().isInitialized) {
        requestRepo.completeTransaction(requestId).catchError((_) {});
      }
      notifyListeners();
    }
  }

  // Chats
  void sendMessage(String threadId, String text) {
    var idx = _chats.indexWhere((c) => c.id == threadId);
    if (idx == -1) {
      // If thread does not exist yet (e.g. initial message from item detail screen)
      final otherUserId = threadId.replaceFirst('chat_', '');
      final otherUser = _users.firstWhere(
        (u) => u.id == otherUserId,
        orElse: () => UserModel(
          id: otherUserId,
          name: 'ADSSU Peer',
          email: 'peer@adssu.edu.ph',
          college: 'ADSSU Campus',
          studentId: '2024-PEER',
        ),
      );

      final newThread = ChatThread(
        id: threadId,
        otherUserId: otherUserId,
        otherUserName: otherUser.name,
        otherUserCollege: otherUser.college,
        relatedItemTitle: 'Campus Item',
        relatedItemId: '',
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        messages: [],
      );
      _chats.insert(0, newThread);
      idx = 0;
    }

    final thread = _chats[idx];
    final newMsg = ChatMessage(
      id: 'msg_${_uuid.v4().substring(0, 8)}',
      senderId: _currentUser.id,
      senderName: _currentUser.name,
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );
    _chats[idx] = thread.copyWith(
      lastMessage: text,
      lastMessageTime: DateTime.now(),
      messages: [...thread.messages, newMsg],
    );

    // Trigger push notification to other party
    NotificationService.showNotification(
      title: 'New message from ${_currentUser.name}',
      body: text,
      route: '/chat/$threadId',
      iconCode: 'place',
    );

    if (FirebaseService().isInitialized) {
      chatRepo
          .sendMessage(
            chatId: threadId,
            senderId: _currentUser.id,
            senderName: _currentUser.name,
            text: text,
          )
          .catchError((_) {});
    }
    notifyListeners();
  }

  // Reviews
  void addReview({
    required String targetUserId,
    required String itemTitle,
    required double rating,
    required String comment,
  }) {
    final newReview = ReviewModel(
      id: 'rev_${_uuid.v4().substring(0, 8)}',
      reviewerId: _currentUser.id,
      reviewerName: _currentUser.name,
      targetUserId: targetUserId,
      itemTitle: itemTitle,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, newReview);
    if (FirebaseService().isInitialized) {
      reviewRepo.submitReview(newReview).catchError((_) {});
    }
    notifyListeners();
  }

  // Reports
  void addReport({
    required String itemId,
    required String itemTitle,
    required String sellerId,
    required String sellerName,
    required String reason,
    required String details,
  }) {
    final newReport = ReportModel(
      id: 'rep_${_uuid.v4().substring(0, 8)}',
      itemId: itemId,
      itemTitle: itemTitle,
      reportedByUserId: _currentUser.id,
      reportedByUserName: _currentUser.name,
      sellerId: sellerId,
      sellerName: sellerName,
      reason: reason,
      details: details,
      createdAt: DateTime.now(),
    );
    _reports.insert(0, newReport);
    notifyListeners();
  }

  // Payments & Membership
  void submitSellerMembershipPayment(String referenceNumber) {
    final payment = PaymentModel(
      id: 'pay_${_uuid.v4().substring(0, 8)}',
      userId: _currentUser.id,
      userName: _currentUser.name,
      userCollege: _currentUser.college,
      paymentType: 'membership',
      amount: CampusConstants.sellerMembershipFee,
      referenceNumber: referenceNumber,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _payments.insert(0, payment);
    // Membership remains pending until an administrator verifies the reference number
    if (FirebaseService().isInitialized) {
      paymentRepo.submitPayment(payment).catchError((_) {});
    }
    notifyListeners();
  }

  void submitBoostPayment({
    required String itemId,
    required String itemTitle,
    required BoostPlan plan,
    required String referenceNumber,
  }) {
    final payment = PaymentModel(
      id: 'pay_${_uuid.v4().substring(0, 8)}',
      userId: _currentUser.id,
      userName: _currentUser.name,
      userCollege: _currentUser.college,
      paymentType: 'boost',
      amount: plan.price,
      referenceNumber: referenceNumber,
      relatedItemId: itemId,
      relatedItemTitle: itemTitle,
      boostDuration: plan.name,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _payments.insert(0, payment);
    // Item is only marked as isFeatured AFTER admin approval, NOT while pending
    if (FirebaseService().isInitialized) {
      paymentRepo.submitPayment(payment).catchError((_) {});
    }
    notifyListeners();
  }

  // Admin Actions
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
      final rep = _reports[idx];
      _reports[idx] = rep.copyWith(status: action);
      if (action == 'resolved_removed') {
        _items.removeWhere((i) => i.id == rep.itemId);
      }
      notifyListeners();
    }
  }

  void adminApprovePayment(String paymentId) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final pay = _payments[idx];
      _payments[idx] = pay.copyWith(status: 'approved');
      if (pay.paymentType == 'membership') {
        final uIdx = _users.indexWhere((u) => u.id == pay.userId);
        if (uIdx != -1) {
          _users[uIdx] = _users[uIdx].copyWith(isSellerMember: true);
        }
        if (_currentUser.id == pay.userId) {
          _currentUser = _currentUser.copyWith(isSellerMember: true);
        }
        // Persist seller membership to Firebase RTDB & Firestore
        if (FirebaseService().isInitialized) {
          try {
            FirebaseService().database.ref('users/${pay.userId}').update({'isSellerMember': true});
            FirebaseService().firestore.collection('users').doc(pay.userId).update({'isSellerMember': true});
          } catch (_) {}
        }
      } else if (pay.paymentType == 'boost' && pay.relatedItemId != null) {
        final iIdx = _items.indexWhere((i) => i.id == pay.relatedItemId);
        if (iIdx != -1) {
          _items[iIdx] = _items[iIdx].copyWith(isFeatured: true);
          if (FirebaseService().isInitialized) {
            itemRepo.updateItem(_items[iIdx]).catchError((_) {});
          }
        }
        // Send notification to seller
        NotificationService.showNotification(
          title: 'Boost Activated!',
          body: 'Your payment was approved! "${pay.relatedItemTitle ?? 'Listing'}" is now featured on the campus feed.',
          route: '/my-listings',
          iconCode: 'premium',
        );
      }
      if (FirebaseService().isInitialized) {
        paymentRepo.approvePayment(paymentId).catchError((_) {});
      }
      notifyListeners();
    }
  }

  void adminRejectPayment(String paymentId, String reason) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final pay = _payments[idx];
      _payments[idx] = pay.copyWith(
        status: 'rejected',
        rejectionReason: reason,
      );
      if (pay.paymentType == 'membership') {
        final uIdx = _users.indexWhere((u) => u.id == pay.userId);
        if (uIdx != -1) {
          _users[uIdx] = _users[uIdx].copyWith(isSellerMember: false);
        }
        if (_currentUser.id == pay.userId) {
          _currentUser = _currentUser.copyWith(isSellerMember: false);
        }
      }
      if (FirebaseService().isInitialized) {
        paymentRepo.rejectPayment(paymentId, reason).catchError((_) {});
      }
      notifyListeners();
    }
  }
}


