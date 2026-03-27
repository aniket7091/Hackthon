import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'StatCard.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'TOTAL DESIGNS',
                value: '1,284',
                sub: '+12.4% FROM LAST CYCLE',
                subIcon: Icons.trending_up,
                subColor: AppColors.success,
                valueColor: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'ERRORS DETECTED',
                value: '03',
                sub: 'REQUIRES IMMEDIATE REVIEW',
                subIcon: Icons.warning_amber,
                subColor: AppColors.error,
                valueColor: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'AUTO-FIXES APPLIED',
                value: '412',
                sub: 'AI EFFICIENCY OPTIMIZED',
                subIcon: Icons.bolt,
                subColor: AppColors.secondary,
                valueColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'AVG DESIGN SCORE',
                value: '98.2',
                sub: 'GRADE: S-CLASS ELITE',
                subIcon: CupertinoIcons.star_fill,
                subColor: AppColors.primary,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}