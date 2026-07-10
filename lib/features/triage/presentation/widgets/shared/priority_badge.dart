import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';

class PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.label,
    this.color = AppColors.error,
    this.textColor = AppColors.onError,
    this.showIcon = true,
  });

  factory PriorityBadge.p1() => const PriorityBadge(
        label: 'P1 - CRITICAL',
        color: AppColors.error,
        textColor: AppColors.onError,
      );

  factory PriorityBadge.p2() => const PriorityBadge(
        label: 'PRIORITY P2',
        color: Color(0xFFFF8C00),
        textColor: AppColors.onError,
      );

  factory PriorityBadge.p3() => const PriorityBadge(
        label: 'PRIORITY P3',
        color: Color(0xFF54A0FE),
        textColor: AppColors.onSecondaryContainer,
      );

  factory PriorityBadge.p4() => const PriorityBadge(
        label: 'Expectant',
        color: AppColors.inverseSurface,
        textColor: AppColors.inverseOnSurface,
      );

  factory PriorityBadge.queue(String level, Color color) =>
      PriorityBadge(label: 'PRIORITY $level', color: color, showIcon: false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[const SizedBox(width: 0)],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}