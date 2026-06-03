// Derived dashboard data, wired to the real read-only providers.
//
// This file mirrors the web dashboard's client-side aggregation
// (src/app/(app)/dashboard/page.tsx): the "next session" (first uncompleted
// plan_day in the active plan), the "last sessions" feed (recent completed
// sessions), per-session volume/set counts, total tonnage, PRs this month and
// the derived display week. All inputs come from existing providers in
// lib/data/providers.dart — nothing here writes or fetches directly.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models.dart';
import '../../../data/providers.dart';

/// A single completed session enriched with its plan-day label and volume.
class DashboardActivity {
  const DashboardActivity({
    required this.session,
    required this.dayLabel,
    required this.setCount,
    required this.volume,
  });

  final WorkoutSession session;
  final String dayLabel;
  final int setCount;
  final double volume;

  /// Volume in tonnes, e.g. "1.4T", or "—" when there is none.
  String get volumeLabel =>
      volume <= 0 ? '—' : '${(volume / 1000).toStringAsFixed(1)}T';
}

/// The next plan-day in line for the active plan, plus its exercises.
class NextSession {
  const NextSession({
    required this.day,
    required this.exercises,
    required this.isCompleted,
    required this.estimatedMinutes,
  });

  final PlanDay day;
  final List<PlanExercise> exercises;
  final bool isCompleted;
  final int estimatedMinutes;
}

/// One row in the weekly schedule strip (upcoming + completed sessions).
class ScheduleEntry {
  const ScheduleEntry({
    required this.dayLabel,
    required this.focus,
    required this.isCompleted,
    required this.isNext,
    required this.isLocked,
    this.dateLabel,
  });

  final String dayLabel;
  final List<String> focus;
  final bool isCompleted;
  final bool isNext;
  final bool isLocked;
  final String? dateLabel;
}

const _months = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

String _shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}${_months[d.month - 1]}';

String formatTacticalDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mon = _months[d.month - 1];
  final yy = (d.year % 100).toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$dd$mon$yy $hh$mm';
}

// ── Total volume (tonnes) across all completed sets ──────────────────────────

final totalVolumeTonsProvider = Provider<int>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return 0;
  final total = data.sets.fold<double>(0, (acc, s) => acc + s.volume);
  return (total / 1000).round();
});

// ── PRs set this calendar month ──────────────────────────────────────────────

final prsThisMonthProvider = Provider<int>((ref) {
  final records = ref.watch(personalRecordsProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  return records.where((pr) {
    final d = DateTime.tryParse(pr.date)?.toLocal();
    return d != null && !d.isBefore(monthStart);
  }).length;
});

// ── Recent completed sessions feed (LAST SESSIONS) ───────────────────────────

final recentActivityProvider = Provider<List<DashboardActivity>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null || data.sessions.isEmpty) return const [];

  // Per-session volume + set counts.
  final volumes = <String, double>{};
  final counts = <String, int>{};
  for (final s in data.sets) {
    volumes[s.session] = (volumes[s.session] ?? 0) + s.volume;
    counts[s.session] = (counts[s.session] ?? 0) + 1;
  }

  final sorted = [...data.sessions]
    ..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));

  return sorted.take(5).map((s) {
    // Empty label = no session notes; the view localizes the fallback ("WORKOUT").
    final label =
        s.sessionNotes.isNotEmpty ? s.sessionNotes.toUpperCase() : '';
    return DashboardActivity(
      session: s,
      dayLabel: label,
      setCount: counts[s.id] ?? 0,
      volume: volumes[s.id] ?? 0,
    );
  }).toList();
});

// ── Completed plan-day ids for the active plan ───────────────────────────────

final _activeCompletedDaysProvider = Provider<AsyncValue<Set<String>>>((ref) {
  final plan = ref.watch(activePlanProvider).valueOrNull;
  if (plan == null) return const AsyncData(<String>{});
  return ref.watch(completedPlanDaysProvider(plan.id));
});

// ── Derived display week (first uncompleted day's week) ──────────────────────

final displayWeekProvider = Provider<int>((ref) {
  final plan = ref.watch(activePlanProvider).valueOrNull;
  if (plan == null) return 1;
  final days = ref.watch(planDaysProvider(plan.id)).valueOrNull;
  final completed = ref.watch(_activeCompletedDaysProvider).valueOrNull ?? {};
  if (days == null || days.isEmpty) return plan.currentWeek;

  final sorted = [...days]..sort((a, b) =>
      a.week != b.week ? a.week.compareTo(b.week) : a.dayOfWeek.compareTo(b.dayOfWeek));
  for (final d in sorted) {
    if (!completed.contains(d.id)) return d.week;
  }
  return plan.currentWeek;
});

/// Sort plan days by week then dayOfWeek (shared helper).
List<PlanDay> sortPlanDays(List<PlanDay> days) {
  final sorted = [...days];
  sorted.sort((a, b) =>
      a.week != b.week ? a.week.compareTo(b.week) : a.dayOfWeek.compareTo(b.dayOfWeek));
  return sorted;
}

/// First uncompleted plan day (the "next session"), or null when finished.
PlanDay? firstUncompletedDay(List<PlanDay> days, Set<String> completed) {
  for (final d in sortPlanDays(days)) {
    if (!completed.contains(d.id)) return d;
  }
  return null;
}

/// Build the weekly schedule strip: up to 3 upcoming + last 2 completed.
List<ScheduleEntry> buildSchedule(
  List<PlanDay> days,
  Set<String> completedIds, {
  required int displayWeek,
}) {
  final sorted = sortPlanDays(days);
  final firstUncompletedIndex =
      sorted.indexWhere((d) => !completedIds.contains(d.id));
  final startIndex = firstUncompletedIndex >= 0 ? firstUncompletedIndex : 0;
  final nextWeek =
      startIndex < sorted.length ? sorted[startIndex].week : displayWeek;

  String upcomingDate(int dayOfWeek, int programWeek) {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1=Mon … 7=Sun
    var daysUntil = dayOfWeek - currentDay;
    if (daysUntil < 0) daysUntil += 7;
    daysUntil += (programWeek - nextWeek) * 7;
    return _shortDate(now.add(Duration(days: daysUntil)));
  }

  final out = <ScheduleEntry>[];

  // Upcoming (from first uncompleted, max 3).
  var collected = 0;
  for (var i = startIndex; i < sorted.length && collected < 3; i++) {
    final d = sorted[i];
    if (completedIds.contains(d.id)) continue;
    out.add(ScheduleEntry(
      dayLabel: d.label,
      focus: d.focus,
      isCompleted: false,
      isNext: collected == 0,
      isLocked: collected > 0,
      dateLabel: upcomingDate(d.dayOfWeek, d.week),
    ));
    collected++;
  }

  // Completed (last 2, newest first).
  final completedDays =
      sorted.where((d) => completedIds.contains(d.id)).toList();
  final lastTwo = completedDays.length <= 2
      ? completedDays.reversed.toList()
      : completedDays.sublist(completedDays.length - 2).reversed.toList();
  for (final d in lastTwo) {
    out.add(ScheduleEntry(
      dayLabel: d.label,
      focus: d.focus,
      isCompleted: true,
      isNext: false,
      isLocked: false,
    ));
  }

  return out;
}

/// Estimated session minutes from its exercises (sets * (rest + 45s)).
int estimateMinutes(List<PlanExercise> exercises) {
  if (exercises.isEmpty) return 0;
  final seconds = exercises.fold<int>(
      0, (acc, e) => acc + e.sets * (e.restSeconds + 45));
  return (seconds / 60).round();
}
