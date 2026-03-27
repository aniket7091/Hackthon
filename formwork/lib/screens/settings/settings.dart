import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/Dashboard/dashboard_left_sidebar.dart';
import '../validation_report/validation_report.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool realTimeValidation = true;
  bool autoFixGeometry = false;
  bool cloudSync = true;
  double neuralSensitivity = 0.75;
  String selectedUnit = 'MM';

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.architecture, label: 'DRAFTING'),
    _NavItem(icon: Icons.grid_view, label: 'MESHING'),
    _NavItem(icon: Icons.bar_chart, label: 'ANALYSIS'),
    _NavItem(icon: Icons.auto_fix_high, label: 'OPTIMIZATION'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      endDrawer: _buildEndDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;

          return Row(
            children: [
              // Left Nav Rail
              LeftSidebar(compact: !isMedium),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, constraints.maxWidth),
                    Expanded(
                      child: isWide
                          ? _buildWideLayout()
                          : _buildNarrowLayout(isMedium),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  Widget _buildTopBar(BuildContext context, double screenWidth) {
    final isNarrow = screenWidth < 900;
    return Container(
      height: 52,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'SYNTHETIC_ARCHITECT',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: isNarrow ? 11 : 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 24),
          if (!isNarrow) ...[
            _topBarLink('Projects', false),
            const SizedBox(width: 16),
            _topBarLink('Simulations', false),
            const SizedBox(width: 16),
            _topBarLink('Library', false),
          ],
          const Spacer(),
          if (isNarrow)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.darkTextPrimary),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            )
          else ...[
            Icon(Icons.save_outlined, color: AppColors.darkTextSecondary, size: 18),
            const SizedBox(width: 16),
            Icon(Icons.settings_outlined, color: AppColors.darkTextSecondary, size: 18),
            const SizedBox(width: 16),
            Icon(Icons.notifications_none, color: AppColors.darkTextSecondary, size: 18),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => ValidationAnalysisScreen.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Validate',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkSurface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        children: [
          const Text(
            'MENU',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _drawerItem(Icons.folder_outlined, 'Projects'),
          _drawerItem(Icons.science_outlined, 'Simulations'),
          _drawerItem(Icons.library_books_outlined, 'Library'),
          const Divider(color: AppColors.outlineVariant, height: 32),
          _drawerItem(Icons.save_outlined, 'Save'),
          _drawerItem(Icons.settings_outlined, 'Settings', active: true),
          _drawerItem(Icons.notifications_none, 'Notifications'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close drawer
              ValidationAnalysisScreen.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Validate', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, {bool active = false}) {
    return ListTile(
      leading: Icon(icon, color: active ? AppColors.primary : AppColors.darkTextSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primary : AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {},
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _topBarLink(String label, bool active) {
    return Text(
      label,
      style: TextStyle(
        color: active ? AppColors.primary : AppColors.darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildMainContent(),
        ),
        Container(
          width: 1,
          color: AppColors.outlineVariant.withOpacity(0.3),
        ),
        SizedBox(
          width: 280,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isMedium) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainContent(),
          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.3),
          ),
          _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'SYSTEM_CONFIG',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adjust neural parameters and architectural constraints for CAD_ENGINE_V1.',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Row 1: Real-time Validation + Measurement Units
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRealTimeValidationCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMeasurementUnitsCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildRealTimeValidationCard(),
                  const SizedBox(height: 16),
                  _buildMeasurementUnitsCard(),
                ],
              );
            }
          }),

          const SizedBox(height: 16),

          // Neural Sensitivity
          _buildNeuralSensitivityCard(),

          const SizedBox(height: 16),

          // Row 3: Auto-Fix + Cloud Sync
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _buildAutoFixCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCloudSyncCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildAutoFixCard(),
                  const SizedBox(height: 16),
                  _buildCloudSyncCard(),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRealTimeValidationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Real-time Validation',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: realTimeValidation,
                onChanged: (v) => setState(() => realTimeValidation = v),
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primaryContainer,
                inactiveThumbColor: AppColors.darkTextSecondary,
                inactiveTrackColor: AppColors.outlineVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Continuous mesh integrity checks during the drafting phase. High CPU overhead, recommended for complex geometries.',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'OPERATIONAL: 4.2MS LATENCY',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementUnitsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              const Text(
                'Measurement Units',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _unitButton('MM', 'METRIC')),
              const SizedBox(width: 12),
              Expanded(child: _unitButton('IN', 'IMPERIAL')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _unitButton(String unit, String label) {
    final selected = selectedUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => selectedUnit = unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.darkBackground
              : AppColors.darkBackground.withOpacity(0.4),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              unit,
              style: TextStyle(
                color: selected
                    ? AppColors.darkTextPrimary
                    : AppColors.darkTextSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.darkTextSecondary
                    : AppColors.darkTextSecondary.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuralSensitivityCard() {
    final biasPercent = (neuralSensitivity * 100).round();
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_outlined,
                        color: AppColors.secondary, size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      'Neural Sensitivity',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Adjust the threshold for AI-driven suggestions. Higher values increase predictive accuracy but may reduce creative variance in the optimizer.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.outlineVariant,
                    thumbColor: AppColors.primary,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayColor: AppColors.primary.withOpacity(0.15),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: neuralSensitivity,
                    min: 0,
                    max: 1,
                    onChanged: (v) => setState(() => neuralSensitivity = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('PRECISION',
                        style: TextStyle(
                            color: AppColors.darkTextSecondary, fontSize: 10)),
                    Text('HEURISTIC',
                        style: TextStyle(
                            color: AppColors.darkTextSecondary, fontSize: 10)),
                    Text('GENERATIVE',
                        style: TextStyle(
                            color: AppColors.darkTextSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Bias Box
          Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.outlineVariant.withOpacity(0.5), width: 1),
            ),
            child: Column(
              children: [
                const Text(
                  'CURRENT BIAS',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$biasPercent',
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const TextSpan(
                        text: '%',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getBiasLabel(),
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBiasLabel() {
    if (neuralSensitivity < 0.33) return 'Optimal for Precision';
    if (neuralSensitivity < 0.66) return 'Optimal for Heuristic';
    return 'Optimal for Meshing';
  }

  Widget _buildAutoFixCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_fix_high,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Auto-Fix Geometry',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Automatically resolve non-manifold edges.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: autoFixGeometry,
            onChanged: (v) => setState(() => autoFixGeometry = v),
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
            inactiveThumbColor: AppColors.darkTextSecondary,
            inactiveTrackColor: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_sync, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cloud Sync',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Synchronize workspace across nodes.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: cloudSync,
            onChanged: (v) => setState(() => cloudSync = v),
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
            inactiveThumbColor: AppColors.darkTextSecondary,
            inactiveTrackColor: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Neural Reasoner Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.darkSurface,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.psychology,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'NEURAL_REASONER',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'PROCESSING...',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: AppColors.darkSurface,
            child: Row(
              children: [
                _panelTab('AI Insights', true, Icons.lightbulb_outline),
                _panelTab('Warnings', false, Icons.warning_amber_outlined,
                    badge: '12'),
                _panelTab('Errors', false, Icons.error_outline,
                    badge: '1', badgeColor: AppColors.error),
              ],
            ),
          ),

          // Panel content
          Container(
            color: AppColors.darkBackground,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topology Health
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'TOPOLOGY HEALTH',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '98.4%',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.984,
                    backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Advice Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 12,
                          height: 1.5),
                      children: [
                        TextSpan(
                          text: 'ADVICE: ',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                          'Current "Neural Sensitivity" at 75% may flag intentional architectural voids as structural errors. Consider threshold reduction for organic forms.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Active Threads
                const Text(
                  'ACTIVE THREADS',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _threadRow('GRID_COMPUTE_01', 'IDLE', AppColors.darkTextSecondary),
                const SizedBox(height: 8),
                _threadRow('MESH_RENDER_04', 'ACTIVE', AppColors.success),

                const SizedBox(height: 24),

                // Export Logs Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.outlineVariant, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Export Logs',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelTab(String label, bool active, IconData icon,
      {String? badge, Color? badgeColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            left: active
                ? const BorderSide(color: AppColors.secondary, width: 2)
                : BorderSide.none,
            bottom: active
                ? BorderSide.none
                : const BorderSide(
                color: Color(0xFF1E2330), width: 1),
          ),
          color: active ? AppColors.secondary.withOpacity(0.08) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                active ? AppColors.darkTextPrimary : AppColors.darkTextSecondary,
                size: 14),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppColors.darkTextPrimary
                      : AppColors.darkTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _threadRow(String name, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.3), width: 1),
      ),
      child: child,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}