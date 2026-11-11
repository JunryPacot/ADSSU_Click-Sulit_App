import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isAccent;
  final IconData? icon;
  final double height;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isAccent = false,
    this.icon,
    this.height = 48,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    if (isSecondary) {
      bg = AppColors.cardWhite;
      fg = AppColors.primaryDarkGreen;
      borderSide = const BorderSide(color: AppColors.primaryDarkGreen, width: 1.5);
    } else if (isAccent) {
      bg = AppColors.accentGold;
      fg = AppColors.textDark;
    } else {
      bg = AppColors.primaryDarkGreen;
      fg = AppColors.cardWhite;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: AppColors.mutedGray.withAlpha(50),
      disabledForegroundColor: AppColors.mutedGray,
      elevation: 0,
      minimumSize: isFullWidth ? Size.fromHeight(height) : Size(120, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

