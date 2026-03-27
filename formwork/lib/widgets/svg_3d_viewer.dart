import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/colors.dart';

/// Interactive 3D extruded SVG viewer.
/// Drag horizontally to rotate the Y-axis. Drag vertically for tilt.
class Svg3dViewer extends StatefulWidget {
  final String svgContent;
  const Svg3dViewer({super.key, required this.svgContent});

  @override
  State<Svg3dViewer> createState() => _Svg3dViewerState();
}

class _Svg3dViewerState extends State<Svg3dViewer> with SingleTickerProviderStateMixin {
  double _rotY = -0.3;
  double _rotX = 0.15;
  late AnimationController _glowCtrl;
  late Animation<double> _glow;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(_glowCtrl);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TabChip(label: '3D View', selected: !_showOriginal, onTap: () => setState(() => _showOriginal = false)),
              const SizedBox(width: 8),
              _TabChip(label: 'Flat View', selected: _showOriginal, onTap: () => setState(() => _showOriginal = true)),
            ],
          ),
        ),

        // Viewer
        Expanded(
          child: GestureDetector(
            onPanUpdate: (d) {
              setState(() {
                _rotY += d.delta.dx * 0.008;
                _rotX -= d.delta.dy * 0.006;
                _rotX = _rotX.clamp(-0.8, 0.8);
              });
            },
            child: _showOriginal
                ? Center(
                    child: SvgPicture.string(widget.svgContent, fit: BoxFit.contain),
                  )
                : AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => CustomPaint(
                      painter: _Extruded3dPainter(rotY: _rotY, rotX: _rotX, glowOpacity: _glow.value),
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_rotY)
                            ..rotateX(_rotX),
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3 * _glow.value),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: SvgPicture.string(widget.svgContent, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // Hint
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pan_tool_alt_outlined, size: 12, color: Colors.white24),
              const SizedBox(width: 4),
              const Text('Drag to rotate', style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Background painter that draws extruded depth layers behind the SVG.
class _Extruded3dPainter extends CustomPainter {
  final double rotY;
  final double rotX;
  final double glowOpacity;

  const _Extruded3dPainter({required this.rotY, required this.rotX, required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const depth = 18.0;
    const layers = 12;

    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = layers; i >= 1; i--) {
      final t = i / layers;
      final offsetX = math.sin(rotY) * depth * t;
      final offsetY = -math.sin(rotX) * depth * t;

      paint.color = AppColors.primary.withValues(alpha: 0.04 + t * 0.06 * glowOpacity);
      paint.strokeWidth = 1.5;

      const hw = 140.0;
      const hh = 140.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + offsetX, cy + offsetY),
          width: hw * 2,
          height: hh * 2,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }

    // Grid lines on floor plane
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final x = cx - 150 + i * 44.0;
      canvas.drawLine(Offset(x, cy + 100), Offset(x + math.sin(rotY) * 20, cy + 150), gridPaint);
    }
    for (int i = 0; i < 4; i++) {
      final y = cy + 100 + i * 14.0;
      canvas.drawLine(Offset(cx - 150, y), Offset(cx + 150, y + math.sin(rotY) * 8), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_Extruded3dPainter old) => old.rotY != rotY || old.rotX != rotX;
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.primary : Colors.white12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
