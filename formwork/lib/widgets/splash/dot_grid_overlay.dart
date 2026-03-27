import 'package:flutter/material.dart';

class GridOverlay extends StatelessWidget {
  final AnimationController controller;
  const GridOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FF5FF).withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}