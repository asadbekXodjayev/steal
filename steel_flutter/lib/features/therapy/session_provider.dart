import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain types
// ─────────────────────────────────────────────────────────────────────────────

/// A single logged set for a given exercise inside an active session.
class LoggedSet {
  const LoggedSet({
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.rpe,
  });

  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weight;
  final double rpe;
}

/// One exercise slot in the active session, carrying its plan metadata
/// (when loaded from a planDay) and all sets logged so far.
class ActiveExercise {
  const ActiveExercise({
    required this.name,
    required this.targetSets,
    required this.repsLabel,
    required this.rpeTarget,
    required this.restSeconds,
    required this.loggedSets,
  });

  final String name;
  final int targetSets;
  final String repsLabel;
  final double rpeTarget;
  final int restSeconds;
  final List<LoggedSet> loggedSets;

  ActiveExercise copyWithSet(LoggedSet set) => ActiveExercise(
        name: name,
        targetSets: targetSets,
        repsLabel: repsLabel,
        rpeTarget: rpeTarget,
        restSeconds: restSeconds,
        loggedSets: [...loggedSets, set],
      );

  /// Factory that seeds an entry from a plan exercise (no logged sets yet).
  factory ActiveExercise.fromPlanExercise(PlanExercise pe) => ActiveExercise(
        name: pe.name.isNotEmpty ? pe.name : 'Exercise',
        targetSets: pe.sets,
        repsLabel: pe.repsLabel,
        rpeTarget: pe.rpeTarget,
        restSeconds: pe.restSeconds,
        loggedSets: const [],
      );

  /// Factory for ad-hoc exercises (quick session or user-typed).
  factory ActiveExercise.adhoc(String name) => ActiveExercise(
        name: name,
        targetSets: 0,
        repsLabel: '',
        rpeTarget: 0,
        restSeconds: 0,
        loggedSets: const [],
      );
}

/// Status of the active workout session lifecycle.
enum SessionStatus { idle, inProgress, saving, completed }

const _unset = Object();

/// Full state for an active workout session.
class SessionState {
  const SessionState({
    this.sessionId,
    this.status = SessionStatus.idle,
    this.exercises = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  /// PocketBase record id once `startSession` resolves.
  final String? sessionId;
  final SessionStatus status;

  /// Ordered list of exercises for this session (seeded from plan or empty).
  final List<ActiveExercise> exercises;

  /// True while any async PB call is in flight.
  final bool isSaving;

  /// Non-null when the last operation failed.
  final String? errorMessage;

  bool get isIdle => status == SessionStatus.idle;
  bool get isActive => status == SessionStatus.inProgress;
  bool get isCompleted => status == SessionStatus.completed;

  SessionState copyWith({
    String? sessionId,
    SessionStatus? status,
    List<ActiveExercise>? exercises,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._ref) : super(const SessionState());

  final Ref _ref;

  /// Begin a new PocketBase session. Optionally pre-seeds exercises from a
  /// planDay when [planDay] is provided.
  Future<void> start({String? plan, String? planDay}) async {
    state = const SessionState(
      status: SessionStatus.idle,
      isSaving: true,
      exercises: [],
    );

    try {
      final repo = _ref.read(repositoryProvider);
      final id = await repo.startSession(plan: plan, planDay: planDay);

      List<ActiveExercise> seeded = const [];
      if (planDay != null && planDay.isNotEmpty) {
        try {
          final planExercises =
              await _ref.read(planExercisesProvider(planDay).future);
          seeded = planExercises
              .map(ActiveExercise.fromPlanExercise)
              .toList();
        } catch (_) {
          // If plan exercises can't be loaded, proceed with an empty list.
        }
      }

      state = SessionState(
        sessionId: id,
        status: SessionStatus.inProgress,
        exercises: seeded,
        isSaving: false,
      );
    } catch (e) {
      state = SessionState(
        status: SessionStatus.idle,
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Log a single set to PocketBase and optimistically update state.
  /// If the exercise doesn't exist in the list yet, it is appended.
  Future<void> addSet(
    String exerciseName, {
    required int reps,
    required double weight,
    required double rpe,
  }) async {
    final id = state.sessionId;
    if (id == null) return;

    // Find or create the exercise slot.
    final exercises = List<ActiveExercise>.from(state.exercises);
    final idx =
        exercises.indexWhere((e) => e.name == exerciseName);

    final int setNumber;
    if (idx == -1) {
      // New exercise — append a placeholder first so the set number is 1.
      exercises.add(ActiveExercise.adhoc(exerciseName));
      setNumber = 1;
    } else {
      setNumber = exercises[idx].loggedSets.length + 1;
    }

    final newSet = LoggedSet(
      exerciseName: exerciseName,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      rpe: rpe,
    );

    // Optimistic update.
    final resolvedIdx = exercises.indexWhere((e) => e.name == exerciseName);
    exercises[resolvedIdx] = exercises[resolvedIdx].copyWithSet(newSet);
    state = state.copyWith(exercises: exercises, errorMessage: null);

    try {
      await _ref.read(repositoryProvider).logSet(
            session: id,
            exerciseName: exerciseName,
            setNumber: setNumber,
            reps: reps,
            weight: weight,
            rpe: rpe,
          );
    } catch (e) {
      // Roll back the optimistic set on failure.
      final rolled = List<ActiveExercise>.from(state.exercises);
      final ri = rolled.indexWhere((ex) => ex.name == exerciseName);
      if (ri != -1 && rolled[ri].loggedSets.isNotEmpty) {
        final sets = List<LoggedSet>.from(rolled[ri].loggedSets)
          ..removeLast();
        rolled[ri] = ActiveExercise(
          name: rolled[ri].name,
          targetSets: rolled[ri].targetSets,
          repsLabel: rolled[ri].repsLabel,
          rpeTarget: rolled[ri].rpeTarget,
          restSeconds: rolled[ri].restSeconds,
          loggedSets: sets,
        );
      }
      state = state.copyWith(
        exercises: rolled,
        errorMessage: 'Failed to save set: ${e.toString()}',
      );
    }
  }

  /// Complete the session. Invalidates [progressDataProvider] on success so
  /// the progress screen reloads with the newly logged data.
  Future<void> complete({
    String? mood,
    int? energyLevel,
    String? notes,
    String? plan,
    String? planDay,
  }) async {
    final id = state.sessionId;
    if (id == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _ref.read(repositoryProvider).completeSession(
            id,
            mood: mood,
            energyLevel: energyLevel,
            notes: notes,
            plan: plan,
            planDay: planDay,
          );

      // Invalidate so progress charts refresh.
      _ref.invalidate(progressDataProvider);

      state = state.copyWith(
        status: SessionStatus.completed,
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add an exercise slot without logging a set yet — used by the
  /// "Add Exercise" bar to create the card before the first set is entered.
  void addExerciseSlot(String exerciseName) {
    final trimmed = exerciseName.trim();
    if (trimmed.isEmpty) return;
    final already =
        state.exercises.any((e) => e.name == trimmed);
    if (already) return; // idempotent
    state = state.copyWith(
      exercises: [...state.exercises, ActiveExercise.adhoc(trimmed)],
    );
  }

  /// Reset to idle — call after the screen is dismissed.
  void reset() {
    state = const SessionState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(ref),
);
