import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool compact;

  const SidebarItem({super.key,
    required this.icon,
    required this.label,
    this.active = false,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12,),
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.darkTextSecondary,
              size: 20,
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.darkTextSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}