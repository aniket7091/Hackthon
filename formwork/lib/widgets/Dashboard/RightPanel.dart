import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'TelemetryBar.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.darkSurface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Neural Reasoner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology,
                        color: AppColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEURAL_REASONER',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'PROCESSING...',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Insight
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: AppColors.secondary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI INSIGHT #402',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Structural integrity at Node-7 exceeds safety margins by 14.2%. Optimization recommended.',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'WARNING',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thermal dissipation bottleneck detected in primary conduit mesh.',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-time Telemetry
            const Text(
              'REAL-TIME TELEMETRY',
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            TelemetryBar(
              label: 'Compute Load',
              value: 0.76,
              valueLabel: '76%',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            TelemetryBar(
              label: 'Sync Latency',
              value: 0.12,
              valueLabel: '12ms',
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}