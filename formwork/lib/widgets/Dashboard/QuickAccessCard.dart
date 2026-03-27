import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'QuickAccessButton.dart';
import '../../screens/upload_create_design/upload_create_design.dart';

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

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
            'QUICK_ACCESS',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          QuickAccessButton(
            icon: CupertinoIcons.cloud_upload,
            label: 'Upload\nAsset',
            gradient: AppColors.primaryGradient,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadCreateDesignScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          QuickAccessButton(
            icon: Icons.verified_outlined,
            label: 'Bulk\nValidate',
            gradient: AppColors.secondaryGradient,
          ),
          const SizedBox(height: 10),
          QuickAccessButton(
            icon: Icons.history,
            label: 'Session Logs',
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}