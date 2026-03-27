import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/validation_model.dart';
import '../../providers/design_provider.dart';

class CadWorkspaceScreen extends StatefulWidget {
  const CadWorkspaceScreen({super.key});

  @override
  State<CadWorkspaceScreen> createState() => _CadWorkspaceScreenState();
}

class _CadWorkspaceScreenState extends State<CadWorkspaceScreen> {
  String? _rawSvg;

  // ─── File Upload ───────────────────────────────────────────────────────────
  Future<void> _pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    final jsonString = utf8.decode(bytes);
    if (!mounted) return;
    context.read<DesignProvider>().setDesignJson(jsonString);
    await context.read<DesignProvider>().upload();
  }

  Future<void> _pickSvgFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    setState(() => _rawSvg = utf8.decode(bytes));
  }

  // ─── Download PDF ──────────────────────────────────────────────────────────
  Future<void> _downloadReport(DesignProvider provider) async {
    final bytes = await provider.generateReport();
    if (bytes == null || !mounted) return;
    _showSnack('✅ Report ready — saving to downloads is available on mobile/desktop.', Colors.green);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Consumer<DesignProvider>(
        builder: (context, dp, _) {
          return Column(
            children: [
              _buildTopBar(dp),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) {
                    return _buildWideLayout(dp);
                  }
                  return _buildNarrowLayout(dp);
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(DesignProvider dp) {
    return Container(
      height: 56,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: const Text(
              'FormWork AI — Workspace',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
          ),
          const Spacer(),
          // Upload JSON
          _TopBarBtn(
            label: 'Upload JSON',
            icon: Icons.upload_file,
            onTap: _pickJsonFile,
          ),
          const SizedBox(width: 8),
          // Upload SVG
          _TopBarBtn(
            label: 'Upload SVG',
            icon: Icons.image_outlined,
            onTap: _pickSvgFile,
          ),
          const SizedBox(width: 8),
          // Validate
          _TopBarBtn(
            label: 'Validate',
            icon: Icons.verified_outlined,
            color: AppColors.primary,
            isLoading: dp.validateState == DesignLoadState.loading,
            onTap: dp.hasDesign ? () => dp.validate() : null,
          ),
          const SizedBox(width: 8),
          // Auto-fix
          _TopBarBtn(
            label: 'Auto-Fix',
            icon: Icons.auto_fix_high,
            color: Colors.greenAccent,
            isLoading: dp.autofixState == DesignLoadState.loading,
            onTap: dp.hasDesign ? () => dp.autofix() : null,
          ),
          const SizedBox(width: 8),
          // Download Report
          _TopBarBtn(
            label: 'Report',
            icon: Icons.picture_as_pdf,
            color: Colors.orangeAccent,
            isLoading: dp.reportState == DesignLoadState.loading,
            onTap: dp.hasDesign ? () => _downloadReport(dp) : null,
          ),
        ],
      ),
    );
  }

  // ─── Wide Layout (3-panel) ─────────────────────────────────────────────────
  Widget _buildWideLayout(DesignProvider dp) {
    return Row(
      children: [
        // Left: Shape List
        SizedBox(width: 240, child: _buildShapeList(dp)),
        // Center: Canvas
        Expanded(child: _buildCanvas(dp)),
        // Right: Issues + AI Panel
        SizedBox(width: 320, child: _buildRightPanel(dp)),
      ],
    );
  }

  Widget _buildNarrowLayout(DesignProvider dp) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.darkSurface,
            child: const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Canvas'),
                Tab(text: 'Issues'),
                Tab(text: 'AI Panel'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCanvas(dp),
                _buildIssueList(dp),
                _buildAiPanel(dp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shape List (left panel) ───────────────────────────────────────────────
  Widget _buildShapeList(DesignProvider dp) {
    final shapes = dp.activeShapes;
    return Container(
      color: AppColors.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SHAPES',
              style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: shapes.isEmpty
                ? const Center(child: Text('No shapes loaded', style: TextStyle(color: Colors.white38, fontSize: 12)))
                : ListView.builder(
                    itemCount: shapes.length,
                    itemBuilder: (ctx, i) {
                      final s = shapes[i];
                      final issue = dp.activeIssues.where((iss) => iss.shapeId == s.id).firstOrNull;
                      final color = issue == null
                          ? Colors.white70
                          : issue.type == 'error'
                              ? Colors.redAccent
                              : Colors.orangeAccent;
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.crop_square_rounded, color: color, size: 16),
                        title: Text(s.type, style: TextStyle(color: color, fontSize: 12)),
                        subtitle: Text('${s.x.toInt()}, ${s.y.toInt()}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        onTap: issue != null ? () => dp.selectIssue(issue) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Canvas (center panel) ─────────────────────────────────────────────────
  Widget _buildCanvas(DesignProvider dp) {
    if (_rawSvg != null) {
      return Container(
        color: const Color(0xFF0B0E14),
        child: Center(
          child: SvgPicture.string(_rawSvg!, fit: BoxFit.contain),
        ),
      );
    }

    final shapes = dp.activeShapes;
    final issues = dp.activeIssues;

    if (shapes.isEmpty) {
      return Container(
        color: const Color(0xFF0B0E14),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file_outlined, size: 56, color: AppColors.primary.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text(
                'Upload a JSON or SVG design to get started',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0B0E14),
      child: InteractiveViewer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CustomPaint(
            painter: _DesignCanvasPainter(shapes: shapes, issues: issues),
            child: const SizedBox(width: 800, height: 600),
          ),
        ),
      ),
    );
  }

  // ─── Right Panel (issues + AI) ─────────────────────────────────────────────
  Widget _buildRightPanel(DesignProvider dp) {
    return Container(
      color: AppColors.darkSurface,
      child: Column(
        children: [
          Expanded(flex: 3, child: _buildIssueList(dp)),
          const Divider(color: Colors.white12, height: 1),
          Expanded(flex: 2, child: _buildAiPanel(dp)),
        ],
      ),
    );
  }

  Widget _buildIssueList(DesignProvider dp) {
    final issues = dp.activeIssues;
    final score = dp.autofixResult?.afterScore ?? dp.validationResult?.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('ISSUES', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scoreColor(score).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _scoreColor(score).withOpacity(0.4)),
                  ),
                  child: Text(
                    'Score: ${score.toStringAsFixed(1)}',
                    style: TextStyle(color: _scoreColor(score), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        if (dp.validateState == DesignLoadState.loading || dp.autofixState == DesignLoadState.loading)
          const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
        if (issues.isEmpty && dp.validateState != DesignLoadState.loading)
          const Expanded(
            child: Center(child: Text('No issues yet — run Validate!', style: TextStyle(color: Colors.white38, fontSize: 12))),
          ),
        if (issues.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: issues.length,
              itemBuilder: (ctx, i) {
                final issue = issues[i];
                final isSelected = dp.selectedIssue?.id == issue.id;
                final color = issue.status == 'fixed'
                    ? Colors.greenAccent
                    : issue.type == 'error'
                        ? Colors.redAccent
                        : Colors.orangeAccent;
                return GestureDetector(
                  onTap: () => dp.selectIssue(issue),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? color.withOpacity(0.5) : Colors.white12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          issue.status == 'fixed' ? Icons.check_circle_outline : Icons.circle,
                          color: color,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(issue.message, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(issue.ruleId, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAiPanel(DesignProvider dp) {
    final issue = dp.selectedIssue;
    final suggestion = dp.aiSuggestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('AI SUGGESTION', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (issue != null)
                TextButton.icon(
                  onPressed: dp.aiState == DesignLoadState.loading ? null : dp.getAiSuggestion,
                  icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                  label: const Text('Ask AI', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        Expanded(
          child: dp.aiState == DesignLoadState.loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : suggestion == null
                  ? Center(
                      child: Text(
                        issue == null ? 'Select an issue to get AI help.' : 'Tap "Ask AI" to analyze.',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (suggestion.explanation.isNotEmpty) ...[
                            const Text('Explanation', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(suggestion.explanation, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                            const SizedBox(height: 14),
                          ],
                          if (suggestion.steps.isNotEmpty) ...[
                            const Text('Steps', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            ...suggestion.steps.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${e.key + 1}. ', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                                    Expanded(child: Text(e.value, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (suggestion.confidence != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Text('Confidence: ', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                Text(
                                  '${(suggestion.confidence! * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Color _scoreColor(double score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

// ─── Canvas Painter ────────────────────────────────────────────────────────────
class _DesignCanvasPainter extends CustomPainter {
  final List shapes;
  final List<ValidationIssue> issues;

  const _DesignCanvasPainter({required this.shapes, required this.issues});

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final shapeId = shape.id;
      final issue = issues.where((i) => i.shapeId == shapeId).firstOrNull;
      final Paint fill = Paint()
        ..color = const Color(0xFF1E2A3A)
        ..style = PaintingStyle.fill;
      final Paint border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (issue?.status == 'fixed') {
        border.color = Colors.greenAccent.withOpacity(0.8);
      } else if (issue?.type == 'error') {
        border.color = Colors.redAccent.withOpacity(0.8);
      } else if (issue?.type == 'warning') {
        border.color = Colors.orangeAccent.withOpacity(0.8);
      } else {
        border.color = AppColors.primary.withOpacity(0.4);
      }

      final rect = Rect.fromLTWH(shape.x, shape.y, shape.width, shape.height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), fill);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), border);

      // Label
      final tp = TextPainter(
        text: TextSpan(text: shape.type, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(shape.x + 4, shape.y + 4));
    }
  }

  @override
  bool shouldRepaint(_DesignCanvasPainter old) =>
      old.shapes != shapes || old.issues != issues;
}

// ─── Top Bar Button ────────────────────────────────────────────────────────────
class _TopBarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _TopBarBtn({
    required this.label,
    required this.icon,
    this.color = Colors.white70,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isLoading
              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}
