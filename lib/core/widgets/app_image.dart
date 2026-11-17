import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders real item images supporting:
/// - Base64 encoded images (uploaded from device or camera)
/// - Local file paths (File(path))
/// - Network HTTP / HTTPS URLs (e.g. Firebase Storage, Google Profile, Web)
/// - Clean university placeholder fallback with category-specific icon
class AppImage extends StatelessWidget {
  final String? imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final String? semanticLabel;

  const AppImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.fallbackIcon = Icons.shopping_bag_outlined,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final src = imageSource?.trim();

    Widget imageWidget;

    if (src == null || src.isEmpty) {
      imageWidget = _buildPlaceholder();
    } else if (src.startsWith('data:image') || (src.length > 100 && !src.startsWith('http') && !src.contains('/'))) {
      // Base64 image
      try {
        final cleanBase64 = src.contains(',') ? src.split(',').last : src;
        final bytes = base64Decode(cleanBase64);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (_) {
        imageWidget = _buildPlaceholder();
      }
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      // Network Image
      imageWidget = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.paleGreen,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ),
          );
        },
      );
    } else if (!kIsWeb && File(src).existsSync()) {
      // Local Device File
      imageWidget = Image.file(
        File(src),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      // Fallback
      imageWidget = _buildPlaceholder();
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.midGreen.withAlpha(30)),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height != null && height! < 60) ? 22 : 36,
          color: AppColors.midGreen.withAlpha(180),
        ),
      ),
    );
  }
}

