import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local derived computations for the Stats screen.
//
// These mirror the memoized derivations in the web Progress page
// (src/app/(app)/progress/page.tsx) but live entirely inside the stats feature
// so the shared providers.dart stays untouched. All pure functions are exposed
// so they remain trivially testable.
// ─────────────────────────────────────────────────────────────────────────────

/// Estimated 1RM (Epley). Mirrors `estimate1RM` from web `lib/utils`.
double estimate1RM(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0;
  if (reps == 1) return weight;
  return weight * (1 + reps / 30.0);
}

/// One bucket of weekly aggregated volume.
class WeeklyVolumePoint {
  const WeeklyVolumePoint({
    required this.weekStart,
    required this.volume,
    required this.sessions,
  });

  final DateTime weekStart;
  final double volume;
  final int sessions;
}

/// One rep-range bucket for the intensity profile chart.
class RepRangeBucket {
  const RepRangeBucket({required this.label, required this.count});
  final String label;
  final int count;
}

/// One calendar day cell for the contact-matrix heatmap.
class HeatmapDay {
  const HeatmapDay({
    required this.date,
    required this.volume,
    required this.count,
  });
  final DateTime date;
  final double volume;
  final int count;
}

/// Top-line HUD totals across every logged set.
class HudTotals {
  const HudTotals({
    required this.totalReps,
    required this.avgRpe,
    required this.heaviestWeight,
    required this.heaviestReps,
    required this.totalVolume,
  });

  final int totalReps;
  final double avgRpe;
  final double heaviestWeight;
  final int heaviestReps;
  final double totalVolume;

  static const zero = HudTotals(
    totalReps: 0,
    avgRpe: 0,
    heaviestWeight: 0,
    heaviestReps: 0,
    totalVolume: 0,
  );
}

DateTime _weekStartOf(DateTime d) {
  // Sunday-aligned week start (matches the web `setDate(d - d.getDay())`).
  final local = DateTime(d.year, d.month, d.day);
  return local.subtract(Duration(days: local.weekday % 7));
}

/// Sum of `weight × reps` per session id.
Map<String, double> _volumeBySession(List<SessionSet> sets) {
  final out = <String, double>{};
  for (final s in sets) {
    out[s.session] = (out[s.session] ?? 0) + s.volume;
  }
  return out;
}

/// Aggregate completed sessions into the last [take] Sunday-aligned weeks of
/// total volume. Mirrors `enhancedVolumeData` on the web.
List<WeeklyVolumePoint> computeWeeklyVolume(
  List<WorkoutSession> sessions,
  List<SessionSet> sets, {
  int take = 8,
}) {
  if (sessions.isEmpty) return const [];
  final volBySession = _volumeBySession(sets);

  final byWeek = <DateTime, WeeklyVolumePoint>{};
  for (final session in sessions) {
    final wk = _weekStartOf(session.effectiveDate);
    final existing = byWeek[wk];
    final vol = volBySession[session.id] ?? 0;
    if (existing == null) {
      byWeek[wk] = WeeklyVolumePoint(weekStart: wk, volume: vol, sessions: 1);
    } else {
      byWeek[wk] = WeeklyVolumePoint(
        weekStart: wk,
        volume: existing.volume + vol,
        sessions: existing.sessions + 1,
      );
    }
  }

  final ordered = byWeek.values.toList()
    ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  if (ordered.length <= take) return ordered;
  return ordered.sublist(ordered.length - take);
}

const List<({String label, int min, int max})> kRepRanges = [
  (label: '1-3', min: 1, max: 3),
  (label: '4-5', min: 4, max: 5),
  (label: '6-8', min: 6, max: 8),
  (label: '9-10', min: 9, max: 10),
  (label: '11-12', min: 11, max: 12),
  (label: '13+', min: 13, max: 999),
];

/// Count sets per rep range, dropping empty buckets. Mirrors
/// `repsDistributionData` on the web.
List<RepRangeBucket> computeRepsDistribution(List<SessionSet> sets) {
  if (sets.isEmpty) return const [];
  return kRepRanges
      .map((r) => RepRangeBucket(
            label: r.label,
            count:
                sets.where((s) => s.reps >= r.min && s.reps <= r.max).length,
          ))
      .where((b) => b.count > 0)
      .toList();
}

/// Per-day volume + session counts keyed by `yyyy-mm-dd`, for the current year.
/// Mirrors the `dayMap` build in the web CalendarHeatmap.
Map<String, HeatmapDay> computeHeatmapDays(
  List<WorkoutSession> sessions,
  List<SessionSet> sets,
) {
  final volBySession = _volumeBySession(sets);
  final out = <String, HeatmapDay>{};
  for (final session in sessions) {
    final d = session.effectiveDate;
    final key = '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final existing = out[key];
    final vol = volBySession[session.id] ?? 0;
    out[key] = HeatmapDay(
      date: DateTime(d.year, d.month, d.day),
      volume: (existing?.volume ?? 0) + vol,
      count: (existing?.count ?? 0) + 1,
    );
  }
  return out;
}

/// Top-line totals across all sets. Mirrors `hudStats` / `totalVolume`.
HudTotals computeHudTotals(List<SessionSet> sets) {
  if (sets.isEmpty) return HudTotals.zero;
  var totalReps = 0;
  var rpeSum = 0.0;
  var rpeCount = 0;
  var heaviestWeight = 0.0;
  var heaviestReps = 0;
  var totalVolume = 0.0;

  for (final s in sets) {
    totalReps += s.reps;
    totalVolume += s.volume;
    if (s.rpe > 0) {
      rpeSum += s.rpe;
      rpeCount++;
    }
    if (s.weight > heaviestWeight) {
      heaviestWeight = s.weight;
      heaviestReps = s.reps;
    }
  }

  return HudTotals(
    totalReps: totalReps,
    avgRpe: rpeCount > 0 ? rpeSum / rpeCount : 0,
    heaviestWeight: heaviestWeight,
    heaviestReps: heaviestReps,
    totalVolume: totalVolume,
  );
}

// ── Providers (derive off the shared progressDataProvider) ───────────────────

final weeklyVolumeProvider = Provider<List<WeeklyVolumePoint>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return const [];
  return computeWeeklyVolume(data.sessions, data.sets);
});

final repsDistributionProvider = Provider<List<RepRangeBucket>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return const [];
  return computeRepsDistribution(data.sets);
});

final heatmapDaysProvider = Provider<Map<String, HeatmapDay>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return const {};
  return computeHeatmapDays(data.sessions, data.sets);
});

final hudTotalsProvider = Provider<HudTotals>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return HudTotals.zero;
  return computeHudTotals(data.sets);
});
