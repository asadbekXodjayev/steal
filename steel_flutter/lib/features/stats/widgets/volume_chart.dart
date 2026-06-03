import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/ops_theme.dart';
import '../stats_aggregations.dart';

/// Weekly volume bar chart (last 8 Sunday-aligned weeks) plus a peak / average /
/// sessions footer. Mirrors the web `EnhancedVolumeChart`.
class VolumeChart extends StatelessWidget {
  const VolumeChart({
    super.key,
    required this.data,
    required this.peakLabel,
    required this.avgLabel,
    required this.sessionsLabel,
    required this.emptyLabel,
  });

  final List<WeeklyVolumePoint> data;
  final String peakLabel;
  final String avgLabel;
  final String sessionsLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _ChartEmpty(label: emptyLabel);
    }

    final maxVol = data.fold<double>(0, (m, d) => d.volume > m ? d.volume : m);
    final avgVol = data.fold<double>(0, (s, d) => s + d.volume) / data.length;
    final totalSessions = data.fold<int>(0, (s, d) => s + d.sessions);
    final maxY = (maxVol <= 0 ? 1.0 : maxVol) * 1.18;

    final dateFmt = DateFormat.MMMd();
    final compact = NumberFormat.compact();
    final grouped = NumberFormat.decimalPattern();

    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => SteelOpsColors.surfaceElevated,
                    tooltipBorder: const BorderSide(
                      color: SteelOpsColors.orange,
                    ),
                    tooltipRoundedRadius: 0,
                    getTooltipItem: (group, _, rod, rodIndex) {
                      final p = data[group.x];
                      return BarTooltipItem(
                        '${grouped.format(p.volume.round())} kg\n',
                        steelMonoStyle(
                          fontSize: 10,
                          color: SteelOpsColors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: '${p.sessions} $sessionsLabel',
                            style: steelMonoStyle(
                              fontSize: 9,
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
                  horizontalInterval: maxY / 3,
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
                      reservedSize: 34,
                      interval: maxY / 3,
                      getTitlesWidget: (value, meta) {
                        if (value <= 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            compact.format(value.round()),
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
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dateFmt.format(data[i].weekStart),
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
                extraLinesData: data.length >= 2
                    ? ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: avgVol,
                            color: SteelOpsColors.orange.withAlpha(140),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                      )
                    : const ExtraLinesData(),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].volume,
                          width: 14,
                          borderRadius: BorderRadius.zero,
                          color: SteelOpsColors.orange,
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
            children: [
              Expanded(
                child: _Stat(
                  label: peakLabel,
                  value: '${grouped.format(maxVol.round())} kg',
                  color: SteelOpsColors.orange,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: avgLabel,
                  value: '${grouped.format(avgVol.round())} kg',
                  color: SteelOpsColors.inkMid,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: sessionsLabel,
                  value: '$totalSessions',
                  color: SteelOpsColors.inkDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: steelMonoStyle(
            fontSize: 8,
            color: SteelOpsColors.inkDim,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: steelMonoStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Text(
          label,
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
}
