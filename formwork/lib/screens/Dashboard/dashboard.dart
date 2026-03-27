import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/Dashboard/RightPanel.dart';
import '../../widgets/Dashboard/dashboard_left_sidebar.dart';
import '../../widgets/Dashboard/narrow_layout.dart';
import '../../widgets/Dashboard/top_nav_bar.dart';
import '../../widgets/Dashboard/wide_layout.dart';
import '../workspace/cad_workspace_screen.dart';
import '../auth/login_screen.dart';
import '../svg_workshop/svg_workshop_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2;

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

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
              /// Top App Bar
              TopNavBar(
                isWide: isWide,
                selectedIndex: _selectedIndex,
                onTabSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),

              /// Dynamic Content Area
              Expanded(
                child: _selectedIndex == 1
                    ? const CadWorkspaceScreen()
                    : _selectedIndex == 3
                        ? const SvgWorkshopScreen()
                        : Row(
                        children: [
                          LeftSidebar(compact: !isMedium),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: isWide
                                      ? WideLayout()
                                      : NarrowLayout(isMedium: isMedium),
                                ),
                                // Logout bar at bottom
                                Container(
                                  color: AppColors.darkSurface,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer<AuthProvider>(
                                        builder: (_, auth, __) => Text(
                                          auth.user?.name ?? '',
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: _logout,
                                        icon: const Icon(Icons.logout, size: 14, color: Colors.white54),
                                        label: const Text('Logout', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
