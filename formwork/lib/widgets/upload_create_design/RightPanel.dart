import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'AlertCard.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 1100) return const SizedBox.shrink();

    return Container(
      width: 280,
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Neural Reasoner status
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'NEURAL_REASONER',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'PROCESSING...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Schema Mismatch alert
          AlertCard(
            color: AppColors.error,
            title: 'SCHEMA_MISMATCH',
            body:
            'System detected a non-compliant SVG header in previous attempt. Ensure coordinate system is set to Absolute.',
          ),
          const SizedBox(height: 12),
          // Asset Indexing info
          AlertCard(
            color: AppColors.primary,
            title: 'ASSET_INDEXING',
            body:
            'Neural weights optimized for JSON geometry arrays. Ready for architectural parsing.',
          ),
        ],
      ),
    );
  }
}