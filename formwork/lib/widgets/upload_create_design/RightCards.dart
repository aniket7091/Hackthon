import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/string.dart';
import '../../screens/main_cad_workspace/main_cad_workspace.dart';

class RightCards extends StatelessWidget {
  const RightCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick Start card
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUICK START',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manual Entry',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppString.quickStartText,
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Create New Design button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainCardWorkSpaceScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'CREATE NEW\nDESIGN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.2,
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Recent Assets card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Recent Assets',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '8 VERSIONS AVAILABLE',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}