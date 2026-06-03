import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'session_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route entry point
// ─────────────────────────────────────────────────────────────────────────────

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, this.planId, this.planDayId});

  /// Optional plan/planDay ids — when provided the notifier pre-seeds exercises.
  final String? planId;
  final String? planDayId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).start(
            plan: widget.planId,
            planDay: widget.planDayId,
          );
    });
  }

  @override
  void dispose() {
    // Reset provider when screen is popped so next open is always fresh.
    ref.read(sessionProvider.notifier).reset();
    super.dispose();
  }

  void _onFinishTapped() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SteelOpsColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => _FinishSheet(
        planId: widget.planId,
        planDayId: widget.planDayId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final t = ref.watch(tProvider);

    // Navigate away once the session is marked completed.
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.isCompleted && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t('session.SESSION_COMPLETE_MSG'),
              style: steelMonoStyle(
                  fontSize: 12, color: Colors.white, letterSpacing: 1.2),
            ),
            backgroundColor: SteelOpsColors.forge,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: SteelAppBar(
        title: t('session.TITLE'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: SteelOpsColors.inkMid),
          tooltip: t('session.CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: session.isActive
            ? [
                TextButton(
                  onPressed: session.isSaving ? null : _onFinishTapped,
                  child: Text(
                    t('session.FINISH'),
                    style: steelMonoStyle(
                        fontSize: 12, color: SteelOpsColors.orange),
                  ),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Forge accent stripe
          Container(height: 3, color: SteelOpsColors.forge),

          if (session.errorMessage != null)
            _ErrorBanner(
              message: session.errorMessage!,
              onDismiss: () =>
                  ref.read(sessionProvider.notifier).reset(),
            ),

          Expanded(child: _SessionBody(session: session)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — switches between loading / idle / active
// ─────────────────────────────────────────────────────────────────────────────

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session});
  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    if (session.isSaving && session.isIdle) {
      return const Center(
        child: CircularProgressIndicator(color: SteelOpsColors.forge),
      );
    }

    if (session.isIdle && !session.isSaving) {
      return Center(
        child: SteelEmptyState(
          icon: Icons.fitness_center_outlined,
          title: t('session.NOT_STARTED'),
          subtitle: t('session.NOT_STARTED_DESC'),
          actionLabel: t('session.RETRY'),
          onAction: () =>
              ref.read(sessionProvider.notifier).start(),
        ),
      );
    }

    if (session.exercises.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: SteelEmptyState(
                icon: Icons.add_circle_outline,
                title: t('session.NO_EXERCISES'),
                subtitle: t('session.NO_EXERCISES_DESC'),
              ),
            ),
          ),
          _AddExerciseBar(session: session),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: session.exercises.length,
            itemBuilder: (_, i) =>
                _ExerciseCard(exercise: session.exercises[i]),
          ),
        ),
        _AddExerciseBar(session: session),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-exercise card: shows target, logged sets, and ADD SET row
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({required this.exercise});
  final ActiveExercise exercise;

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  final _repsCtrl = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController(text: '0');
  final _rpeCtrl = TextEditingController(text: '8');

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _rpeCtrl.dispose();
    super.dispose();
  }

  void _addSet() {
    final reps = int.tryParse(_repsCtrl.text.trim()) ?? 0;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    final rpe = double.tryParse(_rpeCtrl.text.trim()) ?? 8;
    if (reps <= 0) return;

    ref.read(sessionProvider.notifier).addSet(
          widget.exercise.name,
          reps: reps,
          weight: weight,
          rpe: rpe,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
    final ex = widget.exercise;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: SteelOpsColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ex.name.toUpperCase(),
                    style: steelHeadingStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ex.targetSets > 0)
                  Text(
                    t('session.SETS')
                        .replaceAll('{logged}', '${ex.loggedSets.length}')
                        .replaceAll('{target}', '${ex.targetSets}'),
                    style: steelMonoStyle(
                        fontSize: 10, color: SteelOpsColors.forge),
                  ),
              ],
            ),
          ),

          // Plan target hint
          if (ex.repsLabel.isNotEmpty || ex.rpeTarget > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                [
                  if (ex.repsLabel.isNotEmpty)
                    t('session.TARGET_REPS')
                        .replaceAll('{reps}', ex.repsLabel),
                  if (ex.rpeTarget > 0)
                    '${t('session.RPE')} ${ex.rpeTarget.toStringAsFixed(0)}',
                ].join('  ·  '),
                style: steelMonoStyle(
                    fontSize: 9,
                    color: SteelOpsColors.inkDim,
                    letterSpacing: 1.2),
              ),
            ),

          // Logged sets
          if (ex.loggedSets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                children: ex.loggedSets
                    .map((s) => _SetRow(set: s))
                    .toList(),
              ),
            ),

          // Add set row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _NumField(
                  label: t('session.FIELD_REPS'),
                  controller: _repsCtrl,
                  digits: false,
                ),
                const SizedBox(width: 8),
                _NumField(
                  label: t('session.FIELD_KG'),
                  controller: _weightCtrl,
                  digits: true,
                ),
                const SizedBox(width: 8),
                _NumField(
                  label: t('session.FIELD_RPE'),
                  controller: _rpeCtrl,
                  digits: true,
                ),
                const SizedBox(width: 10),
                SteelForgeButton(
                  label: t('session.ADD_SET'),
                  expanded: false,
                  onPressed: _addSet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A single logged set row
// ─────────────────────────────────────────────────────────────────────────────

class _SetRow extends ConsumerWidget {
  const _SetRow({required this.set});
  final LoggedSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              '${set.setNumber}',
              style: steelMonoStyle(
                  fontSize: 10, color: SteelOpsColors.forge),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${set.reps} ${t('session.REPS')}',
            style: steelMonoStyle(
                fontSize: 11, color: SteelOpsColors.inkMid),
          ),
          const SizedBox(width: 12),
          Text(
            '${set.weight.toStringAsFixed(set.weight % 1 == 0 ? 0 : 1)} ${t('session.KG')}',
            style: steelMonoStyle(
                fontSize: 11, color: SteelOpsColors.inkMid),
          ),
          const SizedBox(width: 12),
          Text(
            '${t('session.RPE')} ${set.rpe.toStringAsFixed(0)}',
            style: steelMonoStyle(
                fontSize: 10, color: SteelOpsColors.inkDim),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add exercise chip bar (quick-picks + custom input)
// ─────────────────────────────────────────────────────────────────────────────

const _kQuickExercises = [
  'Bench Press', 'Squat', 'Deadlift', 'Overhead Press',
  'Barbell Row', 'Pull-Up', 'Dip', 'Leg Press',
  'Romanian Deadlift', 'Incline DB Press',
];

class _AddExerciseBar extends ConsumerStatefulWidget {
  const _AddExerciseBar({required this.session});
  final SessionState session;

  @override
  ConsumerState<_AddExerciseBar> createState() => _AddExerciseBarState();
}

class _AddExerciseBarState extends ConsumerState<_AddExerciseBar> {
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _addExercise(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final notifier = ref.read(sessionProvider.notifier);
    // Ensure the exercise slot exists by adding a zero-weight placeholder
    // set — no: just add the exercise to the list by calling addSet with 0.
    // Actually we want to add the exercise slot without a set. The provider
    // handles unknown exercise names in addSet, but we want the card to appear
    // immediately. We do this by calling addSet with 0 reps which the card
    // will not display (setNumber 1, reps 0 will be stored but skipped on
    // render). Better approach: expose a dedicated addExercise in the notifier.
    // For simplicity we call addSet with minimal values so the PB record is
    // created; we check reps > 0 before sending to PB in addSet, so we need
    // to just add the slot optimistically. The notifier's addSet checks
    // reps <= 0 only on the screen side. Let's directly mutate state via a
    // dedicated notifier method instead.
    //
    // The simplest correct solution: expose an addExerciseSlot on the notifier.
    notifier.addExerciseSlot(trimmed);
    _customCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
    return Container(
      color: SteelOpsColors.surfaceElevated,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t('session.ADD_EXERCISE'),
            style: steelMonoStyle(
                fontSize: 9,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          // Custom name input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customCtrl,
                  style: steelMonoStyle(
                      fontSize: 12, color: SteelOpsColors.inkHigh),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: t('session.CUSTOM_HINT'),
                    hintStyle: steelMonoStyle(
                        fontSize: 12, color: SteelOpsColors.inkDim),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(
                          color: SteelOpsColors.borderStrong),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide:
                          const BorderSide(color: SteelOpsColors.forge),
                    ),
                  ),
                  onFieldSubmitted: _addExercise,
                ),
              ),
              const SizedBox(width: 8),
              SteelForgeButton(
                label: t('session.ADD'),
                expanded: false,
                onPressed: () => _addExercise(_customCtrl.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick-pick chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kQuickExercises
                .map(
                  (ex) => GestureDetector(
                    onTap: () => _addExercise(ex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: SteelOpsColors.borderStrong),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        ex,
                        style: steelMonoStyle(
                            fontSize: 10, color: SteelOpsColors.inkMid),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Finish session bottom sheet — mood / energy / notes
// ─────────────────────────────────────────────────────────────────────────────

class _FinishSheet extends ConsumerStatefulWidget {
  const _FinishSheet({this.planId, this.planDayId});
  final String? planId;
  final String? planDayId;

  @override
  ConsumerState<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends ConsumerState<_FinishSheet> {
  String? _mood;
  int _energy = 3;
  final _notesCtrl = TextEditingController();

  static const _moods = ['great', 'good', 'okay', 'tired', 'bad'];
  static const _moodLabelKeys = [
    'session.MOOD_GREAT',
    'session.MOOD_GOOD',
    'session.MOOD_OKAY',
    'session.MOOD_TIRED',
    'session.MOOD_BAD',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(sessionProvider.notifier).complete(
          mood: _mood,
          energyLevel: _energy,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          plan: widget.planId,
          planDay: widget.planDayId,
        );
    if (mounted) Navigator.of(context).pop(); // close sheet
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final t = ref.watch(tProvider);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t('session.FINISH_SESSION'),
                style: steelHeadingStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              t('session.HOW_IT_GO'),
              style: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.muted),
            ),
            const SizedBox(height: 24),

            // Mood
            Text(
              t('session.MOOD'),
              style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.muted,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_moods.length, (i) {
                final selected = _mood == _moods[i];
                return GestureDetector(
                  onTap: () => setState(() => _mood = _moods[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? SteelOpsColors.forge
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? SteelOpsColors.forge
                            : SteelOpsColors.borderStrong,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      t(_moodLabelKeys[i]),
                      style: steelMonoStyle(
                        fontSize: 11,
                        color: selected
                            ? Colors.white
                            : SteelOpsColors.inkMid,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Energy level 1-5
            Text(
              t('session.ENERGY').replaceAll('{n}', '$_energy'),
              style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.muted,
                  letterSpacing: 1.5),
            ),
            Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: SteelOpsColors.forge,
              inactiveColor: SteelOpsColors.border,
              onChanged: (v) => setState(() => _energy = v.round()),
            ),
            const SizedBox(height: 16),

            // Notes
            Text(
              t('session.NOTES'),
              style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.muted,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              style: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.inkHigh),
              decoration: InputDecoration(
                hintText: t('session.NOTES_HINT'),
                hintStyle: steelMonoStyle(
                    fontSize: 12, color: SteelOpsColors.inkDim),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide:
                      const BorderSide(color: SteelOpsColors.borderStrong),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: SteelOpsColors.forge),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (session.errorMessage != null) ...[
              Text(
                session.errorMessage!,
                style: steelMonoStyle(
                    fontSize: 11, color: SteelOpsColors.rust),
              ),
              const SizedBox(height: 12),
            ],

            SteelForgeButton(
              label: t('session.COMPLETE_SESSION'),
              isLoading: session.isSaving,
              onPressed: session.isSaving ? null : _submit,
            ),
            const SizedBox(height: 8),
            SteelGhostButton(
              label: t('session.CANCEL_BTN'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _NumField extends StatelessWidget {
  const _NumField({
    required this.label,
    required this.controller,
    required this.digits,
  });

  final String label;
  final TextEditingController controller;

  /// true  → allow decimals (weight / rpe)
  /// false → integers only (reps)
  final bool digits;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  steelMonoStyle(fontSize: 8, color: SteelOpsColors.muted)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: digits),
            inputFormatters: digits
                ? [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*')),
                  ]
                : [FilteringTextInputFormatter.digitsOnly],
            style:
                steelMonoStyle(fontSize: 12, color: SteelOpsColors.inkHigh),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide:
                    const BorderSide(color: SteelOpsColors.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide:
                    const BorderSide(color: SteelOpsColors.forge),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SteelOpsColors.blood.withAlpha(40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: SteelOpsColors.rust, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  steelMonoStyle(fontSize: 11, color: SteelOpsColors.rust),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close,
                color: SteelOpsColors.muted, size: 16),
          ),
        ],
      ),
    );
  }
}
