import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static const String rtdbUrl =
      'https://adssu-click-sulit-default-rtdb.asia-southeast1.firebasedatabase.app';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseDatabase? _database;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get storage => _storage ?? FirebaseStorage.instance;
  FirebaseDatabase get database =>
      _database ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: rtdbUrl,
      );

  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
      } else {
        if (kIsWeb) {
          await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: 'AIzaSyAOuiST060AgO0cJF7s5ZjAsO7TIE-S5Sw',
              appId: '1:904465393499:web:b03c7d609df5f532a75c7e',
              messagingSenderId: '904465393499',
              projectId: 'adssu-click-sulit',
              authDomain: 'adssu-click-sulit.firebaseapp.com',
              storageBucket: 'adssu-click-sulit.firebasestorage.app',
              databaseURL: rtdbUrl,
            ),
          );
        } else {
          await Firebase.initializeApp();
        }
        _isInitialized = true;
      }

      _auth = FirebaseAuth.instance;

      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        if (kDebugMode) debugPrint('[FirebaseService] Firestore note: $e');
      }

      try {
        _storage = FirebaseStorage.instance;
      } catch (e) {
        if (kDebugMode) debugPrint('[FirebaseService] Storage note: $e');
      }

      try {
        _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: rtdbUrl,
        );
        if (!kIsWeb) {
          _database!.setPersistenceEnabled(true);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[FirebaseService] RTDB note: $e');
      }

      if (kDebugMode) {
        debugPrint('[FirebaseService] Successfully connected to Firebase & RTDB: $rtdbUrl');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseService] Firebase initialization failed: $e');
      }
      _isInitialized = false;
      return false;
    }
  }
}
