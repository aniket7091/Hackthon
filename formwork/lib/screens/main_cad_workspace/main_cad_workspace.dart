import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/constants/colors.dart';


class MainCardWorkSpaceScreen extends StatefulWidget {
  const MainCardWorkSpaceScreen({super.key});

  @override
  State<MainCardWorkSpaceScreen> createState() => _MainCardWorkSpaceScreenState();
}

class _MainCardWorkSpaceScreenState extends State<MainCardWorkSpaceScreen> {
  int _selectedTool = 0; // 0=cursor, 1=square, 2=circle, 3=triangle(share), 4=pentagon

  void _onToolSelected(int index) {
    setState(() {
      _selectedTool = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                if (isNarrow) {
                  // Stack vertically on small screens
                  return Column(
                    children: [
                      Expanded(child: _CanvasArea(selectedTool: _selectedTool)),
                      SizedBox(
                        height: 340,
                        child: _RightPanel(),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _LeftToolbar(selectedTool: _selectedTool, onToolSelected: _onToolSelected),
                    Expanded(
                      child: _CanvasArea(selectedTool: _selectedTool),
                    ),
                    SizedBox(
                      width: constraints.maxWidth < 1000 ? 260 : 300,
                      child: _RightPanel(),
                    ),
                  ],
                );
              },
            ),
          ),
          _BottomBar(), // Full width at the bottom!
        ],
      ),
    );
  }
}

// ===== TOP NAV BAR =====
class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          Text(
            'SYNTHETIC_ARCHITECT',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 32),
          // Nav Items
          _NavItem(label: 'Projects', active: false),
          const SizedBox(width: 8),
          _NavItem(label: 'Simulations', active: true),
          const SizedBox(width: 8),
          _NavItem(label: 'Library', active: false),
          const Spacer(),
          // Upload button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.outlineVariant),
              foregroundColor: AppColors.darkTextPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Upload', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          // Validate button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Validate',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          // Icon buttons
          _NavIconButton(icon: Icons.save_outlined),
          _NavIconButton(icon: Icons.settings_outlined),
          _NavIconButton(icon: Icons.notifications_outlined),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceContainerHighest,
            child: Icon(Icons.person, size: 18, color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  const _NavItem({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: active
            ? BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 2),
          ),
        )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.darkTextSecondary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  const _NavIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: AppColors.darkTextSecondary),
      onPressed: () {},
      splashRadius: 18,
    );
  }
}

// ===== LEFT TOOLBAR =====
class _LeftToolbar extends StatelessWidget {
  final int selectedTool;
  final ValueChanged<int> onToolSelected;

  const _LeftToolbar({required this.selectedTool, required this.onToolSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _ToolbarBtn(icon: Icons.near_me, active: selectedTool == 0, onTap: () => onToolSelected(0)),
          const SizedBox(height: 4),
          _ToolbarBtn(icon: Icons.crop_square_outlined, active: selectedTool == 1, onTap: () => onToolSelected(1)),
          const SizedBox(height: 4),
          _ToolbarBtn(icon: Icons.circle_outlined, active: selectedTool == 2, onTap: () => onToolSelected(2)),
          const SizedBox(height: 4),
          _ToolbarBtn(icon: Icons.share_outlined, active: selectedTool == 3, onTap: () => onToolSelected(3)),
          const SizedBox(height: 4),
          _ToolbarBtn(icon: Icons.pentagon_outlined, active: selectedTool == 4, onTap: () => onToolSelected(4)),
          const Spacer(),
          _ToolbarBtn(icon: Icons.help_outline, active: false, onTap: () {}),
          const SizedBox(height: 4),
          _ToolbarBtn(icon: Icons.terminal, active: false, onTap: () {}),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToolbarBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active
              ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? AppColors.primary : AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}

// ===== CANVAS AREA =====
class _CanvasArea extends StatelessWidget {
  final int selectedTool;
  const _CanvasArea({required this.selectedTool});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBackground,
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: _GridPainter(),
            child: const SizedBox.expand(),
          ),
          // Centered shape with tooltip
          Center(
            child: _ShapeWithTooltip(selectedTool: selectedTool),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2030)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _ShapeWithTooltip extends StatelessWidget {
  final int selectedTool;
  const _ShapeWithTooltip({required this.selectedTool});

  @override
  Widget build(BuildContext context) {
    CustomPainter shapePainter;
    String propLabel = 'RADIUS';
    String propValue = '80.00mm';
    if (selectedTool == 1) {
      shapePainter = _SquarePainter();
      propLabel = 'SIDE_LENGTH';
      propValue = '160.00mm';
    } else if (selectedTool == 3) {
      shapePainter = _TrianglePainter();
      propLabel = 'BASE_WIDTH';
      propValue = '160.00mm';
    } else if (selectedTool == 4) {
      shapePainter = _PentagonPainter();
      propLabel = 'CIRCUMRADIUS';
      propValue = '80.00mm';
    } else {
      shapePainter = _CirclePainter(); // Default or circle
      propLabel = 'RADIUS';
      propValue = '80.00mm';
    }

    return SizedBox(
      width: 320,
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dashed rectangle selection
          CustomPaint(
            painter: _DashedRectPainter(),
            child: const SizedBox(width: 320, height: 280),
          ),
          // Dynamic shape
          Positioned(
            left: 60,
            top: 40,
            child: CustomPaint(
              painter: shapePainter,
              child: const SizedBox(width: 200, height: 200),
            ),
          ),
          // Diagonal line from top-center to bottom-right
          Positioned.fill(
            child: CustomPaint(painter: _DiagonalLinePainter()),
          ),
          // Corner handles
          ..._cornerHandles(),
          // Top-center handle
          Positioned(
            top: -4,
            left: 156,
            child: _Handle(),
          ),
          // Entity Properties tooltip - top left
          Positioned(
            top: -16,
            left: -10,
            child: _EntityPropertiesCard(propLabel: propLabel, propValue: propValue),
          ),
        ],
      ),
    );
  }

  List<Widget> _cornerHandles() {
    return [
      Positioned(top: -4, left: -4, child: _Handle()),
      Positioned(top: -4, right: -4, child: _Handle()),
      Positioned(bottom: -4, left: -4, child: _Handle()),
      Positioned(bottom: -4, right: -4, child: _Handle()),
    ];
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: AppColors.darkBackground, width: 1.5),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    _drawDashedRect(canvas, Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dash = 8.0;
    const gap = 5.0;
    // Top
    _dashLine(canvas, Offset(rect.left, rect.top), Offset(rect.right, rect.top), dash, gap, paint);
    // Bottom
    _dashLine(canvas, Offset(rect.left, rect.bottom), Offset(rect.right, rect.bottom), dash, gap, paint);
    // Left
    _dashLine(canvas, Offset(rect.left, rect.top), Offset(rect.left, rect.bottom), dash, gap, paint);
    // Right
    _dashLine(canvas, Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), dash, gap, paint);
  }

  void _dashLine(Canvas canvas, Offset a, Offset b, double dash, double gap, Paint paint) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final nx = dx / len;
    final ny = dy / len;
    double dist = 0;
    bool drawing = true;
    while (dist < len) {
      final seg = drawing ? math.min(dash, len - dist) : math.min(gap, len - dist);
      if (drawing) {
        canvas.drawLine(
          Offset(a.dx + nx * dist, a.dy + ny * dist),
          Offset(a.dx + nx * (dist + seg), a.dy + ny * (dist + seg)),
          paint,
        );
      }
      dist += seg;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => false;
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) => false;
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.7)
      ..strokeWidth = 1.2;
    // From top-center handle to bottom-right handle
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DiagonalLinePainter old) => false;
}

class _EntityPropertiesCard extends StatelessWidget {
  final String propLabel;
  final String propValue;

  const _EntityPropertiesCard({required this.propLabel, required this.propValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2233),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTITY_PROPERTIES',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          _PropRow(label: propLabel, value: propValue),
          const SizedBox(height: 2),
          _PropRow(label: 'CENTER_X', value: '300.00'),
        ],
      ),
    );
  }
}

class _SquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_SquarePainter old) => false;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => false;
}

class _PentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final point = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PentagonPainter old) => false;
}

class _PropRow extends StatelessWidget {
  final String label;
  final String value;
  const _PropRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ===== BOTTOM STATUS BAR =====
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SYSTEM_LIVE',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'X: 342.12  Y: 891.05',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Icon(Icons.search_outlined, size: 16, color: AppColors.darkTextSecondary),
          const SizedBox(width: 8),
          Icon(Icons.zoom_out_outlined, size: 16, color: AppColors.darkTextSecondary),
        ],
      ),
    );
  }
}

// ===== RIGHT PANEL =====
class _RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Neural Reasoner header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEURAL_REASONER',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'PROCESSING...',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Auto-fix all button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.25),
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    'AUTO-FIX ALL DETECTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            // Issue cards
            _IssueCard(
              borderColor: AppColors.error,
              icon: Icons.error,
              iconColor: AppColors.error,
              title: 'Geometric Conflict',
              badge: 'CRITICAL',
              badgeColor: AppColors.error,
              description:
              'Overlap detected between Main_Hull and Core_Vent_01. Non-manifold geometry will fail export.',
              suggestion: '"Suggestion: Offset Core_Vent_01 by -2.4mm on Y-Axis."',
              actionLabel: 'FIX THIS NOW',
              actionColor: AppColors.error,
              actionTextColor: Colors.white,
            ),
            _IssueCard(
              borderColor: AppColors.warning,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              title: 'Tolerance Warning',
              badge: 'WARNING',
              badgeColor: AppColors.warning,
              description:
              'Wall thickness in Zone B-4 drops below 0.8mm. Structural integrity is potentially compromised.',
              suggestion: null,
              actionLabel: 'ADJUST THICKNESS',
              actionColor: Colors.transparent,
              actionTextColor: AppColors.primary,
              actionBorder: AppColors.outlineVariant,
            ),
            _IssueCard(
              borderColor: AppColors.secondary,
              icon: Icons.lightbulb_outline,
              iconColor: AppColors.secondary,
              title: 'Efficiency Gain',
              badge: 'IDEA',
              badgeColor: AppColors.secondary,
              description:
              'Replacing fillets with chamfers on internal edges could reduce mesh count by 14%.',
              suggestion: null,
              actionLabel: 'APPLY OPTIMIZATION',
              actionColor: Colors.transparent,
              actionTextColor: AppColors.primary,
              actionBorder: AppColors.outlineVariant,
            ),
            // Bottom status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ANALYSIS_DEPTH: 84%',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'V1.0.42_STABLE',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final String description;
  final String? suggestion;
  final String actionLabel;
  final Color actionColor;
  final Color actionTextColor;
  final Color? actionBorder;

  const _IssueCard({
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.description,
    this.suggestion,
    required this.actionLabel,
    required this.actionColor,
    required this.actionTextColor,
    this.actionBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        color: AppColors.darkCard,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            description,
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 8),
            Text(
              suggestion!,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: actionTextColor,
                side: actionBorder != null
                    ? BorderSide(color: actionBorder!)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                elevation: 0,
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                  color: actionTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}