import 'package:pocketbase/pocketbase.dart';

import 'models.dart';

/// Brian-Epley style 1RM estimate — identical to the web `estimate1RM`.
double estimate1RM(double weight, int reps) {
  if (reps <= 0 || weight <= 0) return 0;
  if (reps == 1) return weight;
  return (weight * (1 + reps / 30) * 10).round() / 10;
}

/// All PocketBase reads/writes for the app. One instance per [PocketBase]
/// client, created by `repositoryProvider`.
class SteelRepository {
  SteelRepository(this.pb);

  final PocketBase pb;

  String? get userId => pb.authStore.isValid ? pb.authStore.record?.id : null;

  // ── Profile / goals ─────────────────────────────────────────────────────

  Future<Profile?> fetchProfile() async {
    final uid = userId;
    if (uid == null) return null;
    try {
      final res = await pb.collection('profiles').getList(
            page: 1,
            perPage: 1,
            filter: 'user="$uid"',
          );
      final item = res.items.isNotEmpty ? res.items.first : null;
      return item == null ? null : Profile.fromRecord(item);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(Map<String, dynamic> body) async {
    final uid = userId;
    if (uid == null) throw StateError('Not authenticated');
    final existing = await pb.collection('profiles').getList(
          page: 1,
          perPage: 1,
          filter: 'user="$uid"',
        );
    final payload = {...body, 'user': uid};
    if (existing.items.isNotEmpty) {
      await pb.collection('profiles').update(existing.items.first.id, body: payload);
    } else {
      await pb.collection('profiles').create(body: payload);
    }
  }

  Future<List<Goal>> fetchGoals() async {
    final uid = userId;
    if (uid == null) return [];
    try {
      final res = await pb.collection('goals').getList(
            page: 1,
            perPage: 10,
            filter: 'user="$uid"',
          );
      return res.items.map(Goal.fromRecord).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Plans ───────────────────────────────────────────────────────────────

  Future<List<WorkoutPlan>> fetchPlans() async {
    final uid = userId;
    if (uid == null) return [];
    final res = await pb.collection('workout_plans').getList(
          page: 1,
          perPage: 50,
          filter: 'user="$uid"',
          sort: '-created',
        );
    return res.items.map(WorkoutPlan.fromRecord).toList();
  }

  Future<WorkoutPlan?> fetchActivePlan() async {
    final uid = userId;
    if (uid == null) return null;
    try {
      final res = await pb.collection('workout_plans').getList(
            page: 1,
            perPage: 1,
            filter: 'user="$uid" && status="active"',
            sort: '-created',
          );
      return res.items.isEmpty ? null : WorkoutPlan.fromRecord(res.items.first);
    } catch (_) {
      return null;
    }
  }

  Future<WorkoutPlan?> fetchPlan(String planId) async {
    try {
      final r = await pb.collection('workout_plans').getOne(planId);
      return WorkoutPlan.fromRecord(r);
    } catch (_) {
      return null;
    }
  }

  Future<List<PlanDay>> fetchPlanDays(String planId) async {
    final res = await pb.collection('plan_days').getList(
          page: 1,
          perPage: 200,
          filter: 'plan="$planId"',
          sort: 'week,dayOfWeek',
        );
    return res.items.map(PlanDay.fromRecord).toList();
  }

  Future<List<PlanExercise>> fetchPlanExercises(String planDayId) async {
    final res = await pb.collection('plan_exercises').getList(
          page: 1,
          perPage: 50,
          filter: 'planDay="$planDayId"',
          sort: 'order',
          expand: 'exercise',
        );
    return res.items.map(PlanExercise.fromRecord).toList();
  }

  /// Completed planDay ids for a plan (for sequential unlock / progress).
  Future<Set<String>> fetchCompletedPlanDays(String planId) async {
    final uid = userId;
    if (uid == null) return {};
    final res = await pb.collection('workout_sessions').getList(
          page: 1,
          perPage: 200,
          filter: 'plan="$planId" && user="$uid" && status="completed"',
          fields: 'planDay',
        );
    return res.items
        .map((r) => r.get<String>('planDay', ''))
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  Future<void> updatePlanStatus(String planId, String status) async {
    await pb.collection('workout_plans').update(planId, body: {'status': status});
  }

  Future<void> deletePlan(String planId) async {
    final days = await pb
        .collection('plan_days')
        .getFullList(filter: 'plan="$planId"');
    for (final day in days) {
      final exs = await pb
          .collection('plan_exercises')
          .getFullList(filter: 'planDay="${day.id}"');
      for (final ex in exs) {
        await pb.collection('plan_exercises').delete(ex.id);
      }
      await pb.collection('plan_days').delete(day.id);
    }
    await pb.collection('workout_plans').delete(planId);
  }

  /// Create a custom plan from raw day definitions (Build screen).
  /// [days]: each = { dayOfWeek, label, focus:[], exercises:[{name,sets,repsMin,repsMax,rpeTarget,restSeconds,notes}] }
  Future<String> createManualPlan({
    required String title,
    required String description,
    required String goalType,
    required String environment,
    required int durationWeeks,
    required List<Map<String, dynamic>> days,
  }) async {
    final uid = userId;
    if (uid == null) throw StateError('Not authenticated');

    final plan = await pb.collection('workout_plans').create(body: {
      'user': uid,
      'title': title,
      'description': description,
      'source': 'custom',
      'goalType': goalType,
      'environment': environment,
      'durationWeeks': durationWeeks,
      'currentWeek': 1,
      'status': 'active',
    });

    for (var week = 1; week <= durationWeeks; week++) {
      for (final day in days) {
        final savedDay = await pb.collection('plan_days').create(body: {
          'plan': plan.id,
          'week': week,
          'dayOfWeek': day['dayOfWeek'],
          'label': day['label'],
          'focus': day['focus'] ?? const [],
          'warmup': null,
          'cooldown': null,
        });
        final exercises = (day['exercises'] as List?) ?? const [];
        for (var i = 0; i < exercises.length; i++) {
          final ex = Map<String, dynamic>.from(exercises[i] as Map);
          await pb.collection('plan_exercises').create(body: {
            'planDay': savedDay.id,
            'name': ex['name'] ?? '',
            'order': i + 1,
            'sets': ex['sets'] ?? 3,
            'repsMin': ex['repsMin'] ?? 8,
            'repsMax': ex['repsMax'] ?? 12,
            'rpeTarget': ex['rpeTarget'] ?? 8,
            'restSeconds': ex['restSeconds'] ?? 90,
            'notes': ex['notes'] ?? '',
            'substitutions': const [],
          });
        }
      }
    }
    return plan.id;
  }

  /// Instantiate a plan from a [ProgramTemplate]. Days repeat across all weeks.
  Future<String> createPlanFromTemplate(ProgramTemplate template) async {
    final days = template.trainingDays
        .map((d) => <String, dynamic>{
              'dayOfWeek': d.dayNumber == 0 ? 1 : d.dayNumber,
              'label': d.label,
              'focus': <String>[d.label],
              'exercises': d.exercises
                  .map((e) => <String, dynamic>{
                        'name': e.name,
                        'sets': int.tryParse(e.sets.replaceAll(RegExp(r'[^0-9]'), '')) ?? 3,
                        'repsMin': _firstInt(e.reps, fallback: 8),
                        'repsMax': _lastInt(e.reps, fallback: 12),
                        'rpeTarget': 8,
                        'restSeconds': _restToSeconds(e.rest),
                        'notes': e.notes,
                      })
                  .toList(),
            })
        .toList();

    return createManualPlan(
      title: template.title,
      description: template.description,
      goalType: template.goalType.isEmpty ? 'muscle_building' : template.goalType,
      environment: 'gym',
      durationWeeks: template.durationWeeks == 0 ? 4 : template.durationWeeks,
      days: days,
    );
  }

  // ── Sessions + sets ───────────────────────────────────────────────────────

  Future<String> startSession({String? plan, String? planDay}) async {
    final uid = userId;
    if (uid == null) throw StateError('Not authenticated');
    final now = DateTime.now().toUtc().toIso8601String();
    final rec = await pb.collection('workout_sessions').create(body: {
      'user': uid,
      'plan': plan ?? '',
      'planDay': planDay ?? '',
      'startedAt': now,
      'status': 'in_progress',
    });
    return rec.id;
  }

  Future<void> logSet({
    required String session,
    String exercise = '',
    String exerciseName = '',
    required int setNumber,
    required int reps,
    required double weight,
    required double rpe,
    String notes = '',
  }) async {
    await pb.collection('session_sets').create(body: {
      'session': session,
      if (exercise.isNotEmpty) 'exercise': exercise,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      // The web app stores the exercise display name in `notes` for quick
      // sessions; keep that convention so history renders names.
      'notes': notes.isNotEmpty ? notes : exerciseName,
    });
  }

  Future<void> completeSession(
    String sessionId, {
    String? mood,
    int? energyLevel,
    String? notes,
    String? plan,
    String? planDay,
  }) async {
    await pb.collection('workout_sessions').update(sessionId, body: {
      'status': 'completed',
      'completedAt': DateTime.now().toUtc().toIso8601String(),
      'mood': ?mood,
      'energyLevel': ?energyLevel,
      'sessionNotes': ?notes,
    });

    // Week progression: if every plan_day in the current week is completed,
    // advance currentWeek. Mirrors the web workout/[sessionId] logic.
    if (plan != null && plan.isNotEmpty && planDay != null && planDay.isNotEmpty) {
      await _maybeAdvanceWeek(plan, planDay);
    }
  }

  Future<void> _maybeAdvanceWeek(String planId, String planDayId) async {
    try {
      final planRec = await pb.collection('workout_plans').getOne(planId);
      final currentWeek =
          asInt(planRec.data['currentWeek']) == 0 ? 1 : asInt(planRec.data['currentWeek']);
      final durationWeeks = asInt(planRec.data['durationWeeks']);

      final daysThisWeek = await pb.collection('plan_days').getFullList(
            filter: 'plan="$planId" && week=$currentWeek',
          );
      if (daysThisWeek.isEmpty) return;

      final completed = await fetchCompletedPlanDays(planId);
      final allDone = daysThisWeek.every((d) => completed.contains(d.id));
      if (allDone && currentWeek < durationWeeks) {
        await pb
            .collection('workout_plans')
            .update(planId, body: {'currentWeek': currentWeek + 1});
      }
    } catch (_) {
      // progression is best-effort; never block session completion
    }
  }

  // ── Exercise catalog ──────────────────────────────────────────────────────

  Future<List<ExerciseCatalogItem>> fetchExercises({String search = ''}) async {
    final filter = search.trim().isEmpty ? null : 'name~"${search.trim()}"';
    final res = await pb.collection('exercises').getList(
          page: 1,
          perPage: 200,
          sort: 'name',
          filter: filter,
        );
    return res.items.map(ExerciseCatalogItem.fromRecord).toList();
  }

  // ── Program templates ─────────────────────────────────────────────────────

  Future<List<ProgramTemplate>> fetchProgramTemplates(String lang) async {
    final res = await pb.collection('plan_templates').getList(
          page: 1,
          perPage: 20,
          sort: '-popularity',
        );
    return res.items.map((r) => ProgramTemplate.fromRecord(r, lang)).toList();
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  /// Mirrors web `useProgressData`: fetch sessions without a user filter (to
  /// dodge PB SDK auto-cancel issues), filter in Dart, then fetch their sets.
  Future<ProgressData> fetchProgressData() async {
    final uid = userId;
    if (uid == null) return ProgressData.empty;

    final sessionsRes = await pb.collection('workout_sessions').getList(
          page: 1,
          perPage: 200,
          expand: 'planDay',
        );
    final completed = sessionsRes.items
        .map(WorkoutSession.fromRecord)
        .where((s) => s.user == uid && s.isCompleted)
        .toList();

    if (completed.isEmpty) return ProgressData(sessions: completed, sets: const []);

    final ids = completed.map((s) => s.id).toList();
    final filter = ids.map((id) => 'session="$id"').join(' || ');
    final setsRes = await pb.collection('session_sets').getList(
          page: 1,
          perPage: 2000,
          filter: filter,
          expand: 'exercise',
        );
    final sets = setsRes.items.map(SessionSet.fromRecord).toList();
    return ProgressData(sessions: completed, sets: sets);
  }
}

int _firstInt(String range, {required int fallback}) {
  final m = RegExp(r'\d+').firstMatch(range);
  return m == null ? fallback : int.parse(m.group(0)!);
}

int _lastInt(String range, {required int fallback}) {
  final matches = RegExp(r'\d+').allMatches(range).toList();
  return matches.isEmpty ? fallback : int.parse(matches.last.group(0)!);
}

int _restToSeconds(String rest) {
  if (rest.isEmpty) return 90;
  final lower = rest.toLowerCase();
  final num = RegExp(r'\d+').firstMatch(lower);
  if (num == null) return 90;
  final value = int.parse(num.group(0)!);
  if (lower.contains('min')) return value * 60;
  return value;
}
