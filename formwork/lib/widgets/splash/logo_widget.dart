import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'HudCorner.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Main box
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.architecture,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          // HUD corners
          ..._buildHudCorners(),
        ],
      ),
    );
  }

  List<Widget> _buildHudCorners() {
    return [
      HudCorner(top: 8, left: 8, flipH: false, flipV: false),
      HudCorner(top: 8, right: 8, flipH: true, flipV: false),
      HudCorner(bottom: 8, left: 8, flipH: false, flipV: true),
      HudCorner(bottom: 8, right: 8, flipH: true, flipV: true),
    ];
  }
}