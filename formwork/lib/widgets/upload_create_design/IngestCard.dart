import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';

import '../../core/constants/colors.dart';

class IngestCard extends StatefulWidget {
  /// Called when a valid SVG or JSON file has been selected.
  /// [filename] is the file name, [content] is the raw text content.
  final void Function(String filename, String content, String type)? onFilePicked;

  const IngestCard({super.key, this.onFilePicked});

  @override
  State<IngestCard> createState() => _IngestCardState();
}

class _IngestCardState extends State<IngestCard> {
  String? _selectedFile;
  bool _loading = false;

  Future<void> _pick() async {
    setState(() => _loading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg', 'json'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final content = utf8.decode(file.bytes!);
        final ext = file.extension?.toLowerCase() ?? 'json';
        setState(() => _selectedFile = file.name);
        widget.onFilePicked?.call(file.name, content, ext);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFile != null ? _selectedFile! : 'Ingest Source File',
              style: TextStyle(
                color: _selectedFile != null ? AppColors.primary : AppColors.darkTextPrimary,
                fontSize: _selectedFile != null ? 14 : 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                children: [
                  TextSpan(text: _selectedFile != null ? 'File loaded. Tap to change. ' : AppString.dragFileText),
                  TextSpan(
                    text: 'browse filesystem',
                    style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(Icons.code, 'SVG_PATH'),
                const SizedBox(width: 12),
                _Chip(Icons.storage_rounded, 'JSON_DATA'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}