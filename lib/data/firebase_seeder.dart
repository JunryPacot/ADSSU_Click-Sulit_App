import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'mock/seed_data.dart';
import 'services/firebase_service.dart';

class FirebaseSeeder {
  final FirebaseFirestore? firestore;

  FirebaseSeeder({this.firestore});

  /// Ensures necessary system records exist (like the official ADSSU admin account),
  /// while keeping marketplace items and requests clean for real user postings.
  Future<void> seedInitialData({bool overwrite = false}) async {
    final admin = SeedData.initialUsers.firstWhere((u) => u.id == 'user_admin');

    // 1. Seed Realtime Database
    try {
      if (FirebaseService().isInitialized) {
        final rtdbAdmin = await FirebaseService().database.ref('users/user_admin').get();
        if (!rtdbAdmin.exists) {
          await FirebaseService().database.ref('users/user_admin').set(admin.toMap());
          if (kDebugMode) {
            debugPrint('[FirebaseSeeder] Configured official ADSSU Admin in Realtime Database.');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[FirebaseSeeder] RTDB seed note: $e');
    }

    // 2. Seed Firestore if available
    try {
      final fs = firestore ?? FirebaseFirestore.instance;
      final adminDoc = await fs.collection('users').doc('user_admin').get();
      if (!adminDoc.exists) {
        await fs.collection('users').doc('user_admin').set(admin.toMap(), SetOptions(merge: true));
        if (kDebugMode) {
          debugPrint('[FirebaseSeeder] Configured official ADSSU Admin in Cloud Firestore.');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[FirebaseSeeder] Firestore seed note: $e');
    }
  }
}
