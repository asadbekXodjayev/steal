import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';
import '../data/ops_dashboard_sample.dart';

class OpsStatCard extends StatelessWidget {
  const OpsStatCard({super.key, required this.item});

  final OpsStatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 2, color: item.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: steelMonoStyle(fontSize: 10, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item.value,
                          style: steelMonoStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: item.valueColor,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.unit,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: steelMonoStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
