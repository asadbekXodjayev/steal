import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';

/// A single KPI tile: a big condensed value over a mono label, with a colored
/// left rail and optional sub-line. Mirrors the web `KPIPanel`.
class KpiPanel extends StatelessWidget {
  const KpiPanel({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.subValue,
    this.panelNum,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color accent;
  final String? panelNum;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border(
          top: BorderSide(color: SteelOpsColors.border),
          right: BorderSide(color: SteelOpsColors.border),
          bottom: BorderSide(color: SteelOpsColors.border),
          left: BorderSide(color: accent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: steelMonoStyle(
                    fontSize: 9,
                    color: SteelOpsColors.inkDim,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (panelNum != null)
                Text(
                  panelNum!,
                  style: steelMonoStyle(
                    fontSize: 8,
                    color: SteelOpsColors.inkDim,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: steelHeadingStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: accent,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null) ...[
            const SizedBox(height: 4),
            Text(
              subValue!,
              style: steelMonoStyle(
                fontSize: 8,
                color: SteelOpsColors.inkDim,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// 2-column responsive grid of KPI tiles.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.tiles});
  final List<KpiPanel> tiles;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 520 ? 4 : 2;
        final tileWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles)
              SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}
