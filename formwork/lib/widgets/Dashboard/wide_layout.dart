import 'package:flutter/material.dart';

import 'CoreLoadCard.dart';
import 'PageHeader.dart';
import 'QuickAccessCard.dart';
import 'RecentConstructsCard.dart';
import 'StatsRow.dart';

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(),
          const SizedBox(height: 24),
          const StatsRow(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: RecentConstructsCard(),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    QuickAccessCard(),
                    const SizedBox(height: 20),
                    CoreLoadCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}