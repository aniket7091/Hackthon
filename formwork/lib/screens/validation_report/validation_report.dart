import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/constants/colors.dart';

import '../../widgets/Dashboard/dashboard_left_sidebar.dart';
import '../../widgets/Dashboard/top_nav_bar.dart';

// ─── Main Screen with Sidebar ─────────────────────────────────────────────
class ValidationAnalysisScreen extends StatefulWidget {
  const ValidationAnalysisScreen({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => LayoutBuilder(builder: (context, constraints) {
        final isMedium = constraints.maxWidth > 600;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMedium ? 100 : 12,
            vertical: isMedium ? 60 : 12,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: const _ValidationReportModal(),
          ),
        );
      }),
    );
  }

  @override
  State<ValidationAnalysisScreen> createState() => _ValidationAnalysisScreenState();
}

class _ValidationAnalysisScreenState extends State<ValidationAnalysisScreen> {
  int _selectedIndex = 2; // Default to ANALYSIS

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;

          return Column(
            children: [
              // Top App Bar
              TopNavBar(
                isWide: isWide,
                selectedIndex: _selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              // Main content area
              Expanded(
                child: Row(
                  children: [
                    // Global Sidebar
                    LeftSidebar(compact: !isMedium),
                    // Main Content overlay
                    Expanded(
                      child: Stack(
                        children: [
                          // Background blurred project label
                          Positioned(
                            top: 24,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROJECT_ALPHA',
                                  style: TextStyle(
                                    color: AppColors.darkTextSecondary.withOpacity(0.18),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Structural Offsets & Support Calculations',
                                  style: TextStyle(
                                    color: AppColors.darkTextSecondary.withOpacity(0.12),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Modal overlay
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMedium ? 100 : 12,
                                vertical: isMedium ? 60 : 12,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 960),
                                width: double.infinity,
                                height: double.infinity, // Tight height parent for Expanded
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withOpacity(0.4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 80,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: const _ValidationReportModal(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



// ─── Validation Report Modal ──────────────────────────────────────────────
class _ValidationReportModal extends StatelessWidget {
  const _ValidationReportModal();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const _ModalHeader(),
            const SizedBox(height: 28),
            // Stats Row
            _StatsRow(),
            SizedBox(height: 48), // Increased spacing
            _ValidationLogsSection(),
            const SizedBox(height: 24),
            // Footer
            const _ModalFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Modal Header ─────────────────────────────────────────────────────────
class _ModalHeader extends StatelessWidget {
  const _ModalHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 640;
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          // Title block
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isNarrow ? constraints.maxWidth : 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkTextSecondary.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SYSTEM REPORT',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'VALIDATION_ANALYSIS_COMPLETE',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'Session ID: ',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                      TextSpan(
                        text: '#CAD-7742-XP',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(
                        text: '  •  Generated 2 mins ago',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Discard
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Discard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkTextSecondary,
                  side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              // Download
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Download Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 680;
      if (isNarrow) {
        return Column(
          children: [
            const _DesignScoreCard(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: _ActiveIssuesCard()),
                SizedBox(width: 16),
                Expanded(child: _AIConfidenceCard()),
              ],
            ),
          ],
        );
      }
      return SizedBox(
        height: 280, // Even more generous height for laptop view
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 32) * 5 / 11,
              child: const _DesignScoreCard(),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: (constraints.maxWidth - 32) * 3 / 11,
              child: const _ActiveIssuesCard(),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: (constraints.maxWidth - 32) * 3 / 11,
              child: const _AIConfidenceCard(),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Design Score Card ───────────────────────────────────────────────────
class _DesignScoreCard extends StatelessWidget {
  const _DesignScoreCard();

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'DESIGN OPTIMIZATION SCORE',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '94',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: AppColors.success, size: 14),
                            Text(
                              '+22%',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Text(
                          'IMPROVEMENT',
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _BeforeAfterLabel(label: 'BEFORE', value: '72%'),
                    _BeforeAfterLabel(
                        label: 'AFTER AI FIX',
                        value: '94%',
                        valueColor: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular progress
          const _CircularScoreWidget(score: 0.94),
        ],
      ),
    );
  }
}

class _BeforeAfterLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BeforeAfterLabel(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 10,
                letterSpacing: 0.5)),
        Text(value,
            style: TextStyle(
              color: valueColor ?? AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            )),
      ],
    );
  }
}

class _CircularScoreWidget extends StatelessWidget {
  final double score;
  const _CircularScoreWidget({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(
        painter: _CircularProgressPainter(score: score),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkCard,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.verified_rounded,
                color: AppColors.primary, size: 28),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double score;
  const _CircularProgressPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.outlineVariant.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.tertiary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * score,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Active Issues Card ──────────────────────────────────────────────────
class _ActiveIssuesCard extends StatelessWidget {
  const _ActiveIssuesCard();

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE ISSUES',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '12',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'CRITICAL',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              const Text(
                '02',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 2 / 12,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
              valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.error),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI Confidence Card ──────────────────────────────────────────────────
class _AIConfidenceCard extends StatelessWidget {
  const _AIConfidenceCard();

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI CONFIDENCE',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '99.2',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // High Reliability badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded,
                    color: AppColors.secondary, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'HIGH RELIABILITY',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card wrapper ────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Widget child;
  const _StatCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

// ─── Validation Logs Section ──────────────────────────────────────────────
class _ValidationLogsSection extends StatelessWidget {
  const _ValidationLogsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            const Text(
              'Validation Detail Logs',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Wrap(
              spacing: 12,
              children: [
                _FilterTab(label: 'ALL ENTRIES', active: true),
                _FilterTab(label: 'ERRORS ONLY', active: false),
                _FilterTab(label: 'AUTO-FIXED', active: false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Log entries
        const _LogEntry(
          icon: Icons.warning_rounded,
          iconBg: Color(0xFF3D1515),
          iconColor: AppColors.error,
          title: 'Non-Manifold Geometry Detected',
          description:
          'Vertex mismatch on junction #E-421. May cause failures during simulation of thermal loads.',
          badge: 'CRITICAL',
          badgeColor: AppColors.error,
          actions: [_LogAction(label: '✦ Apply AI Patch', isPrimary: true)],
          secondaryAction: 'Ignore',
        ),
        const SizedBox(height: 16),
        const _LogEntry(
          icon: Icons.check_circle_rounded,
          iconBg: Color(0xFF0D2B1A),
          iconColor: AppColors.success,
          title: 'Stress Distribution Optimized',
          description:
          'Neural Reasoner adjusted wall thickness of internal strut [Z-09] by +0.2mm to handle peak torsional loads.',
          badge: 'AUTO-FIXED',
          badgeColor: AppColors.success,
          chips: [
            _ChipData(label: 'ORIGINAL: 1.5MM', icon: Icons.history_rounded),
            _ChipData(label: 'NEW: 1.7MM', icon: Icons.check_rounded, color: AppColors.success),
          ],
        ),
        const SizedBox(height: 16),
        const _LogEntry(
          icon: Icons.psychology_rounded,
          iconBg: Color(0xFF1C1035),
          iconColor: AppColors.secondary,
          title: 'Material Efficiency Suggestion',
          description:
          'System identifies a 12% weight reduction potential by switching from Grade 5 Titanium to Al-Alloy Composite LX-9.',
          badge: 'AI INSIGHT',
          badgeColor: AppColors.secondary,
          hasRecalcLink: true,
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterTab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: TextStyle(
          color:
          active ? AppColors.darkTextPrimary : AppColors.darkTextSecondary,
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.8,
          decoration: active ? TextDecoration.underline : null,
          decorationColor: AppColors.primary,
          decorationThickness: 2,
        ),
      ),
    );
  }
}

class _LogAction {
  final String label;
  final bool isPrimary;
  const _LogAction({required this.label, this.isPrimary = false});
}

class _ChipData {
  final String label;
  final IconData icon;
  final Color color;
  const _ChipData(
      {required this.label,
        required this.icon,
        this.color = AppColors.darkTextSecondary});
}

class _LogEntry extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final List<_LogAction> actions;
  final String? secondaryAction;
  final List<_ChipData> chips;
  final bool hasRecalcLink;

  const _LogEntry({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    this.actions = const [],
    this.secondaryAction,
    this.chips = const [],
    this.hasRecalcLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                if (actions.isNotEmpty || secondaryAction != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...actions.map((a) => GestureDetector(
                        onTap: () {},
                        child: Text(
                          a.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                      if (secondaryAction != null)
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            secondaryAction!,
                            style: const TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: chips
                        .map((c) => _InfoChip(data: c))
                        .toList(),
                  ),
                ],
                if (hasRecalcLink) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Recalculate with LX-9',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            color: AppColors.secondary, size: 16),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withOpacity(0.4)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final _ChipData data;
  const _InfoChip({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 12, color: data.color),
          const SizedBox(width: 5),
          Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modal Footer ─────────────────────────────────────────────────────────
class _ModalFooter extends StatelessWidget {
  const _ModalFooter();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SYSTEM STATUS: STABLE',
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Container(
          width: 1,
          height: 12,
          color: AppColors.outlineVariant,
        ),
        const Text(
          'LATENCY: 14MS',
          style: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const Text(
          'End of Validation Report for PROJECT_OMEGA_V2.0.4',
          style: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}