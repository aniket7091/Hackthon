import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'footer_lable.dart';

class StatusFooter extends StatelessWidget {
  const StatusFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              FooterLabel('LATENCY: 14MS'),
              SizedBox(height: 3),
              FooterLabel('REGION: NORTH_A_1'),
            ],
          ),
          // Right block
          Row(
            children: [
              // Core temp bar
              Row(
                children: [
                  const FooterLabel('CORE_TEMP'),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              const Text(
                'SECURE_TUNNEL: ACTIVE',
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 8,
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}