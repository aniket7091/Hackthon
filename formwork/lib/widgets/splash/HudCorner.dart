import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class HudCorner extends StatelessWidget {
  final double? top, bottom, left, right;
  final bool flipH, flipV;
  const HudCorner(
      {this.top, this.bottom, this.left, this.right, required this.flipH, required this.flipV});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(flipH ? -1.0 : 1.0, flipV ? -1.0 : 1.0),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CustomPaint(painter: _CornerPainter()),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}