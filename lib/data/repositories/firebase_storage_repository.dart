import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_service.dart';
import 'storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage? _customStorage;

  FirebaseStorageRepository({FirebaseStorage? storage})
      : _customStorage = storage;

  FirebaseStorage? get _storage {
    if (_customStorage != null) return _customStorage;
    if (FirebaseService().isInitialized) {
      try {
        return FirebaseStorage.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<String> uploadPhoto({
    required String storagePath,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final s = _storage;
    if (s == null) {
      return 'https://storage.googleapis.com/adssu-click-and-sulit.appspot.com/$storagePath';
    }

    final ref = s.ref().child(storagePath);
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
