import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final radius = min(w, h) / 2;
    final cx = w / 2;
    final cy = h / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * pi / 180;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexCategoryBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isSelected;

  const HexCategoryBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.size = 64,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryDarkGreen : AppColors.cardWhite,
              border: Border.all(
                color: isSelected ? AppColors.accentGold : AppColors.borderLight,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDarkGreen.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                color: isSelected
                    ? AppColors.primaryDarkGreen
                    : AppColors.paleGreen.withAlpha(120),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: size * 0.44,
                  color: isSelected ? AppColors.cardWhite : AppColors.primaryDarkGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 16,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primaryDarkGreen : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

