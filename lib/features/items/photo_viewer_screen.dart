import 'package:flutter/material.dart';
import '../../core/widgets/app_image.dart';

class PhotoViewerScreen extends StatelessWidget {
  final String? title;
  final String? imageUrl;
  final List<String> images;

  const PhotoViewerScreen({
    super.key,
    this.title,
    this.imageUrl,
    this.images = const [],
  });

  @override
  Widget build(BuildContext context) {
    final activeUrl = imageUrl ?? (images.isNotEmpty ? images.first : null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title ?? 'Photo Viewer',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 520),
            child: AppImage(
              imageSource: activeUrl,
              fit: BoxFit.contain,
              borderRadius: 12,
              fallbackIcon: Icons.image_outlined,
            ),
          ),
        ),
      ),
    );
  }
}
