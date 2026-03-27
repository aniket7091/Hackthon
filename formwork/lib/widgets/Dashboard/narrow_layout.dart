import 'package:flutter/material.dart';

import 'CoreLoadCard.dart';
import 'PageHeader.dart';
import 'QuickAccessCard.dart';
import 'RecentConstructsCard.dart';
import 'RightPanel.dart';
import 'StatsGrid.dart';
import 'StatsRow.dart';

class NarrowLayout extends StatelessWidget {
  final bool isMedium;
  const NarrowLayout({super.key, required this.isMedium});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(),
          const SizedBox(height: 16),
          isMedium
              ? const StatsRow()
              : const StatsGrid(),
          const SizedBox(height: 16),
          RecentConstructsCard(),
          const SizedBox(height: 16),
          QuickAccessCard(),
          const SizedBox(height: 16),
          CoreLoadCard(),
          const SizedBox(height: 16),
          const RightPanel(),
        ],
      ),
    );
  }
}