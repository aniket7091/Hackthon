import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const SideNavItem(this.icon, this.label, {super.key, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.darkTextSecondary,
            size: 22,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: selected
                    ? AppColors.primary
                    : AppColors.darkTextSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}