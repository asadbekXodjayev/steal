import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/ops_theme.dart';
import '../stats_aggregations.dart';

/// GitHub-style contribution grid for the current calendar year, intensity
/// scaled by per-day volume. Mirrors the web `CalendarHeatmap`.
class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({
    super.key,
    required this.days,
    required this.lessLabel,
    required this.moreLabel,
  });

  /// `yyyy-mm-dd` -> aggregated day.
  final Map<String, HeatmapDay> days;
  final String lessLabel;
  final String moreLabel;

  static const double _cell = 11;
  static const double _gap = 3;

  Color _intensity(double volume, double maxVolume, int count) {
    if (count == 0) return SteelOpsColors.border;
    if (maxVolume > 0) {
      final ratio = volume / maxVolume;
      if (ratio < 0.25) return SteelOpsColors.orange.withAlpha(40);
      if (ratio < 0.6) return SteelOpsColors.orange.withAlpha(140);
      return SteelOpsColors.orange;
    }
    return SteelOpsColors.orange.withAlpha(140);
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final jan1 = DateTime(year, 1, 1);
    final dec31 = DateTime(year, 12, 31);

    // First Sunday on/before Jan 1 (weekday Sun==7 in Dart -> 0 offset).
    final gridStart = jan1.subtract(Duration(days: jan1.weekday % 7));
    final gridEnd = dec31.add(Duration(days: (6 - (dec31.weekday % 7))));
    final totalDays = gridEnd.difference(gridStart).inDays + 1;
    final weeks = (totalDays / 7).round();

    var maxVol = 0.0;
    for (final d in days.values) {
      if (d.volume > maxVol) maxVol = d.volume;
    }

    String keyOf(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    // Month labels: week index where a new month first appears.
    final monthLabels = <int, String>{};
    var lastMonth = -1;
    for (var w = 0; w < weeks; w++) {
      final colDate = gridStart.add(Duration(days: w * 7));
      if (colDate.month != lastMonth && colDate.year == year) {
        monthLabels[w] = DateFormat.MMM().format(colDate).toUpperCase();
        lastMonth = colDate.month;
      }
    }

    final dateFmt = DateFormat.MMMd();

    final columns = <Widget>[];
    for (var w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (var d = 0; d < 7; d++) {
        final date = gridStart.add(Duration(days: w * 7 + d));
        final inYear = date.year == year;
        final day = days[keyOf(date)];
        final count = day?.count ?? 0;
        final vol = day?.volume ?? 0;
        cells.add(
          Padding(
            padding: const EdgeInsets.only(bottom: _gap),
            child: Tooltip(
              message: count > 0
                  ? '${dateFmt.format(date)} — ${vol > 0 ? '${NumberFormat.decimalPattern().format(vol.round())} kg' : '$count'}'
                  : dateFmt.format(date),
              waitDuration: const Duration(milliseconds: 200),
              child: Container(
                width: _cell,
                height: _cell,
                decoration: BoxDecoration(
                  color: inYear
                      ? _intensity(vol, maxVol, count)
                      : SteelOpsColors.border.withAlpha(80),
                ),
              ),
            ),
          ),
        );
      }
      columns.add(
        Padding(
          padding: const EdgeInsets.only(right: _gap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 14,
                child: monthLabels.containsKey(w)
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          monthLabels[w]!,
                          style: steelMonoStyle(
                            fontSize: 8,
                            color: SteelOpsColors.inkDim,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    : null,
              ),
              ...cells,
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns,
            ),
          ),
          const SizedBox(height: 12),
          // Legend: less → more
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lessLabel,
                style: steelMonoStyle(
                  fontSize: 8,
                  color: SteelOpsColors.inkDim,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 6),
              for (final c in [
                SteelOpsColors.border,
                SteelOpsColors.orange.withAlpha(40),
                SteelOpsColors.orange.withAlpha(140),
                SteelOpsColors.orange,
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Container(width: _cell, height: _cell, color: c),
                ),
              const SizedBox(width: 3),
              Text(
                moreLabel,
                style: steelMonoStyle(
                  fontSize: 8,
                  color: SteelOpsColors.inkDim,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
