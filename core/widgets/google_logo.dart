import 'package:flutter/material.dart';

/// Renders the authentic official 4-color Google "G" logo
/// using exact cubic Bézier geometry according to official Google brand specs.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OfficialGoogleLogoPainter(),
      ),
    );
  }
}

class _OfficialGoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 24.0;
    final double sy = size.height / 24.0;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Blue segment (#4285F4)
    final bluePath = Path()
      ..moveTo(23.745 * sx, 12.27 * sy)
      ..cubicTo(23.745 * sx, 11.57 * sy, 23.685 * sx, 10.87 * sy, 23.555 * sx, 10.20 * sy)
      ..lineTo(12.0 * sx, 10.20 * sy)
      ..lineTo(12.0 * sx, 14.71 * sy)
      ..lineTo(18.60 * sx, 14.71 * sy)
      ..cubicTo(18.31 * sx, 16.23 * sy, 17.46 * sx, 17.53 * sy, 16.20 * sx, 18.39 * sy)
      ..lineTo(16.20 * sx, 21.44 * sy)
      ..lineTo(20.08 * sx, 21.44 * sy)
      ..cubicTo(22.35 * sx, 19.35 * sy, 23.745 * sx, 16.27 * sy, 23.745 * sx, 12.27 * sy)
      ..close();
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(bluePath, paint);

    // 2. Green segment (#34A853)
    final greenPath = Path()
      ..moveTo(12.0 * sx, 24.0 * sy)
      ..cubicTo(15.24 * sx, 24.0 * sy, 17.95 * sx, 22.92 * sy, 19.93 * sx, 21.09 * sy)
      ..lineTo(16.05 * sx, 18.04 * sy)
      ..cubicTo(14.97 * sx, 18.76 * sy, 13.60 * sx, 19.20 * sy, 12.0 * sx, 19.20 * sy)
      ..cubicTo(8.88 * sx, 19.20 * sy, 6.23 * sx, 17.10 * sy, 5.28 * sx, 14.27 * sy)
      ..lineTo(1.25 * sx, 14.27 * sy)
      ..lineTo(1.25 * sx, 17.42 * sy)
      ..cubicTo(3.26 * sx, 21.36 * sy, 7.33 * sx, 24.0 * sy, 12.0 * sx, 24.0 * sy)
      ..close();
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(greenPath, paint);

    // 3. Yellow segment (#FBBC05)
    final yellowPath = Path()
      ..moveTo(5.28 * sx, 14.27 * sy)
      ..cubicTo(5.03 * sx, 13.55 * sy, 4.90 * sx, 12.78 * sy, 4.90 * sx, 12.0 * sy)
      ..cubicTo(4.90 * sx, 11.22 * sy, 5.03 * sx, 10.45 * sy, 5.28 * sx, 9.73 * sy)
      ..lineTo(5.28 * sx, 6.58 * sy)
      ..lineTo(1.25 * sx, 6.58 * sy)
      ..cubicTo(0.45 * sx, 8.18 * sy, 0.0 * sx, 9.99 * sy, 0.0 * sx, 12.0 * sy)
      ..cubicTo(0.0 * sx, 14.01 * sy, 0.45 * sx, 15.82 * sy, 1.25 * sx, 17.42 * sy)
      ..lineTo(5.28 * sx, 14.27 * sy)
      ..close();
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(yellowPath, paint);

    // 4. Red segment (#EA4335)
    final redPath = Path()
      ..moveTo(12.0 * sx, 4.75 * sy)
      ..cubicTo(13.77 * sx, 4.75 * sy, 15.35 * sx, 5.36 * sy, 16.60 * sx, 6.55 * sy)
      ..lineTo(20.02 * sx, 3.13 * sy)
      ..cubicTo(17.95 * sx, 1.19 * sy, 15.24 * sx, 0.0 * sy, 12.0 * sx, 0.0 * sy)
      ..cubicTo(7.33 * sx, 0.0 * sy, 3.26 * sx, 2.64 * sy, 1.25 * sx, 6.58 * sy)
      ..lineTo(5.28 * sx, 9.73 * sy)
      ..cubicTo(6.23 * sx, 6.90 * sy, 8.88 * sx, 4.75 * sy, 12.0 * sx, 4.75 * sy)
      ..close();
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
