import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/campus_constants.dart';
import '../models/user_model.dart';
import '../services/email_otp_service.dart';
import '../services/firebase_service.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final EmailOtpService _otpService;

  UserModel? _cachedUser;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    EmailOtpService? otpService,
  })  : _customAuth = auth,
        _customFirestore = firestore,
        _otpService = otpService ?? EmailOtpService(firestore: firestore);

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (FirebaseService().isInitialized) {
      try {
        return FirebaseAuth.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

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
  Stream<UserModel?> get authStateChanges {
    final a = _auth;
    if (a == null) return Stream.value(null);
    return a.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        _cachedUser = null;
        return null;
      }
      return await _fetchUserProfile(fbUser.uid);
    });
  }

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  bool get isAuthenticated => _auth?.currentUser != null;

  void _validateAdssuEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (!clean.endsWith('@adssu.edu.ph')) {
      throw FirebaseAuthException(
        code: 'invalid-email-domain',
        message: 'Only official @adssu.edu.ph institutional email addresses are permitted.',
      );
    }
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    final fs = _firestore;
    if (fs == null) return null;
    try {
      final doc = await fs.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _cachedUser = UserModel.fromMap(doc.data()!, uid);
        return _cachedUser;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    _validateAdssuEmail(email);

    final a = _auth;
    final fs = _firestore;
    if (a == null || fs == null) {
      final fallback = UserModel(
        id: 'user_${email.split('@').first}',
        name: email.split('@').first.toUpperCase(),
        email: email.trim().toLowerCase(),
        college: CampusConstants.colleges.first,
        studentId: '2024-0001',
        isVerified: true,
      );
      _cachedUser = fallback;
      return fallback;
    }

    final cred = await a.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final uid = cred.user!.uid;
    var profile = await _fetchUserProfile(uid);

    if (profile == null) {
      profile = UserModel(
        id: uid,
        name: cred.user!.displayName ?? email.split('@').first,
        email: email.trim().toLowerCase(),
        college: CampusConstants.colleges.first,
        studentId: '2023-0001',
        isVerified: true,
      );
      await fs.collection('users').doc(uid).set(profile.toMap());
      _cachedUser = profile;
    }

    return profile;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String college,
  }) async {
    _validateAdssuEmail(email);

    final cleanEmail = email.trim().toLowerCase();
    final a = _auth;
    final fs = _firestore;

    if (a == null || fs == null) {
      final fallback = UserModel(
        id: 'user_${cleanEmail.split('@').first}',
        name: name.trim(),
        email: cleanEmail,
        college: college,
        studentId: studentId.trim(),
        isVerified: false,
      );
      _cachedUser = fallback;
      await sendVerificationOtp(cleanEmail);
      return fallback;
    }

    final cred = await a.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final uid = cred.user!.uid;
    final newUser = UserModel(
      id: uid,
      name: name.trim(),
      email: cleanEmail,
      college: college,
      studentId: studentId.trim(),
      isVerified: false,
      isSellerMember: false,
    );

    await fs.collection('users').doc(uid).set(newUser.toMap());
    _cachedUser = newUser;

    await sendVerificationOtp(cleanEmail);

    return newUser;
  }

  @override
  Future<void> sendVerificationOtp(String email) async {
    _validateAdssuEmail(email);
    await _otpService.sendVerificationOtp(email.trim().toLowerCase());
  }

  @override
  Future<bool> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final uid = _auth?.currentUser?.uid;
    final success = await _otpService.verifyOtp(
      email: email,
      enteredCode: code,
      currentUserId: uid,
    );

    if (success && uid != null) {
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(isVerified: true);
      }
    }
    return success;
  }

  Future<UserModel?> findRegisteredUser({String? uid, String? email}) async {
    final fs = _firestore;
    final cleanEmail = email?.trim().toLowerCase();

    // 1. Try Firestore by UID
    if (fs != null && uid != null && uid.isNotEmpty) {
      try {
        final doc = await fs.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final u = UserModel.fromMap(doc.data()!, uid);
          if (u.studentId.isNotEmpty && u.studentId != '2024-GGL-001' && u.studentId != '2024-STU-0001') {
            return u;
          }
        }
      } catch (_) {}
    }

    // 2. Try Firestore by Email
    if (fs != null && cleanEmail != null && cleanEmail.isNotEmpty) {
      try {
        final q = await fs.collection('users').where('email', isEqualTo: cleanEmail).limit(1).get();
        if (q.docs.isNotEmpty) {
          final u = UserModel.fromMap(q.docs.first.data(), q.docs.first.id);
          if (u.studentId.isNotEmpty && u.studentId != '2024-GGL-001' && u.studentId != '2024-STU-0001') {
            return u;
          }
        }
      } catch (_) {}
    }

    // 3. Try Realtime Database by UID
    if (FirebaseService().isInitialized && uid != null && uid.isNotEmpty) {
      try {
        final snap = await FirebaseService().database.ref('users/$uid').get();
        if (snap.exists && snap.value is Map) {
          final u = UserModel.fromMap(Map<String, dynamic>.from(snap.value as Map), uid);
          if (u.studentId.isNotEmpty && u.studentId != '2024-GGL-001' && u.studentId != '2024-STU-0001') {
            return u;
          }
        }
      } catch (_) {}
    }

    // 4. Try Realtime Database by email
    if (FirebaseService().isInitialized && cleanEmail != null && cleanEmail.isNotEmpty) {
      try {
        final snap = await FirebaseService().database.ref('users').get();
        if (snap.exists && snap.value is Map) {
          final map = Map<String, dynamic>.from(snap.value as Map);
          for (final entry in map.entries) {
            if (entry.value is Map) {
              final userMap = Map<String, dynamic>.from(entry.value as Map);
              if (userMap['email']?.toString().toLowerCase() == cleanEmail) {
                final u = UserModel.fromMap(userMap, entry.key);
                if (u.studentId.isNotEmpty && u.studentId != '2024-GGL-001' && u.studentId != '2024-STU-0001') {
                  return u;
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final a = _auth;

    // Web Flow
    if (kIsWeb && a != null) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      provider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential;
      try {
        userCredential = await a.signInWithPopup(provider);
      } catch (e) {
        debugPrint('[GoogleSignIn Web] Popup error: $e');
        final err = e.toString().toLowerCase();
        if (err.contains('popup-closed-by-user') ||
            err.contains('cancelled') ||
            err.contains('canceled') ||
            err.contains('closed')) {
          throw FirebaseAuthException(
            code: 'sign-in-cancelled',
            message: 'Google Sign-In was cancelled.',
          );
        }
        if (err.contains('popup-blocked')) {
          throw FirebaseAuthException(
            code: 'popup-blocked',
            message: 'Browser blocked the Google popup. Please allow popups or open in a regular Chrome tab at http://localhost:8080.',
          );
        }
        rethrow;
      }

      final u = userCredential.user;
      if (u == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google Sign-In was cancelled.',
        );
      }

      final email = (u.email ?? '').trim().toLowerCase();
      // Strict Institutional domain check
      if (!email.endsWith('@adssu.edu.ph')) {
        await a.signOut();
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Access restricted: Only official Agusan del Sur State University accounts (@adssu.edu.ph) are permitted.',
        );
      }

      // Check if user is registered in the database
      var registered = await findRegisteredUser(uid: u.uid, email: email);
      if (registered == null) {
        await a.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No registered account found for $email. Please register your account first.',
        );
      }

      // If registered user doesn't have photo yet or Gmail has a photo, sync photo
      if (u.photoURL != null && u.photoURL!.isNotEmpty && registered.profilePhoto != u.photoURL) {
        registered = registered.copyWith(profilePhoto: u.photoURL);
        try {
          await FirebaseService().database.ref('users/${registered.id}').update({'profilePhoto': u.photoURL});
        } catch (_) {}
      }

      _cachedUser = registered;
      return registered;
    }

    // Android / Device Flow
    final googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? '904465393499-h9gqfbb9g82l0pd280sopbf1mcv6pbg4.apps.googleusercontent.com' : null,
      serverClientId: '904465393499-h9gqfbb9g82l0pd280sopbf1mcv6pbg4.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );

    // Sign out first so Android always displays the Google Account Chooser bottom sheet
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser;
    try {
      googleUser = await googleSignIn.signIn();
    } catch (e) {
      debugPrint('[GoogleSignIn] Platform sign-in error on device: $e');
      final err = e.toString().toLowerCase();
      if (err.contains('cancel') || err.contains('canceled') || err.contains('cancelled')) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google Sign-In was cancelled.',
        );
      }
      rethrow;
    }

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google Sign-In was cancelled.',
      );
    }

    final email = googleUser.email.trim().toLowerCase();
    // Strict Institutional domain check
    if (!email.endsWith('@adssu.edu.ph')) {
      await googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'invalid-email-domain',
        message: 'Access restricted: Only official Agusan del Sur State University accounts (@adssu.edu.ph) are permitted.',
      );
    }

    // Check if user is registered in the database
    var registered = await findRegisteredUser(email: email);
    if (registered == null) {
      await googleSignIn.signOut();
      await a?.signOut();
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No registered account found for $email. Please register your account first.',
      );
    }

    // Sync Gmail profile photo
    if (googleUser.photoUrl != null && googleUser.photoUrl!.isNotEmpty && registered.profilePhoto != googleUser.photoUrl) {
      registered = registered.copyWith(profilePhoto: googleUser.photoUrl);
      try {
        await FirebaseService().database.ref('users/${registered.id}').update({'profilePhoto': googleUser.photoUrl});
      } catch (_) {}
    }

    _cachedUser = registered;
    return registered;
  }

  @override
  Future<Map<String, String>> getGoogleAccountForRegistration() async {
    final a = _auth;

    // Web Flow
    if (kIsWeb && a != null) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      provider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential;
      try {
        userCredential = await a.signInWithPopup(provider);
      } catch (e) {
        final err = e.toString().toLowerCase();
        if (err.contains('popup-closed-by-user') ||
            err.contains('cancelled') ||
            err.contains('canceled') ||
            err.contains('closed')) {
          throw FirebaseAuthException(
            code: 'sign-in-cancelled',
            message: 'Google Sign-In was cancelled.',
          );
        }
        if (err.contains('popup-blocked')) {
          throw FirebaseAuthException(
            code: 'popup-blocked',
            message: 'Browser blocked the Google popup. Please allow popups or open in a regular Chrome tab at http://localhost:8080.',
          );
        }
        rethrow;
      }

      final u = userCredential.user;
      if (u == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google Sign-In was cancelled.',
        );
      }

      final email = (u.email ?? '').trim().toLowerCase();
      if (!email.endsWith('@adssu.edu.ph')) {
        await a.signOut();
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only official @adssu.edu.ph institutional Google accounts are permitted to register.',
        );
      }

      // Check if already registered
      final existing = await findRegisteredUser(uid: u.uid, email: email);
      if (existing != null) {
        await a.signOut();
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account with $email is already registered. Please go to Sign In.',
        );
      }

      final name = u.displayName?.trim().isNotEmpty == true
          ? u.displayName!
          : email.split('@').first.toUpperCase();

      return {
        'name': name,
        'email': email,
        'uid': u.uid,
        if (u.photoURL != null && u.photoURL!.isNotEmpty) 'photoUrl': u.photoURL!,
      };
    }

    // Android / Device Flow
    final googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? '904465393499-h9gqfbb9g82l0pd280sopbf1mcv6pbg4.apps.googleusercontent.com' : null,
      serverClientId: '904465393499-h9gqfbb9g82l0pd280sopbf1mcv6pbg4.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );

    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser;
    try {
      googleUser = await googleSignIn.signIn();
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('cancel') || err.contains('canceled') || err.contains('cancelled')) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google Sign-In was cancelled.',
        );
      }
      rethrow;
    }

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google Sign-In was cancelled.',
      );
    }

    final email = googleUser.email.trim().toLowerCase();
    if (!email.endsWith('@adssu.edu.ph')) {
      await googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'invalid-email-domain',
        message: 'Only official @adssu.edu.ph institutional Google accounts are permitted to register.',
      );
    }

    // Check if already registered
    final existing = await findRegisteredUser(email: email);
    if (existing != null) {
      await googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'An account with $email is already registered. Please go to Sign In.',
      );
    }

    final name = googleUser.displayName?.trim().isNotEmpty == true
        ? googleUser.displayName!
        : email.split('@').first.toUpperCase();

    return {
      'name': name,
      'email': email,
      'uid': googleUser.id,
      if (googleUser.photoUrl != null && googleUser.photoUrl!.isNotEmpty)
        'photoUrl': googleUser.photoUrl!,
    };
  }

  @override
  Future<void> signOut() async {
    await _auth?.signOut();
    _cachedUser = null;
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? college,
    String? bio,
    String? profilePhoto,
  }) async {
    final uid = _auth?.currentUser?.uid;
    final fs = _firestore;
    if (uid == null || fs == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (college != null) updates['college'] = college;
    if (bio != null) updates['bio'] = bio;
    if (profilePhoto != null) updates['profilePhoto'] = profilePhoto;

    if (updates.isNotEmpty) {
      await fs.collection('users').doc(uid).update(updates);
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(
          name: name,
          college: college,
          bio: bio,
          profilePhoto: profilePhoto,
        );
      }
    }
  }
}

