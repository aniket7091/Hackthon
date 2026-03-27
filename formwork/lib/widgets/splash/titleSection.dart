import 'package:flutter/material.dart';
import 'package:formwork/core/constants/string.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = _responsiveTitleSize(context);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Helvetica Neue',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
          height: 1,
          color: AppColors.onSurface,
          shadows: [
            Shadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
            ),
          ],
        ),
        children:  [
          TextSpan(text: AppString.appTittle),
          TextSpan(
            text: '  AI',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  double _responsiveTitleSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return 72;
    if (w > 600) return 54;
    return 36;
  }
}



// for subTittle
class SubtitleText extends StatelessWidget {
  const SubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppString.appSubTittle,
      textAlign: TextAlign.center,
      style: GoogleFonts.courierPrime(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 4.5,
        color: AppColors.onSurfaceVariant,
        height: 1.6,
      ),
    );
  }
}