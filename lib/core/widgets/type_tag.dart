import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TypeTag extends StatelessWidget {
  final String type; // SELL, EXCHANGE, DONATE
  final bool isCompact;

  const TypeTag({
    super.key,
    required this.type,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type.toUpperCase()) {
      case 'SELL':
        bg = AppColors.primaryDarkGreen;
        fg = AppColors.cardWhite;
        break;
      case 'EXCHANGE':
        bg = AppColors.midGreen;
        fg = AppColors.cardWhite;
        break;
      case 'DONATE':
      default:
        bg = AppColors.accentGold;
        fg = AppColors.textDark;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: isCompact ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

