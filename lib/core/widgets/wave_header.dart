import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Layer 1: Dark Green Base Wave
    final paintDark = Paint()
      ..color = AppColors.primaryDarkGreen
      ..style = PaintingStyle.fill;

    final pathDark = Path();
    pathDark.moveTo(0, 0);
    pathDark.lineTo(w, 0);
    pathDark.lineTo(w, h * 0.72);
    pathDark.quadraticBezierTo(w * 0.70, h * 1.05, w * 0.35, h * 0.85);
    pathDark.quadraticBezierTo(w * 0.15, h * 0.72, 0, h * 0.88);
    pathDark.close();
    canvas.drawPath(pathDark, paintDark);

    // Layer 2: Pale Mint Swoosh Accent
    final paintMint = Paint()
      ..color = AppColors.paleGreen.withAlpha(60)
      ..style = PaintingStyle.fill;

    final pathMint = Path();
    pathMint.moveTo(0, 0);
    pathMint.lineTo(w, 0);
    pathMint.lineTo(w, h * 0.78);
    pathMint.quadraticBezierTo(w * 0.65, h * 1.10, w * 0.30, h * 0.90);
    pathMint.quadraticBezierTo(w * 0.10, h * 0.78, 0, h * 0.94);
    pathMint.close();
    canvas.drawPath(pathMint, paintMint);

    // Layer 3: Gold Ribbon Stroke
    final paintGold = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pathGold = Path();
    pathGold.moveTo(0, h * 0.88);
    pathGold.quadraticBezierTo(w * 0.15, h * 0.72, w * 0.35, h * 0.85);
    pathGold.quadraticBezierTo(w * 0.70, h * 1.05, w, h * 0.72);
    canvas.drawPath(pathGold, paintGold);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WaveHeader extends StatelessWidget {
  final double height;
  final Widget? child;

  const WaveHeader({
    super.key,
    this.height = 160,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(double.infinity, height),
          painter: WaveHeaderPainter(),
        ),
        if (child != null)
          SizedBox(
            height: height,
            width: double.infinity,
            child: child!,
          ),
      ],
    );
  }
}

