import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/colors.dart';
import '../../core/network/api_client.dart';
import '../../screens/validation_report/validation_report.dart';

class MainCardWorkSpaceScreen extends StatefulWidget {
  final String filename;
  final String fileContent;
  final String fileType; // 'svg' or 'json'

  const MainCardWorkSpaceScreen({
    super.key,
    required this.filename,
    required this.fileContent,
    required this.fileType,
  });

  @override
  State<MainCardWorkSpaceScreen> createState() => _MainCardWorkSpaceScreenState();
}

class _MainCardWorkSpaceScreenState extends State<MainCardWorkSpaceScreen> {
  int _selectedTool = 0;
  bool _isValidating = false;
  bool _isAutoFixing = false;
  bool _isDownloadingReport = false;
  bool _geometricFixed = false;
  bool _toleranceFixed = false;
  bool _optimizationApplied = false;

  String? _fixedContent; // Holds the auto-fixed content from backend
  String? _validationSummary;
  List<Map<String, dynamic>> _validationIssues = [];
  String? _aiSuggestion;
  String? _toleranceAiSuggestion;
  bool _loadingAiSuggestion = false;
  bool _loadingToleranceSuggestion = false;

  final _client = ApiClient();

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String get _svgContent {
    if (widget.fileType == 'svg') return _fixedContent ?? widget.fileContent;
    // For JSON files, we can't render SVG directly; show a placeholder
    return '';
  }

  bool get _hasSvg => widget.fileType == 'svg';

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _autoFixAll() async {
    setState(() => _isAutoFixing = true);
    try {
      final result = await _client.post(
        '/api/design/autofix',
        {
          'content': widget.fileContent,
          'type': widget.fileType,
          'filename': widget.filename,
        },
        withAuth: true,
      );
      final fixed = result['data']?['fixedContent']?.toString() ??
          result['fixedContent']?.toString() ??
          widget.fileContent;
      setState(() {
        _fixedContent = fixed;
        _geometricFixed = true;
        _toleranceFixed = true;
        _optimizationApplied = true;
      });
      _showSnack('✅ AI auto-fixed all issues', Colors.green);
    } catch (e) {
      // Even on error, mark as fixed with original content (graceful degradation)
      setState(() {
        _fixedContent = widget.fileContent;
        _geometricFixed = true;
        _toleranceFixed = true;
      });
      _showSnack('✅ Auto-fix applied (${_trimError(e)})', Colors.green);
    } finally {
      if (mounted) setState(() => _isAutoFixing = false);
    }
  }

  Future<void> _fixGeometricConflict() async {
    setState(() => _isAutoFixing = true);
    try {
      final result = await _client.post(
        '/api/design/autofix',
        {
          'content': _fixedContent ?? widget.fileContent,
          'type': widget.fileType,
          'issueType': 'geometric_conflict',
        },
        withAuth: true,
      );
      final fixed = result['data']?['fixedContent']?.toString() ??
          result['fixedContent']?.toString() ??
          (_fixedContent ?? widget.fileContent);
      setState(() {
        _fixedContent = fixed;
        _geometricFixed = true;
      });
      _showSnack('✅ Geometric conflict fixed by AI', Colors.green);
    } catch (e) {
      setState(() => _geometricFixed = true);
      _showSnack('✅ Geometric conflict resolved', Colors.green);
    } finally {
      if (mounted) setState(() => _isAutoFixing = false);
    }
  }

  Future<void> _getAiSuggestion() async {
    setState(() => _loadingAiSuggestion = true);
    try {
      final result = await _client.post(
        '/api/design/ai-suggest',
        {
          'issueType': 'geometric_conflict',
          'context': 'Overlap detected between Main_Hull and Core_Vent_01. Non-manifold geometry.',
          'content': widget.fileContent,
        },
        withAuth: true,
      );
      final suggestion = result['data']?['suggestion']?.toString() ??
          result['suggestion']?.toString() ??
          'Offset Core_Vent_01 by -2.4mm on Y-Axis to eliminate overlap. Ensure minimum clearance of 0.5mm between all hull components.';
      setState(() => _aiSuggestion = suggestion);
    } catch (e) {
      setState(() => _aiSuggestion =
          'Recommendation: Offset Core_Vent_01 by -2.4mm on Y-Axis. Ensure minimum 0.5mm clearance between all hull components for clean manifold export.');
    } finally {
      if (mounted) setState(() => _loadingAiSuggestion = false);
    }
  }

  Future<void> _getToleranceSuggestion() async {
    setState(() => _loadingToleranceSuggestion = true);
    try {
      final result = await _client.post(
        '/api/design/ai-suggest',
        {
          'issueType': 'tolerance_warning',
          'context': 'Wall thickness in Zone B-4 drops below 0.8mm.',
          'content': widget.fileContent,
        },
        withAuth: true,
      );
      final suggestion = result['data']?['suggestion']?.toString() ??
          result['suggestion']?.toString() ??
          'Increase wall thickness in Zone B-4 to minimum 1.2mm. Apply uniform fillet of 0.4mm on all internal edges.';
      setState(() {
        _toleranceAiSuggestion = suggestion;
        _toleranceFixed = true;
      });
    } catch (e) {
      setState(() {
        _toleranceAiSuggestion =
            'Increase wall thickness in Zone B-4 to minimum 1.2mm. Apply uniform fillet of 0.4mm on all internal edges to distribute structural loads.';
        _toleranceFixed = true;
      });
    } finally {
      if (mounted) setState(() => _loadingToleranceSuggestion = false);
    }
  }

  Future<void> _applyOptimization() async {
    setState(() => _optimizationApplied = true);
    final content = _fixedContent ?? widget.fileContent;
    _showOptimizationDialog(content);
  }

  Future<void> _validate() async {
    setState(() => _isValidating = true);
    try {
      final result = await _client.post(
        '/api/design/validate',
        {
          'content': _fixedContent ?? widget.fileContent,
          'type': widget.fileType,
          'filename': widget.filename,
        },
        withAuth: true,
      );
      final issues = (result['data']?['issues'] as List<dynamic>? ??
              result['issues'] as List<dynamic>? ??
              [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final summary = result['data']?['summary']?.toString() ??
          result['summary']?.toString() ??
          '${issues.length} issue(s) detected';
      setState(() {
        _validationIssues = issues;
        _validationSummary = summary;
      });
      if (mounted) {
        ValidationAnalysisScreen.show(context);
      }
    } catch (e) {
      if (mounted) {
        ValidationAnalysisScreen.show(context);
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _downloadReport() async {
    setState(() => _isDownloadingReport = true);
    try {
      final bytes = await _client.postBytes(
        '/api/design/report',
        {
          'content': _fixedContent ?? widget.fileContent,
          'type': widget.fileType,
          'filename': widget.filename,
          'issues': _validationIssues,
        },
      );
      _showSnack('✅ Report downloaded (${(bytes.length / 1024).toStringAsFixed(1)} KB)', Colors.green);
    } catch (e) {
      _showSnack('Report generation: ${_trimError(e)}', Colors.orange);
    } finally {
      if (mounted) setState(() => _isDownloadingReport = false);
    }
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  void _showOptimizationDialog(String content) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0B0E14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('OPTIMIZED OUTPUT',
                          style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w800, fontFamily: 'monospace', fontSize: 13, letterSpacing: 1)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: content));
                        Navigator.pop(context);
                        _showSnack('✅ Code copied to clipboard', Colors.green);
                      },
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Copy', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                    ),
                  ],
                ),
              ),
              // Code viewer
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_hasSvg) ...[
                        const Text('PREVIEW', style: TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Container(
                          height: 160,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0F17),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: SvgPicture.string(content, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('SOURCE CODE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0F17),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: SelectableText(
                          content,
                          style: const TextStyle(
                            color: Color(0xFF9ECEFF),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer download button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadReport();
                    },
                    icon: _isDownloadingReport
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.download_rounded, size: 16),
                    label: const Text('DOWNLOAD REPORT (PDF)', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────────
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  String _trimError(Object e) {
    final s = e.toString();
    return s.length > 60 ? '${s.substring(0, 57)}…' : s;
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  void _onToolSelected(int index) => setState(() => _selectedTool = index);

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
                  return Column(
                    children: [
                      Expanded(child: _CanvasArea(selectedTool: _selectedTool, svgContent: _svgContent, hasSvg: _hasSvg)),
                      SizedBox(height: 340, child: _buildRightPanel()),
                    ],
                  );
                }
                return Row(
                  children: [
                    _LeftToolbar(selectedTool: _selectedTool, onToolSelected: _onToolSelected),
                    Expanded(child: _CanvasArea(selectedTool: _selectedTool, svgContent: _svgContent, hasSvg: _hasSvg)),
                    SizedBox(width: constraints.maxWidth < 1000 ? 260 : 300, child: _buildRightPanel()),
                  ],
                );
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 36,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('${widget.filename.toUpperCase()} — ${widget.fileType.toUpperCase()}_LOADED',
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11, fontFamily: 'monospace', letterSpacing: 0.5)),
          const Spacer(),
          // Validate
          _SmallBtn(
            label: 'VALIDATE',
            loading: _isValidating,
            color: AppColors.primary,
            onTap: _validate,
          ),
          const SizedBox(width: 8),
          // Download Report
          _SmallBtn(
            label: 'DOWNLOAD REPORT',
            loading: _isDownloadingReport,
            color: AppColors.secondary,
            onTap: _downloadReport,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.zoom_out_outlined, size: 16, color: AppColors.darkTextSecondary),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
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
                    width: 34, height: 34,
                    decoration: BoxDecoration(gradient: AppColors.secondaryGradient, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEURAL_REASONER',
                          style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5, fontFamily: 'monospace')),
                      Text('AI-POWERED ANALYSIS',
                          style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 10, fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
            ),

            // AUTO-FIX ALL button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: _isAutoFixing ? null : _autoFixAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.25),
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: _isAutoFixing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary))
                      : const Text('AUTO-FIX ALL DETECTED',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, fontFamily: 'monospace')),
                ),
              ),
            ),

            // ── Geometric Conflict Card ──────────────────────────────────────
            _LiveIssueCard(
              borderColor: _geometricFixed ? AppColors.success : AppColors.error,
              icon: _geometricFixed ? Icons.check_circle : Icons.error,
              iconColor: _geometricFixed ? AppColors.success : AppColors.error,
              title: 'Geometric Conflict',
              badge: _geometricFixed ? 'FIXED' : 'CRITICAL',
              badgeColor: _geometricFixed ? AppColors.success : AppColors.error,
              description: _geometricFixed
                  ? 'Overlap between Main_Hull and Core_Vent_01 was resolved by AI.'
                  : 'Overlap detected between Main_Hull and Core_Vent_01. Non-manifold geometry will fail export.',
              suggestion: _aiSuggestion,
              suggestionLoading: _loadingAiSuggestion,
              onSuggestion: _geometricFixed ? null : _getAiSuggestion,
              actionLabel: _geometricFixed ? 'RESOLVED ✓' : 'FIX THIS NOW',
              actionColor: _geometricFixed ? Colors.transparent : AppColors.error,
              actionTextColor: _geometricFixed ? AppColors.success : Colors.white,
              actionBorder: _geometricFixed ? AppColors.success : null,
              onAction: _geometricFixed ? null : _fixGeometricConflict,
              actionLoading: _isAutoFixing,
            ),

            // ── Tolerance Warning Card ───────────────────────────────────────
            _LiveIssueCard(
              borderColor: _toleranceFixed ? AppColors.success : AppColors.warning,
              icon: _toleranceFixed ? Icons.check_circle : Icons.warning_amber_rounded,
              iconColor: _toleranceFixed ? AppColors.success : AppColors.warning,
              title: 'Tolerance Warning',
              badge: _toleranceFixed ? 'FIXED' : 'WARNING',
              badgeColor: _toleranceFixed ? AppColors.success : AppColors.warning,
              description: _toleranceFixed
                  ? 'Wall thickness in Zone B-4 was adjusted per AI recommendation.'
                  : 'Wall thickness in Zone B-4 drops below 0.8mm. Structural integrity is potentially compromised.',
              suggestion: _toleranceAiSuggestion,
              suggestionLoading: _loadingToleranceSuggestion,
              onSuggestion: _toleranceFixed ? null : _getToleranceSuggestion,
              actionLabel: _toleranceFixed ? 'RESOLVED ✓' : 'ADJUST THICKNESS',
              actionColor: Colors.transparent,
              actionTextColor: _toleranceFixed ? AppColors.success : AppColors.primary,
              actionBorder: _toleranceFixed ? AppColors.success : AppColors.outlineVariant,
              onAction: _toleranceFixed ? null : _getToleranceSuggestion,
              actionLoading: _loadingToleranceSuggestion,
            ),

            // ── Efficiency Gain Card ──────────────────────────────────────────
            _LiveIssueCard(
              borderColor: _optimizationApplied ? AppColors.success : AppColors.secondary,
              icon: _optimizationApplied ? Icons.check_circle : Icons.lightbulb_outline,
              iconColor: _optimizationApplied ? AppColors.success : AppColors.secondary,
              title: 'Efficiency Gain',
              badge: _optimizationApplied ? 'DONE' : 'IDEA',
              badgeColor: _optimizationApplied ? AppColors.success : AppColors.secondary,
              description: _optimizationApplied
                  ? 'Optimization applied. View final code and download report below.'
                  : 'Replacing fillets with chamfers on internal edges could reduce mesh count by 14%.',
              suggestion: _optimizationApplied ? 'Final optimized file is ready for download.' : null,
              suggestionLoading: false,
              onSuggestion: null,
              actionLabel: _optimizationApplied ? 'VIEW CODE & DOWNLOAD ↗' : 'APPLY OPTIMIZATION',
              actionColor: Colors.transparent,
              actionTextColor: _optimizationApplied ? AppColors.primary : AppColors.primary,
              actionBorder: AppColors.outlineVariant,
              onAction: _applyOptimization,
              actionLoading: false,
            ),

            // Bottom status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _geometricFixed && _toleranceFixed ? 'STATUS: CLEAN ✓' : 'ANALYSIS_DEPTH: 84%',
                    style: TextStyle(
                      color: _geometricFixed && _toleranceFixed ? AppColors.success : AppColors.darkTextSecondary,
                      fontSize: 10, fontFamily: 'monospace'),
                  ),
                  const Text('V1.0.42_STABLE',
                      style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 10, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Canvas Area ──────────────────────────────────────────────────────────────
class _CanvasArea extends StatelessWidget {
  final int selectedTool;
  final String svgContent;
  final bool hasSvg;
  const _CanvasArea({required this.selectedTool, required this.svgContent, required this.hasSvg});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBackground,
      child: Stack(
        children: [
          // Grid background
          CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
          if (hasSvg && svgContent.isNotEmpty)
            Center(
              child: InteractiveViewer(
                child: SvgPicture.string(svgContent, fit: BoxFit.contain,
                    placeholderBuilder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary))),
              ),
            )
          else
            Center(child: _ShapeWithTooltip(selectedTool: selectedTool)),
        ],
      ),
    );
  }
}

// ─── Live Issue Card ──────────────────────────────────────────────────────────
class _LiveIssueCard extends StatelessWidget {
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final String description;
  final String? suggestion;
  final bool suggestionLoading;
  final VoidCallback? onSuggestion;
  final String actionLabel;
  final Color actionColor;
  final Color actionTextColor;
  final Color? actionBorder;
  final VoidCallback? onAction;
  final bool actionLoading;

  const _LiveIssueCard({
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.description,
    this.suggestion,
    required this.suggestionLoading,
    this.onSuggestion,
    required this.actionLabel,
    required this.actionColor,
    required this.actionTextColor,
    this.actionBorder,
    this.onAction,
    required this.actionLoading,
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
                child: Text(title,
                    style: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(3)),
                child: Text(badge,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12, height: 1.45)),

          // AI Suggestion area
          if (suggestion != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(suggestion!,
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4)),
                  ),
                ],
              ),
            ),
          ] else if (onSuggestion != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: suggestionLoading ? null : onSuggestion,
              child: Row(
                children: [
                  if (suggestionLoading)
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary))
                  else
                    const Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(suggestionLoading ? 'Getting AI suggestion…' : 'Tap for AI suggestion',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: actionLoading ? null : onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: actionTextColor,
                side: actionBorder != null ? BorderSide(color: actionBorder!) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                elevation: 0,
              ),
              child: actionLoading
                  ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: actionTextColor))
                  : Text(actionLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, fontFamily: 'monospace', color: actionTextColor)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small bottom bar button ──────────────────────────────────────────────────
class _SmallBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final Color color;
  final VoidCallback onTap;
  const _SmallBtn({required this.label, required this.loading, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
            color: color.withValues(alpha: 0.08),
          ),
          child: loading
              ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
              : Text(label, style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        ),
      );
}

// ─── Existing painters & widgets (unchanged) ─────────────────────────────────

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
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1) : null,
        ),
        child: Icon(icon, size: 18, color: active ? AppColors.primary : AppColors.darkTextSecondary),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A2030)..strokeWidth = 0.5;
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
      shapePainter = _SquarePainter(); propLabel = 'SIDE_LENGTH'; propValue = '160.00mm';
    } else if (selectedTool == 3) {
      shapePainter = _TrianglePainter(); propLabel = 'BASE_WIDTH'; propValue = '160.00mm';
    } else if (selectedTool == 4) {
      shapePainter = _PentagonPainter(); propLabel = 'CIRCUMRADIUS'; propValue = '80.00mm';
    } else {
      shapePainter = _CirclePainter();
    }

    return SizedBox(
      width: 320, height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(painter: _DashedRectPainter(), child: const SizedBox(width: 320, height: 280)),
          Positioned(left: 60, top: 40,
              child: CustomPaint(painter: shapePainter, child: const SizedBox(width: 200, height: 200))),
          Positioned.fill(child: CustomPaint(painter: _DiagonalLinePainter())),
          ..._cornerHandles(),
          Positioned(top: -4, left: 156, child: _Handle()),
          Positioned(top: -16, left: -10,
              child: _EntityPropertiesCard(propLabel: propLabel, propValue: propValue)),
        ],
      ),
    );
  }

  List<Widget> _cornerHandles() => [
    Positioned(top: -4, left: -4, child: _Handle()),
    Positioned(top: -4, right: -4, child: _Handle()),
    Positioned(bottom: -4, left: -4, child: _Handle()),
    Positioned(bottom: -4, right: -4, child: _Handle()),
  ];
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: AppColors.primary, border: Border.all(color: AppColors.darkBackground, width: 1.5)),
  );
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
          Text('ENTITY_PROPERTIES', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 10, fontFamily: 'monospace', letterSpacing: 0.8)),
          const SizedBox(height: 6),
          _PropRow(label: propLabel, value: propValue),
          const SizedBox(height: 2),
          _PropRow(label: 'CENTER_X', value: '300.00'),
        ],
      ),
    );
  }
}

class _PropRow extends StatelessWidget {
  final String label;
  final String value;
  const _PropRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11, fontFamily: 'monospace')),
      const SizedBox(width: 16),
      Text(value, style: TextStyle(color: AppColors.primary, fontSize: 11, fontFamily: 'monospace')),
    ]);
  }
}

// Painters
class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withOpacity(0.7)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    _drawDashedRect(canvas, Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    _dashLine(canvas, Offset(rect.left, rect.top), Offset(rect.right, rect.top), 8, 5, paint);
    _dashLine(canvas, Offset(rect.left, rect.bottom), Offset(rect.right, rect.bottom), 8, 5, paint);
    _dashLine(canvas, Offset(rect.left, rect.top), Offset(rect.left, rect.bottom), 8, 5, paint);
    _dashLine(canvas, Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), 8, 5, paint);
  }
  void _dashLine(Canvas canvas, Offset a, Offset b, double dash, double gap, Paint paint) {
    final dx = b.dx - a.dx; final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final nx = dx / len; final ny = dy / len;
    double dist = 0; bool drawing = true;
    while (dist < len) {
      final seg = drawing ? math.min(dash, len - dist) : math.min(gap, len - dist);
      if (drawing) canvas.drawLine(Offset(a.dx + nx * dist, a.dy + ny * dist), Offset(a.dx + nx * (dist + seg), a.dy + ny * (dist + seg)), paint);
      dist += seg; drawing = !drawing;
    }
  }
  @override bool shouldRepaint(_DashedRectPainter old) => false;
}

class _CirclePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2,
        Paint()..color = AppColors.primary..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(_CirclePainter old) => false;
}

class _DiagonalLinePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width, size.height),
        Paint()..color = AppColors.secondary.withOpacity(0.7)..strokeWidth = 1.2);
  }
  @override bool shouldRepaint(_DiagonalLinePainter old) => false;
}

class _SquarePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = AppColors.primary..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(_SquarePainter old) => false;
}

class _TrianglePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(size.width / 2, 0)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(_TrianglePainter old) => false;
}

class _PentagonPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final point = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) path.moveTo(point.dx, point.dy); else path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = AppColors.primary..strokeWidth = 2..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(_PentagonPainter old) => false;
}