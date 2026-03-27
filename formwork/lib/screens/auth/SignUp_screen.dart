import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';
import 'package:formwork/screens/auth/login_screen.dart';

import '../../core/constants/colors.dart';

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

// ===== SIGN UP SCREEN =====
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormKey>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _neuralController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _neuralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _neuralController.dispose();
    _fadeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0F1A),
                  Color(0xFF0B0E14),
                  Color(0xFF101420),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main layout
          SafeArea(
            child: isWide
                ? _WideLayout(
                    fadeAnim: _fadeAnim,
                    slideAnim: _slideAnim,
                    neuralController: _neuralController,
                    formContent: _buildFormPanel(context, isWide),
                  )
                : _NarrowLayout(
                    fadeAnim: _fadeAnim,
                    slideAnim: _slideAnim,
                    neuralController: _neuralController,
                    formContent: _buildFormPanel(context, isWide),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context, bool isWide) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'SIGN UP',
              style: TextStyle(
                fontSize: isWide ? 26 : 22,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please Create your workspace.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 28),

            // Google Button
            _GoogleButton(),
            const SizedBox(height: 20),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR SECURE SIGN UP',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkTextSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Full Name Field
            _FieldLabel('FULL NAME'),
            const SizedBox(height: 6),
            _CyberTextField(
              controller: _fullNameController,
              hint: 'John Doe',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email Field
            _FieldLabel('EMAIL ADDRESS'),
            const SizedBox(height: 6),
            _CyberTextField(
              controller: _emailController,
              hint: 'name@company.cad',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel('PASSWORD'),
              ],
            ),
            const SizedBox(height: 6),
            _CyberTextField(
              controller: _passwordController,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.darkTextSecondary,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 28),

            // Initialize Session Button
            _InitializeButton(
              isLoading: _isLoading,
              onTap: () async {
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _isLoading = false);
              },
            ),
            const SizedBox(height: 14),

            // Guest Button
            _GuestButton(),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => LoginScreen(),));
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                    children: [
                      const TextSpan(text: "Already have a workspace? "),
                      TextSpan(
                        text: 'LOGIN',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ===== WIDE LAYOUT (side by side) =====
class _WideLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final AnimationController neuralController;
  final Widget formContent;

  const _WideLayout({
    required this.fadeAnim,
    required this.slideAnim,
    required this.neuralController,
    required this.formContent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              // Neural network background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: neuralController,
                  builder: (_, __) => CustomPaint(
                    painter: NeuralNetworkPainter(
                      animValue: neuralController.value,
                    ),
                  ),
                ),
              ),
              // Dark overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B0E14).withOpacity(0.55),
                      const Color(0xFF0B0E14).withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LogoBadge(),
                    const Spacer(),
                    FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Construct the\n',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'Impossible.',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppString.loginSubTittle,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.darkTextSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _BottomTaglines(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right panel
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.darkSurface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
              child: formContent,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== NARROW LAYOUT (stacked) =====
class _NarrowLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final AnimationController neuralController;
  final Widget formContent;

  const _NarrowLayout({
    required this.fadeAnim,
    required this.slideAnim,
    required this.neuralController,
    required this.formContent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top hero section
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: neuralController,
                    builder: (_, __) => CustomPaint(
                      painter: NeuralNetworkPainter(
                        animValue: neuralController.value,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0B0E14).withOpacity(0.5),
                        const Color(0xFF0B0E14).withOpacity(0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LogoBadge(),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Construct the\n',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Impossible.',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form section
          Container(
            color: AppColors.darkSurface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: formContent,
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.architecture_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'FORMWORK AI',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}


class _MiniAvatar extends StatelessWidget {
  final Color color;
  final double offset;
  const _MiniAvatar({required this.color, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkCard, width: 2),
        ),
        child: Icon(Icons.person, size: 14, color: Colors.white70),
      ),
    );
  }
}

class _BottomTaglines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ['PRECISION.', 'PERFORMANCE.', 'SYNTHETIC.']
          .asMap()
          .entries
          .map(
            (e) => Text(
              e.value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextPrimary.withOpacity(
                  0.12 + e.key * 0.03,
                ),
                letterSpacing: 2,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: AppColors.darkTextSecondary,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CyberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _CyberTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<_CyberTextField> createState() => _CyberTextFieldState();
}

class _CyberTextFieldState extends State<_CyberTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withOpacity(0.7)
              : AppColors.outlineVariant.withOpacity(0.4),
          width: _focused ? 1.5 : 1,
        ),
        color: AppColors.darkCard,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.darkTextSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? AppColors.primary : AppColors.darkTextSecondary,
              size: 18,
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppColors.outlineVariant
                : AppColors.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
          color: _hovered
              ? AppColors.surfaceContainerHighest.withOpacity(0.5)
              : AppColors.darkCard,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
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
        ),
      ),
    );
  }
}

class _InitializeButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _InitializeButton({required this.isLoading, required this.onTap});

  @override
  State<_InitializeButton> createState() => _InitializeButtonState();
}

class _InitializeButtonState extends State<_InitializeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF00F0FF), Color(0xFF00C4CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35 * _pulse.value),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.isLoading ? null : widget.onTap,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestButton extends StatefulWidget {
  @override
  State<_GuestButton> createState() => _GuestButtonState();
}

class _GuestButtonState extends State<_GuestButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppColors.outlineVariant
                : AppColors.outlineVariant.withOpacity(0.35),
          ),
          color: _hovered
              ? AppColors.surfaceContainerHighest.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  color: AppColors.darkTextSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Required for Form key type alias
typedef FormKey = FormState;
