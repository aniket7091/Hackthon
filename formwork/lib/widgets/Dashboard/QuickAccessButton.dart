import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final bool isOutlined;
  final VoidCallback? onTap;

  const QuickAccessButton({super.key,
    required this.icon,
    required this.label,
    this.gradient,
    this.isOutlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : gradient,
        color: isOutlined ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(8),
        border: isOutlined
            ? Border.all(color: AppColors.outlineVariant.withOpacity(0.4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isOutlined
                      ? AppColors.darkTextSecondary
                      : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isOutlined
                        ? AppColors.darkTextSecondary
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}