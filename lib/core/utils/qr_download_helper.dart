import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class QrDownloadHelper {
  QrDownloadHelper._();

  /// Saves the specified asset image directly to the user's Gallery (DCIM / Pictures)
  /// so it immediately appears in their photos app and GCash upload picker.
  /// Falls back to device storage or app folder if gallery saving is unavailable.
  static Future<String?> downloadQrImage({
    required String assetPath,
    required String fileName,
  }) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // First, write to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes, flush: true);

      // Attempt to save to photo gallery with gal package
      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }
        await Gal.putImage(tempFile.path, album: 'ADSSU Click & Sulit');
        return 'Saved to Gallery (ADSSU Click & Sulit album)';
      } catch (e) {
        debugPrint('[QrDownloadHelper] Gal gallery save failed, falling back to storage: $e');
      }

      // Fallback: save to Downloads folder
      Directory? targetDir;
      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          targetDir = externalDirs.first;
        } else {
          final ext = await getExternalStorageDirectory();
          if (ext != null) {
            final downloadFolder = Directory('${ext.path}/Download');
            if (!downloadFolder.existsSync()) {
              downloadFolder.createSync(recursive: true);
            }
            targetDir = downloadFolder;
          }
        }
      }

      targetDir ??= await getApplicationDocumentsDirectory();
      final File targetFile = File('${targetDir.path}/$fileName');
      await targetFile.writeAsBytes(bytes, flush: true);

      return targetFile.path;
    } catch (e) {
      debugPrint('[QrDownloadHelper] Error saving QR image: $e');
      return null;
    }
  }
}
