import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'ConstructItem.dart';

class RecentConstructsCard extends StatelessWidget {
  const RecentConstructsCard({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT_CONSTRUCTS',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_rounded,
                        color: AppColors.darkTextSecondary, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'FILTER',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstructItem(
            color: AppColors.primary,
            name: 'PROJECT_HYPERION_V4',
            status: 'Last modified 2h ago • Meshing Phase',
            bars: [0.8, 0.6, 0.4],
            barColor: AppColors.primary,
          ),
          const Divider(),
          ConstructItem(
            color: AppColors.secondary,
            name: 'NEURAL_CONDUIT_B',
            status: 'Last modified 5h ago • Completed',
            bars: [1.0, 0.8, 0.6],
            barColor: AppColors.secondary,
          ),
          const Divider(),
          ConstructItem(
            color: AppColors.warning,
            name: 'FLUID_DYNAMICS_01',
            status: 'Last modified 1d ago • Analysis Pending',
            bars: [0.4, 0.3, 0.2],
            barColor: AppColors.warning,
          ),
          const SizedBox(height: 12),
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SYNC_STATUS: OPERATIONAL',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                const Text(
                  'LATENCY: 4MS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}