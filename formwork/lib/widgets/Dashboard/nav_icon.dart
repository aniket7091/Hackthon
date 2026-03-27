import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const NavIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(icon, color: AppColors.darkTextSecondary, size: 22),
          ),
        ),
      ),
    );
  }
}