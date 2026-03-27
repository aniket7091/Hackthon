import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../screens/auth/login_screen.dart';

class BootingHint extends StatelessWidget {
  final Animation<double> bounceAnim;
  const BootingHint({super.key, required this.bounceAnim});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Opacity(
        opacity: 0.45,
        child: Column(
          children: [
            const Text(
              'START WORKSPACE',
              style: TextStyle(
                fontFamily: 'Courier New',
                fontSize: 9,
                letterSpacing: 3.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: bounceAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, bounceAnim.value),
                child: const Icon(
                  Icons.keyboard_double_arrow_down,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}