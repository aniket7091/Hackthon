import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.darkTextSecondary,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (active) ...[
                const SizedBox(height: 2),
                Container(
                  height: 2,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4), // Placeholder to avoid jumping when active line appears
              ],
            ],
          ),
        ),
      ),
    );
  }
}