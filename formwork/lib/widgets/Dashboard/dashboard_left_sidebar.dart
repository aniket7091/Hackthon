import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formwork/widgets/Dashboard/sidebar_items.dart';

import '../../core/constants/colors.dart';

class LeftSidebar extends StatelessWidget {
  final bool compact;
  const LeftSidebar({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.architecture, 'label': 'DRAFTING'},
      {'icon': CupertinoIcons.circle_grid_3x3, 'label': 'MESHING'},
      {'icon': Icons.bar_chart, 'label': 'ANALYSIS', 'active': true},
      {'icon': Icons.auto_awesome_outlined, 'label': 'OPTIMIZATION'},
      {'icon': Icons.terminal, 'label': 'LOGS'},
    ];

    return Container(
      width: compact ? 56 : 72,
      color: AppColors.darkSurface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...items.map((item) => SidebarItem(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            active: item['active'] == true,
            compact: compact,
          )),
        ],
      ),
    );
  }
}