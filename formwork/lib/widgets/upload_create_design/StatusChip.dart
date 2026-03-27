import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 11,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      ),
    );
  }
}