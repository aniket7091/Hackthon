import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class FooterLabel extends StatelessWidget {
  final String text;
  const FooterLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Courier New',
        fontSize: 8,
        letterSpacing: 2,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}