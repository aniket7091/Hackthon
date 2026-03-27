import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';

import '../../core/constants/colors.dart';

class IngestCard extends StatelessWidget {
  const IngestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Upload icon circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ingest Source File',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
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
                TextSpan(
                  text: AppString.dragFileText,
                ),
                TextSpan(
                  text: 'browse filesystem',
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Chips
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}