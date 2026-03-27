import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.outlineVariant.withOpacity(0.2),
    );
  }
}