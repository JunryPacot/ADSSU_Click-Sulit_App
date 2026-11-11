import 'dart:typed_data';

abstract class StorageRepository {
  Future<String> uploadPhoto({
    required String storagePath,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  });
}

