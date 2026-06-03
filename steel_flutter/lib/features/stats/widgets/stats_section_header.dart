import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';

/// Brutal section header: a small mono eyebrow over a condensed title with a
/// trailing hairline rule. Shared by every stats panel.
class StatsSectionHeader extends StatelessWidget {
  const StatsSectionHeader({
    super.key,
    required this.label,
    required this.title,
    this.panelNum,
  });

  final String label;
  final String title;
  final String? panelNum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: steelMonoStyle(
                  fontSize: 10,
                  color: SteelOpsColors.muted,
                  letterSpacing: 2,
                ),
              ),
            ),
            if (panelNum != null)
              Text(
                panelNum!,
                style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.inkDim,
                  letterSpacing: 1.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: steelHeadingStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(height: 1, color: SteelOpsColors.border),
            ),
          ],
        ),
      ],
    );
  }
}

/// Standard squared, elevated container used to frame charts & panels.
class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border.all(color: SteelOpsColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
