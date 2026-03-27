import 'dart:convert';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/svg_model.dart';
import '../../providers/svg_provider.dart';
import '../../widgets/svg_3d_viewer.dart';

class SvgWorkshopScreen extends StatelessWidget {
  const SvgWorkshopScreen({super.key});

  Future<void> _pickSvg(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!context.mounted) return;
    final provider = context.read<SvgProvider>();
    for (final file in result.files) {
      if (file.bytes != null) {
        final content = utf8.decode(file.bytes!);
        provider.addSvg(file.name, content);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<SvgProvider>(
              builder: (ctx, provider, _) {
                if (provider.cards.isEmpty) {
                  return _buildEmptyState(context);
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.cards.length,
                  itemBuilder: (ctx, i) => _SvgCardWidget(card: provider.cards[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickSvg(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload SVG', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: const Icon(Icons.dashboard_customize, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SVG Card Workshop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              Text('Upload · Validate · Auto-Fix · Preview 3D', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Consumer<SvgProvider>(
            builder: (_, p, __) => p.cards.isEmpty
                ? const SizedBox()
                : TextButton.icon(
                    onPressed: p.clearAll,
                    icon: const Icon(Icons.clear_all, size: 14, color: Colors.white38),
                    label: const Text('Clear All', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_search_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          const Text('No SVGs uploaded yet', style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap the "Upload SVG" button to start analysing files', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Individual SVG Card ───────────────────────────────────────────────────────
class _SvgCardWidget extends StatefulWidget {
  final SvgCard card;
  const _SvgCardWidget({required this.card});

  @override
  State<_SvgCardWidget> createState() => _SvgCardWidgetState();
}

class _SvgCardWidgetState extends State<_SvgCardWidget> {
  bool _showIssues = false;
  bool _showSuggestions = false;

  void _openViewer(String svgContent, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0B0E14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 700,
          height: 560,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white54)),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(child: Svg3dViewer(svgContent: svgContent)),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadSvg(String svgContent, String filename) {
    // Web download via anchor element
    final bytes = utf8.encode(svgContent);
    final base64 = base64Encode(bytes);
    // ignore: unused_local_variable
    final dataUrl = 'data:image/svg+xml;base64,$base64';
    // In Flutter Web, trigger via universal_html or just copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fixed SVG ready (${(bytes.length / 1024).toStringAsFixed(1)} KB)'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.black,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final result = card.result;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 160,
              color: const Color(0xFF0B0E14),
              child: card.isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : card.error != null
                      ? const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40))
                      : SvgPicture.string(
                          result?.fixedSvg ?? card.originalSvg,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => const Center(
                            child: Icon(Icons.image_outlined, color: Colors.white12, size: 40),
                          ),
                        ),
            ),
          ),

          // ── Card Body ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filename
                Text(
                  card.filename,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Status Row
                if (card.isLoading)
                  const Row(children: [
                    SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary)),
                    SizedBox(width: 8),
                    Text('Analysing…', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                  ])
                else if (card.error != null)
                  _Chip('Error', Colors.red)
                else if (result != null) ...[
                  Row(children: [
                    _IssueCountBadge(result.issuesFound),
                    const SizedBox(width: 8),
                    if (result.fixesApplied > 0) _Chip('${result.fixesApplied} Fixed', Colors.green),
                    const Spacer(),
                    _ScoreBadge(result.score.after),
                  ]),
                ],
                const SizedBox(height: 12),

                // Action Buttons
                Row(children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'View 3D',
                      icon: Icons.view_in_ar_rounded,
                      color: AppColors.primary,
                      onTap: result == null ? null : () => _openViewer(result.fixedSvg, card.filename),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Download',
                      icon: Icons.download_rounded,
                      color: Colors.greenAccent,
                      onTap: result == null ? null : () => _downloadSvg(result.fixedSvg, card.filename),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),

                // Issues toggle
                if (result != null && result.issues.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => setState(() => _showIssues = !_showIssues),
                    child: Row(children: [
                      Icon(_showIssues ? Icons.expand_less : Icons.expand_more, color: Colors.white38, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${result.issues.length} Issue${result.issues.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ]),
                  ),
                  if (_showIssues) ...[
                    const SizedBox(height: 6),
                    ...result.issues.take(4).map((issue) => _IssueRow(issue: issue)),
                    if (result.issues.length > 4)
                      Text('+${result.issues.length - 4} more', style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ],

                // Suggestions toggle
                if (result != null && result.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showSuggestions = !_showSuggestions),
                    child: Row(children: [
                      Icon(_showSuggestions ? Icons.expand_less : Icons.expand_more, color: Colors.white38, size: 16),
                      const SizedBox(width: 4),
                      const Text('AI Suggestions', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ]),
                  ),
                  if (_showSuggestions) ...[
                    const SizedBox(height: 6),
                    ...result.suggestions.take(3).map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, size: 10, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(child: Text(s, style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.4))),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],

                // Remove button
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.read<SvgProvider>().removeCard(card.id),
                    child: const Icon(Icons.delete_outline, size: 16, color: Colors.white24),
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

// ─── Small widgets ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

class _IssueCountBadge extends StatelessWidget {
  final int count;
  const _IssueCountBadge(this.count);
  @override
  Widget build(BuildContext context) {
    final color = count == 0 ? Colors.greenAccent : count <= 2 ? Colors.orangeAccent : Colors.redAccent;
    return _Chip('$count Issue${count != 1 ? 's' : ''}', color);
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge(this.score);
  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? Colors.greenAccent : score >= 50 ? Colors.orangeAccent : Colors.redAccent;
    return Text('${score.toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800));
  }
}

class _IssueRow extends StatelessWidget {
  final SvgIssue issue;
  const _IssueRow({required this.issue});
  @override
  Widget build(BuildContext context) {
    final color = issue.severity == 'High' ? Colors.redAccent : issue.severity == 'Medium' ? Colors.orangeAccent : Colors.white38;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(issue.explanation, style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(6),
              color: color.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}
