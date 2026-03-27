import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class ProgressPanel extends StatelessWidget {
  final Animation<double> progressAnim;
  final Animation<double> pulseAnim;

  const ProgressPanel({super.key, required this.progressAnim, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final maxWidth = math.min(MediaQuery.of(context).size.width - 48.0, 440.0);

    return SizedBox(
      width: maxWidth,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF282C36).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Pulsing dot
                      AnimatedBuilder(
                        animation: pulseAnim,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary
                                    .withValues(alpha: pulseAnim.value * 0.4),
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'NEURAL_REASONER',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'V1.0.4-STABLE',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar
              AnimatedBuilder(
                animation: progressAnim,
                builder: (_, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: LayoutBuilder(
                            builder: (ctx, constraints) => Stack(
                              children: [
                                Container(
                                  width: constraints.maxWidth * progressAnim.value,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryDim,
                                        AppColors.primaryContainer,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.55),
                                        blurRadius: 8,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'INITIALIZING SYSTEM...',
                                style: TextStyle(
                                  fontFamily: 'Courier New',
                                  fontSize: 9,
                                  letterSpacing: 1.8,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'OK',
                                style: TextStyle(
                                  fontFamily: 'Courier New',
                                  fontSize: 9,
                                  letterSpacing: 1.8,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progressAnim.value * 100).round()}%',
                            style: const TextStyle(
                              fontFamily: 'Courier New',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}