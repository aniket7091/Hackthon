import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class ConstructItem extends StatelessWidget {
  final Color color;
  final String name;
  final String status;
  final List<double> bars;
  final Color barColor;

  const ConstructItem({super.key,
    required this.color,
    required this.name,
    required this.status,
    required this.bars,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(Icons.view_in_ar_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'VALIDATION',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: bars
                    .map((w) => Container(
                  width: 24,
                  height: 4,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(w),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward,
              color: AppColors.darkTextSecondary, size: 18),
        ],
      ),
    );
  }
}