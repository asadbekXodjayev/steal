import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models.dart';
import '../../../shared/ops_theme.dart';

/// Forge-toned palette for muscle slices (orange/rust family with steel greys).
const List<Color> _sliceColors = [
  Color(0xFFC2410C), // forge orange
  Color(0xFFEA580C),
  Color(0xFFB91C1C), // rust
  Color(0xFF8B0000), // blood
  Color(0xFFF59E0B),
  Color(0xFF737373),
  Color(0xFFA1A1AA),
  Color(0xFFC9C9C9),
  Color(0xFF166534),
  Color(0xFF3B82F6),
  Color(0xFF52525B),
];

/// Muscle distribution donut + legend. Mirrors the web `MusclePieChart` /
/// `MuscleDistribution`. [labelFor] localizes the group key.
class MusclePieChart extends StatefulWidget {
  const MusclePieChart({
    super.key,
    required this.slices,
    required this.labelFor,
    required this.setsLabel,
  });

  final List<MuscleSlice> slices;
  final String Function(String groupKey) labelFor;
  final String setsLabel;

  @override
  State<MusclePieChart> createState() => _MusclePieChartState();
}

class _MusclePieChartState extends State<MusclePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final slices = widget.slices;
    final total = slices.fold<double>(0, (s, e) => s + e.volume);
    final pct = NumberFormat.percentPattern();
    final grouped = NumberFormat.decimalPattern();

    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 44,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: [
                  for (var i = 0; i < slices.length; i++)
                    PieChartSectionData(
                      value: slices[i].volume,
                      color: _sliceColors[i % _sliceColors.length],
                      radius: _touchedIndex == i ? 58 : 50,
                      showTitle: total > 0 &&
                          (slices[i].volume / total) >= 0.08,
                      title: total > 0
                          ? pct.format(slices[i].volume / total)
                          : '',
                      titleStyle: steelMonoStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: SteelOpsColors.border),
          const SizedBox(height: 12),
          // Legend rows
          Column(
            children: [
              for (var i = 0; i < slices.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i == slices.length - 1 ? 0 : 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: _sliceColors[i % _sliceColors.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.labelFor(slices[i].name),
                          style: steelMonoStyle(
                            fontSize: 10,
                            color: SteelOpsColors.inkMid,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${grouped.format(slices[i].volume.round())} kg',
                        style: steelMonoStyle(
                          fontSize: 10,
                          color: SteelOpsColors.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slices[i].count} ${widget.setsLabel}',
                        style: steelMonoStyle(
                          fontSize: 9,
                          color: SteelOpsColors.inkDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
