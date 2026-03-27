import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/components/custom_snakeBar.dart';
import '../Dashboard/dashboard.dart';
import 'SignUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _neuralController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _neuralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _neuralController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      AppOverlaySnackBar.show(
        context: context,
        message: 'Please enter your email and password.',
        backgroundColor: Colors.orange,
        icon: Icons.warning_outlined,
      );
      return;
    }
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      AppOverlaySnackBar.show(
        context: context,
        message: 'Session Initialized — Welcome back!',
        backgroundColor: Colors.green,
        icon: Icons.verified_outlined,
      );
    } else {
      AppOverlaySnackBar.show(
        context: context,
        message: authProvider.errorMessage ?? 'Login failed.',
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          // Background Gradient Orbs
          _buildBackgroundDecoration(),

          // Main Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1024) {
                  return _buildDesktopLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),

          // Global Overlays (Desktop Only)
          if (MediaQuery.of(context).size.width >= 1024) ...[
            _buildBackgroundBrandingText(),
          ],
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(painter: BackgroundPainter()),
          // Subtle Grainy Texture Overlay
          // Opacity(
          //   opacity: 0.02,
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //         image: NetworkImage(
          //           'https://images.ctfassets.net/hrltx12pl8hq/28ECAQiPJZ78hxatLTa7Ts/2f695d869736ae3b0de3e56ceaca3958/free-nature-images.jpg?fit=fill&w=1200&h=630',
          //         ),
          //         repeat: ImageRepeat.repeat,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              constraints: const BoxConstraints(maxWidth: 1080),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 60,
                    offset: Offset(0, 30),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: _buildBrandingSide()),
                        Expanded(flex: 6, child: _buildLoginFormSide()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1117),
        border: Border(right: BorderSide(color: Colors.white12)),
      ),
      child: Stack(
        children: [
          // Neural Network Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _neuralController,
              builder: (_, __) => CustomPaint(
                painter: NeuralNetworkPainter(
                  animValue: _neuralController.value,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDynamicLogo(),
                const Spacer(),
                Text(
                  'Construct the',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Impossible.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppString.loginSubTittle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFFA1A1AA),
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                Spacer(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormSide() {
    return Container(
      padding: const EdgeInsets.all(56),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22), // Matching the Design
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please identify yourself to initialize workspace.',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
          ),
          const SizedBox(height: 40),

          // Google Button
          _buildSocialButton(),

          const SizedBox(height: 32),

          _buildFormDivider(),

          const SizedBox(height: 32),

          // Email Field
          _buildInputLabel('EMAIL ADDRESS'),
          const SizedBox(height: 10),
          _buildCustomInputField(
            controller: _emailController,
            hint: 'name@company.com',
            icon: Icons.alternate_email_rounded,
          ),

          const SizedBox(height: 24),

          // Password Field
          _buildInputLabel('ACCESS KEY', trailing: 'FORGOT?'),
          const SizedBox(height: 10),
          _buildCustomInputField(
            controller: _passwordController,
            hint: '••••••••',
            icon: CupertinoIcons.lock,
            isPassword: true,
          ),

          const SizedBox(height: 40),

          // Actions
          _buildMainActionButton(),

          const SizedBox(height: 16),

          _buildGuestActionButton(),

          const SizedBox(height: 32),

          Center(
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(),));
              },
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Color(0xFF484F58)),
                  children: [
                     TextSpan(text: "Don't have a workspace? "),
                    TextSpan(
                      text: 'SignUp',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.architecture_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'FROMWORK AI',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage("assets/images/google.png"),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'OR SECURE LOGIN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Color(0xFF484F58),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF8B949E),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildCustomInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF484F58)),
        prefixIcon: Icon(icon, color: const Color(0xFF6E7681), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFF6E7681),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0D1117),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildMainActionButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'LOGIN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.8,
                ),
              ),
      ),
    );
  }

  Widget _buildGuestActionButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_pin_rounded, size: 20, color: Color(0xFFF0F6FC)),
            SizedBox(width: 12),
            Text(
              'Continue as Guest',
              style: TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundBrandingText() {
    return Positioned(
      bottom: 40,
      left: 40,
      child: Opacity(
        opacity: 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRECISION.',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Text(
              'PERFORMANCE.',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              'SYNTHETIC.',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Layout Implementation
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section for mobile
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _neuralController,
                    builder: (_, __) => CustomPaint(
                      painter: NeuralNetworkPainter(
                        animValue: _neuralController.value,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0B0E14).withOpacity(0.5),
                        const Color(0xFF0B0E14).withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildDynamicLogo(),
                      const SizedBox(height: 24),
                      Text(
                        'Construct the',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Impossible.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            color: const Color(0xFF161B22),
            child: _buildLoginFormSide(),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orb1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1E3A8A).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      size.width * 0.6,
      orb1,
    );

    final orb2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0F766E).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.9),
      size.width * 0.5,
      orb2,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
