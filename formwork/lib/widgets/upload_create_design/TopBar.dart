import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../screens/validation_report/validation_report.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.darkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'FORMWORK',
                  style: TextStyle(color: AppColors.primary),
                ),
                TextSpan(
                  text: '  AI',
                  style: TextStyle(color: AppColors.darkTextPrimary),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Upload button
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.outlineVariant),
              foregroundColor: AppColors.darkTextPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'UPLOAD',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Validate button
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ValidationAnalysisScreen(),));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'VALIDATE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
