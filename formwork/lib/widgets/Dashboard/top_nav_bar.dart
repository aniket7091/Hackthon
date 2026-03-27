import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'nav_icon.dart';
import 'nav_items.dart';
import '../../screens/settings/settings.dart';
import '../../screens/validation_report/validation_report.dart';

class TopNavBar extends StatelessWidget {
  final bool isWide;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const TopNavBar({
    super.key,
    required this.isWide,
    this.selectedIndex = 2,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'FROMWORK AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 16 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 32),
          if (isWide) ...[
            NavItem(
              label: 'Projects',
              active: selectedIndex == 0,
              onTap: onTabSelected != null ? () => onTabSelected!(0) : null,
            ),
            NavItem(
              label: 'Simulations',
              active: selectedIndex == 1,
              onTap: onTabSelected != null ? () => onTabSelected!(1) : null,
            ),
            NavItem(
              label: 'Library',
              active: selectedIndex == 2,
              onTap: onTabSelected != null ? () => onTabSelected!(2) : null,
            ),
            NavItem(
              label: 'SVG Workshop',
              active: selectedIndex == 3,
              onTap: onTabSelected != null ? () => onTabSelected!(3) : null,
            ),
          ],
          const Spacer(),
          // Validate Button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextButton(
              onPressed: () => ValidationAnalysisScreen.show(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Validate',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          NavIcon(icon: CupertinoIcons.doc_fill),
          const SizedBox(width: 12),
          NavIcon(
            icon: CupertinoIcons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 12),
          NavIcon(icon: CupertinoIcons.bell_solid),
          const SizedBox(width: 12),
          NavIcon(icon: CupertinoIcons.person_alt_circle),
        ],
      ),
    );
  }
}