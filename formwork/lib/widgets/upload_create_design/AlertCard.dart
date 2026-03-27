import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class AlertCard extends StatelessWidget {
  final Color color;
  final String title;
  final String body;
  const AlertCard({super.key,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                color == AppColors.error
                    ? Icons.error_outline
                    : Icons.info_outline,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}