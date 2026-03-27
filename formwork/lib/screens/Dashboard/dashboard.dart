import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../widgets/Dashboard/RightPanel.dart';
import '../../widgets/Dashboard/dashboard_left_sidebar.dart';
import '../../widgets/Dashboard/narrow_layout.dart';
import '../../widgets/Dashboard/top_nav_bar.dart';
import '../../widgets/Dashboard/wide_layout.dart';
import '../main_cad_workspace/main_cad_workspace.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2; // Default to 'Library'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;

          return Column(
            children: [
              ///top App bar
              TopNavBar(
                isWide: isWide,
                selectedIndex: _selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),

              /// Dynamic Content Area
              Expanded(
                child: _selectedIndex == 1 
                    ? const MainCardWorkSpaceScreen()
                    : Row(
                        children: [
                          // Left Sidebar
                          LeftSidebar(compact: !isMedium),
                          // Main Content
                          Expanded(
                            child: isWide
                                ? WideLayout()
                                : NarrowLayout(isMedium: isMedium),
                          ),
                          // Right Panel - only show on wide
                          if (isWide) const RightPanel(),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
