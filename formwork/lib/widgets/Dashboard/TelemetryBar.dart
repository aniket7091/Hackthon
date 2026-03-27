import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class TelemetryBar extends StatelessWidget {
  final String label;
  final double value;
  final String valueLabel;
  final Color color;

  const TelemetryBar({super.key,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}