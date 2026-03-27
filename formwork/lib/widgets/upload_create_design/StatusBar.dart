import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'StatusChip.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;
    return Container(
      height: 36,
      color: AppColors.darkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          StatusChip('ENGINE_STATUS: NOMINAL'),
          if (!isNarrow) ...[
            const SizedBox(width: 24),
            StatusChip('LATENCY: 12ms'),
            const SizedBox(width: 24),
            StatusChip('ENCRYPTION: AES-256'),
          ],
          const Spacer(),
          const Icon(
            Icons.memory_outlined,
            size: 13,
            color: AppColors.darkTextSecondary,
          ),
          const SizedBox(width: 6),
          StatusChip('SESSION_ID: 0x8F92A1'),
        ],
      ),
    );
  }
}