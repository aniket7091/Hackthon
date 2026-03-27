import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';

import '../../core/constants/colors.dart';
import 'ArcGaugePainter.dart';

class CoreLoadCard extends StatelessWidget {
  const CoreLoadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CORE LOAD',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: ArcGaugePainter(value: 0.7),
                child: const Center(
                  child: Text(
                    '70%',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
           Center(
            child: Text(
              AppString.coreLoadText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}