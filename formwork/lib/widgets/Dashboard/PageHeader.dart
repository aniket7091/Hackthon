import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYSTEM_OVERVIEW',
          style: GoogleFonts.pochaevsk(
            color: AppColors.darkTextPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Operational Dashboard & Neural Diagnostics',
          style: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}