import 'package:flutter/material.dart';

class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: MeshPainter()),
    );
  }
}

class MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintPurple = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 0.9,
        colors: [
          const Color(0xFF6E06D0).withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paintCyan = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomRight,
        radius: 0.9,
        colors: [
          const Color(0xFF8FF5FF).withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintPurple);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintCyan);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}