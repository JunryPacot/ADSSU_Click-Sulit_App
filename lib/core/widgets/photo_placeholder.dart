import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PhotoPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final double iconSize;
  final double borderRadius;

  const PhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.shopping_bag_outlined,
    this.iconSize = 36,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.midGreen.withAlpha(40),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: AppColors.midGreen,
      ),
    );
  }
}

