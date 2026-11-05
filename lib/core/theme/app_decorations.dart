import 'package:flutter/material.dart';

import 'app_radius.dart';

/// Shared surface treatments so every screen's cards, bars and sheets use
/// the same soft elevation instead of each screen hand-rolling its own
/// mix of hard 1px borders and ad hoc shadows.
class AppDecorations {
  AppDecorations._();

  /// Standard elevated card: a soft shadow plus a faint hairline so the
  /// edge still reads in dark mode, where shadows barely show.
  static BoxDecoration card(
    BuildContext context, {
    Color? color,
    double radius = AppRadius.lg,
    Color? borderColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? scheme.outlineVariant.withValues(alpha: 0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Flatter card for dense list rows where a full shadow would be noisy.
  static BoxDecoration flatCard(
    BuildContext context, {
    Color? color,
    double radius = AppRadius.lg,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: color ?? scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  /// Subtle separator used by app bars / bottom bars instead of a hard
  /// drop-shadow line.
  static List<BoxShadow> barShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
