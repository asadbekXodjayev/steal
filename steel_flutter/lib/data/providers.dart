import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/pb_provider.dart';
import 'models.dart';
import 'repository.dart';

/// Single repository instance bound to the live PB client.
final repositoryProvider = Provider<SteelRepository>(
  (ref) => SteelRepository(ref.watch(pocketbaseProvider)),
);

/// Active UI language for template projection. Defaults to English; the
/// settings screen can flip it. Kept here so providers can react to it.
final languageProvider = StateProvider<String>((ref) => 'en');

// ── Profile / goals ─────────────────────────────────────────────────────────

final profileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchProfile();
});

final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchGoals();
});

// ── Plans ────────────────────────────────────────────────────────────────────

final plansProvider = FutureProvider<List<WorkoutPlan>>((ref) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchPlans();
});

final activePlanProvider = FutureProvider<WorkoutPlan?>((ref) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchActivePlan();
});

final planProvider =
    FutureProvider.family<WorkoutPlan?, String>((ref, planId) async {
  return ref.watch(repositoryProvider).fetchPlan(planId);
});

final planDaysProvider =
    FutureProvider.family<List<PlanDay>, String>((ref, planId) async {
  return ref.watch(repositoryProvider).fetchPlanDays(planId);
});

final planExercisesProvider =
    FutureProvider.family<List<PlanExercise>, String>((ref, planDayId) async {
  return ref.watch(repositoryProvider).fetchPlanExercises(planDayId);
});

final completedPlanDaysProvider =
    FutureProvider.family<Set<String>, String>((ref, planId) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchCompletedPlanDays(planId);
});

// ── Exercise catalog ───────────────────────────────────────────────────────

final exerciseSearchProvider = StateProvider<String>((ref) => '');

/// The full exercise catalog, loaded once from the bundled
/// `assets/exercises.json` (1,300+ exercises — the same static dataset the
/// web app's library uses). The PocketBase `exercises` collection is empty,
/// so we do NOT read it here.
final _exerciseSourceProvider =
    FutureProvider<List<ExerciseCatalogItem>>((ref) async {
  final raw = await rootBundle.loadString('assets/exercises.json');
  final decoded = jsonDecode(raw);
  final list = decoded is List
      ? decoded
      : (decoded is Map ? (decoded['exercises'] ?? decoded['items'] ?? []) : []);
  return (list as List)
      .map((e) => ExerciseCatalogItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
});

/// Search-filtered view over the bundled catalog (filters in Dart so typing
/// is instant and works offline).
final exerciseCatalogProvider =
    FutureProvider<List<ExerciseCatalogItem>>((ref) async {
  final all = await ref.watch(_exerciseSourceProvider.future);
  final q = ref.watch(exerciseSearchProvider).trim().toLowerCase();
  if (q.isEmpty) return all;
  return all
      .where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.muscleGroup.toLowerCase().contains(q) ||
          e.target.toLowerCase().contains(q) ||
          e.equipment.toLowerCase().contains(q))
      .toList();
});

// ── Program templates ──────────────────────────────────────────────────────

final programTemplatesProvider =
    FutureProvider<List<ProgramTemplate>>((ref) async {
  final lang = ref.watch(languageProvider);
  return ref.watch(repositoryProvider).fetchProgramTemplates(lang);
});

// ── Progress ─────────────────────────────────────────────────────────────────

final progressDataProvider = FutureProvider<ProgressData>((ref) async {
  ref.watch(currentUserIdProvider);
  return ref.watch(repositoryProvider).fetchProgressData();
});

/// Streak stats derived from completed sessions. Mirrors web `useStreakData`.
final streakProvider = Provider<StreakData>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null || data.sessions.isEmpty) return StreakData.zero;
  return computeStreak(data.sessions);
});

final personalRecordsProvider = Provider<List<PersonalRecord>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return const [];
  return computePersonalRecords(data.sets);
});

final muscleDistributionProvider = Provider<List<MuscleSlice>>((ref) {
  final data = ref.watch(progressDataProvider).valueOrNull;
  if (data == null) return const [];
  return computeMuscleDistribution(data.sets);
});

// ── Pure computations (testable, mirror src/hooks/useProgress.ts) ────────────

StreakData computeStreak(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) return StreakData.zero;

  final now = DateTime.now();
  final weekday = now.weekday; // 1 = Mon
  final weekStart =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  final dated = sessions.map((s) => s.effectiveDate).toList()
    ..sort((a, b) => b.compareTo(a));

  // Deduplicate by calendar day, newest first.
  final seen = <String>{};
  final uniqueDays = <DateTime>[];
  for (final d in dated) {
    final k = dayKey(d);
    if (seen.add(k)) uniqueDays.add(d);
  }

  final todayKey = dayKey(now);
  final yesterdayKey = dayKey(now.subtract(const Duration(days: 1)));

  var currentStreak = 0;
  if (uniqueDays.isNotEmpty &&
      (dayKey(uniqueDays.first) == todayKey ||
          dayKey(uniqueDays.first) == yesterdayKey)) {
    final keySet = uniqueDays.map(dayKey).toSet();
    for (var i = 0; i < uniqueDays.length + 1; i++) {
      final expected = dayKey(now.subtract(Duration(days: i)));
      if (keySet.contains(expected)) {
        currentStreak++;
      } else {
        break;
      }
    }
  }

  var longestStreak = currentStreak;
  var temp = 1;
  for (var i = 1; i < uniqueDays.length; i++) {
    final diff = uniqueDays[i - 1].difference(uniqueDays[i]).inHours / 24.0;
    if (diff <= 1.5) {
      temp++;
      if (temp > longestStreak) longestStreak = temp;
    } else {
      temp = 1;
    }
  }

  final thisWeek = sessions.where((s) => !s.effectiveDate.isBefore(weekStart)).length;
  final thisMonth =
      sessions.where((s) => !s.effectiveDate.isBefore(monthStart)).length;

  return StreakData(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalSessions: sessions.length,
    thisWeekSessions: thisWeek,
    thisMonthSessions: thisMonth,
  );
}

List<PersonalRecord> computePersonalRecords(List<SessionSet> sets) {
  if (sets.isEmpty) return const [];
  final byExercise = <String, List<SessionSet>>{};
  for (final s in sets) {
    final key = s.exercise.isNotEmpty ? s.exercise : s.notes;
    byExercise.putIfAbsent(key, () => []).add(s);
  }

  final records = <PersonalRecord>[];
  byExercise.forEach((exId, exSets) {
    SessionSet? best;
    var best1RM = 0.0;
    for (final s in exSets) {
      final e = estimate1RM(s.weight, s.reps);
      if (e > best1RM) {
        best1RM = e;
        best = s;
      }
    }
    final b = best;
    if (b != null) {
      final name = exSets
          .map((s) => s.exerciseName)
          .firstWhere((n) => n.isNotEmpty,
              orElse: () => b.notes.isNotEmpty ? b.notes : exId);
      records.add(PersonalRecord(
        exerciseId: exId,
        exerciseName: name.isEmpty ? exId : name,
        weight: b.weight,
        reps: b.reps,
        estimated1RM: best1RM,
        date: b.created,
      ));
    }
  });

  records.sort((a, b) => b.estimated1RM.compareTo(a.estimated1RM));
  return records;
}

const _muscleMapping = <String, List<String>>{
  'CHEST': ['bench', 'chest', 'fly', 'crossover', 'press'],
  'BACK': ['row', 'pullup', 'pull-up', 'pulldown', 'lat', 'deadlift', 'rear delt'],
  'SHOULDER': ['shoulder', 'overhead', 'lateral', 'front raise', 'arnold', 'military', 'delts'],
  'BICEP': ['curl', 'bicep', 'hammer curl', 'preacher'],
  'TRICEP': ['pushdown', 'tricep', 'extension', 'skull crusher', 'close grip', 'dip'],
  'QUAD': ['squat', 'leg press', 'leg extension', 'lunge', 'bulgarian', 'goblet'],
  'HAMSTRING': ['leg curl', 'rdl', 'romanian', 'stiff leg', 'nordic', 'good morning'],
  'GLUTE': ['hip thrust', 'glute', 'kickback', 'abductor'],
  'CALF': ['calf'],
  'TRAP': ['shrug', 'trap', 'face pull'],
  'ABS': ['plank', 'crunch', 'leg raise', 'hanging knee', 'ab wheel', 'russian'],
};

List<MuscleSlice> computeMuscleDistribution(List<SessionSet> sets) {
  if (sets.isEmpty) return const [];
  final counts = <String, int>{};
  final volumes = <String, double>{};

  for (final set in sets) {
    final name = (set.exerciseName.isNotEmpty
            ? set.exerciseName
            : (set.notes.isNotEmpty ? set.notes : set.exercise))
        .toLowerCase();
    var matched = 'OTHER';
    for (final entry in _muscleMapping.entries) {
      if (entry.value.any(name.contains)) {
        matched = entry.key;
        break;
      }
    }
    counts[matched] = (counts[matched] ?? 0) + 1;
    volumes[matched] = (volumes[matched] ?? 0) + set.volume;
  }

  final result = volumes.entries
      .map((e) => MuscleSlice(name: e.key, volume: e.value, count: counts[e.key] ?? 0))
      .toList()
    ..sort((a, b) => b.volume.compareTo(a.volume));
  return result;
}
