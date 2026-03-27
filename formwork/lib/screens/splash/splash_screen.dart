import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/splash/background_mesh.dart';
import '../../widgets/splash/booting_hint.dart';
import '../../widgets/splash/dot_grid_overlay.dart';
import '../../widgets/splash/logo_widget.dart';
import '../../widgets/splash/progress_panel.dart';
import '../../widgets/splash/status_footer.dart';
import '../../widgets/splash/titleSection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _masterCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _gridCtrl;
  late final AnimationController _neuralCtrl;

  // Animations
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _panelFade;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _progressAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _neuralCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );


    // Staggered fade/slide animations
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0, 0.3)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
    ));
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.2, 0.55, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
    ));
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );
    _panelFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _masterCtrl,
          curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
    ));
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _progressCtrl, curve: const Interval(0, 1, curve: Curves.easeInOutCubic)),
    );
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseCtrl);
    _bounceAnim = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // Defer all animation starts to after the first frame to avoid
    // "EngineFlutterView disposed" assertion on hot restart (web).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pulseCtrl.repeat(reverse: true);
      _bounceCtrl.repeat(reverse: true);
      _gridCtrl.repeat();
      _neuralCtrl.repeat();
      _masterCtrl.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _progressCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _bounceCtrl.dispose();
    _gridCtrl.dispose();
    _neuralCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // ── Neural Network Background (Full Screen) ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _neuralCtrl,
              builder: (_, __) => CustomPaint(
                painter: NeuralNetworkPainter(
                  animValue: _neuralCtrl.value,
                ),
              ),
            ),
          ),

          // ── Background layers ──
          const MeshBackground(),
          GridOverlay(controller: _gridCtrl),

          // ── Main content ──
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: const LogoWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    // Title
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const TitleSection(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: const SubtitleText(),
                    ),

                    const SizedBox(height: 56),

                    // Progress panel
                    FadeTransition(
                      opacity: _panelFade,
                      child: SlideTransition(
                        position: _panelSlide,
                        child: ProgressPanel(
                          progressAnim: _progressAnim,
                          pulseAnim: _pulseAnim,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Bounce hint
                    FadeTransition(
                      opacity: _panelFade,
                      child: BootingHint(bounceAnim: _bounceAnim),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── System status footer ──
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _panelFade,
              child: const StatusFooter(),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== NEURAL NETWORK PAINTER =====
class NeuralNetworkPainter extends CustomPainter {
  final double animValue;
  final List<Offset> _nodes = [];
  final List<List<int>> _connections = [];
  bool _initialized = false;

  NeuralNetworkPainter({required this.animValue});

  void _init(Size size) {
    if (_initialized) return;
    _initialized = true;
    final rng = math.Random(42);
    for (int i = 0; i < 28; i++) {
      _nodes.add(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
      );
    }
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final dist = (_nodes[i] - _nodes[j]).distance;
        if (dist < size.width * 0.28) {
          _connections.add([i, j]);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _init(size);

    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.07)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final pulsePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.22)
      ..style = PaintingStyle.fill;

    for (int idx = 0; idx < _connections.length; idx++) {
      final c = _connections[idx];
      final pulse = (math.sin(animValue * math.pi * 2 + idx * 0.4) + 1) / 2;
      final paint = pulse > 0.7 ? pulsePaint : linePaint;
      canvas.drawLine(_nodes[c[0]], _nodes[c[1]], paint);
    }

    for (int i = 0; i < _nodes.length; i++) {
      final pulse = (math.sin(animValue * math.pi * 2 + i * 0.7) + 1) / 2;
      canvas.drawCircle(_nodes[i], 2.0 + pulse * 1.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(NeuralNetworkPainter old) => old.animValue != animValue;
}




