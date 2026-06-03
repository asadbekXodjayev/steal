import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';
import '../stats_aggregations.dart';

/// Green-graded intensity ramp: heavy (dark) → endurance (light). Mirrors the
/// `repColors` ramp in the web `RepsDistributionChart`.
const List<Color> _repColors = [
  Color(0xFF166534), // 1-3 very heavy
  Color(0xFF15803D), // 4-5 heavy
  Color(0xFF16A34A), // 6-8 moderate
  Color(0xFF22C55E), // 9-10 light
  Color(0xFF4ADE80), // 11-12 very light
  Color(0xFF86EFAC), // 13+ endurance
];

/// Rep-range distribution bar chart with a colored intensity legend below.
class RepsDistributionChart extends StatelessWidget {
  const RepsDistributionChart({
    super.key,
    required this.data,
    required this.emptyLabel,
  });

  final List<RepRangeBucket> data;
  final String emptyLabel;

  Color _colorFor(String label) {
    final idx = kRepRanges.indexWhere((r) => r.label == label);
    return _repColors[idx < 0 ? 0 : idx % _repColors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: SteelOpsColors.surface,
          border: Border.all(color: SteelOpsColors.border),
        ),
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Center(
          child: Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: steelMonoStyle(
              fontSize: 10,
              color: SteelOpsColors.inkDim,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }

    final maxCount = data.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    final maxY = (maxCount <= 0 ? 1 : maxCount) * 1.18;

    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => SteelOpsColors.surfaceElevated,
                    tooltipBorder:
                        const BorderSide(color: SteelOpsColors.borderStrong),
                    tooltipRoundedRadius: 0,
                    getTooltipItem: (group, _, rod, rodIndex) {
                      final b = data[group.x];
                      return BarTooltipItem(
                        '${b.label}\n',
                        steelMonoStyle(
                          fontSize: 10,
                          color: SteelOpsColors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: '${b.count}',
                            style: steelMonoStyle(
                              fontSize: 10,
                              color: SteelOpsColors.inkMid,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 3).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: SteelOpsColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: (maxY / 3).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        if (value <= 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.round().toString(),
                            style: steelMonoStyle(
                              fontSize: 8,
                              color: SteelOpsColors.inkDim,
                              letterSpacing: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: steelMonoStyle(
                              fontSize: 8,
                              color: SteelOpsColors.inkDim,
                              letterSpacing: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].count.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.zero,
                          color: _colorFor(data[i].label).withAlpha(
                            data[i].count == maxCount ? 255 : 180,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: SteelOpsColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < kRepRanges.length; i++)
                Column(
                  children: [
                    Container(width: 8, height: 8, color: _repColors[i]),
                    const SizedBox(height: 4),
                    Text(
                      kRepRanges[i].label,
                      style: steelMonoStyle(
                        fontSize: 8,
                        color: SteelOpsColors.inkDim,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
