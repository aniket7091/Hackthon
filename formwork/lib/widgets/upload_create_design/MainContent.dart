import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/string.dart';
import 'IngestCard.dart';
import 'RightCards.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 900;

    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: isNarrow ? 28 : 40,
                letterSpacing: 2,
              ),
              children: const [
                TextSpan(
                  text: 'INITIALIZE ',
                  style: TextStyle(color: AppColors.darkTextPrimary),
                ),
                TextSpan(
                  text: 'CORE ASSET',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppString.uploadSubText,
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          // Cards row
          Expanded(
            child: isNarrow
                ? Column(
              children: [
                Expanded(child: IngestCard()),
                const SizedBox(height: 16),
                Expanded(child: RightCards()),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: IngestCard()),
                const SizedBox(width: 20),
                Expanded(flex: 4, child: RightCards()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}