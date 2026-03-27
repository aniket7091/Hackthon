import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'SideNavItem.dart';

class SideNav extends StatelessWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // hide on very small screens
    if (width < 500) return const SizedBox.shrink();

    return Container(
      width: 72,
      color: AppColors.darkBackground,
      child: Column(
        children: [
          const SizedBox(height: 24),
          SideNavItem(Icons.architecture_outlined, 'DRAFTING', selected: true),
          SideNavItem(Icons.grid_view_outlined, 'MESHING'),
          SideNavItem(Icons.bar_chart_outlined, 'ANALYSIS'),
          SideNavItem(Icons.auto_awesome_outlined, 'OPTIMIZATION'),
          SideNavItem(Icons.ios_share_outlined, 'EXPORT'),
          const Spacer(),
          SideNavItem(Icons.help_outline, ''),
          SideNavItem(Icons.terminal_outlined, ''),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}