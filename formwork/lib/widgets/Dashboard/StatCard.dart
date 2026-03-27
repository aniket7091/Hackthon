import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData subIcon;
  final Color subColor;
  final Color valueColor;

  const StatCard({super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.subIcon,
    required this.subColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(subIcon, color: subColor, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  sub,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}