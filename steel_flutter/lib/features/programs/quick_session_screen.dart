// lib/features/programs/quick_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quick-pick exercise list
// ─────────────────────────────────────────────────────────────────────────────

const _quickExercises = [
  'Bench Press',
  'Squat',
  'Deadlift',
  'Overhead Press',
  'Barbell Row',
  'Pull-Up',
  'Dip',
  'Leg Press',
  'Romanian Deadlift',
  'Incline DB Press',
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Ad-hoc workout logger — no plan attached.
/// Constructor is kept as `const QuickSessionScreen({super.key})` for
/// backwards compatibility with existing navigation call sites.
class QuickSessionScreen extends ConsumerStatefulWidget {
  const QuickSessionScreen({super.key});

  @override
  ConsumerState<QuickSessionScreen> createState() =>
      _QuickSessionScreenState();
}

class _QuickSessionScreenState extends ConsumerState<QuickSessionScreen> {
  // ── session lifecycle ──────────────────────────────────────────────────
  String? _sessionId;
  bool _sessionStarted = false;
  bool _isSaving = false;
  String? _error;
  final _stopwatch = Stopwatch();

  // ── exercise + set data ────────────────────────────────────────────────
  final List<_ExerciseEntry> _exercises = [];

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _startSession() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(repositoryProvider)
          .startSession(); // no plan / planDay
      if (!mounted) return;
      setState(() {
        _sessionId = id;
        _sessionStarted = true;
        _isSaving = false;
        _stopwatch.start();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = e.toString();
      });
    }
  }

  void _addExercise(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final already = _exercises.any((e) => e.name == trimmed);
    if (already) return;
    setState(() => _exercises.add(_ExerciseEntry(name: trimmed)));
  }

  Future<void> _persistSet(_ExerciseEntry entry, _LoggedSet set) async {
    final id = _sessionId;
    if (id == null) return;
    try {
      await ref.read(repositoryProvider).logSet(
            session: id,
            exerciseName: entry.name,
            setNumber: set.setNumber,
            reps: set.reps,
            weight: set.weight,
            rpe: set.rpe,
          );
    } catch (_) {
      // Optimistic — failures are silent; the set is still visible in UI.
    }
  }

  void _finishSession() {
    _stopwatch.stop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SteelOpsColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => _QuickFinishSheet(
        exercises: _exercises,
        elapsed: _stopwatch.elapsed,
        onConfirm: (mood, energy, notes) =>
            _completeSession(mood, energy, notes),
      ),
    );
  }

  Future<void> _completeSession(
      String? mood, int energy, String? notes) async {
    final id = _sessionId;
    if (id == null) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(repositoryProvider).completeSession(
            id,
            mood: mood,
            energyLevel: energy,
            notes: notes,
          );
      // Refresh progress provider so stats screens pick up the new session.
      ref.invalidate(progressDataProvider);
      if (!mounted) return;
      Navigator.of(context).pop(); // close sheet
      Navigator.of(context).pop(); // leave screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SESSION LOGGED — STEEL FORGED.',
            style: steelMonoStyle(
                fontSize: 12, color: Colors.white, letterSpacing: 1.2),
          ),
          backgroundColor: SteelOpsColors.forge,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = e.toString();
      });
      Navigator.of(context).pop(); // close sheet even on error
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: AppBar(
        backgroundColor: SteelOpsColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('QUICK SESSION', style: steelHeadingStyle(fontSize: 18)),
        actions: [
          if (_sessionStarted && !_isSaving)
            TextButton(
              onPressed: _finishSession,
              child: Text(
                'FINISH',
                style: steelMonoStyle(
                    fontSize: 12, color: SteelOpsColors.orange),
              ),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SteelOpsColors.forge,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Forge accent stripe
          Container(height: 3, color: SteelOpsColors.orange),

          // Inline error banner
          if (_error != null)
            Container(
              width: double.infinity,
              color: SteelOpsColors.blood.withAlpha(40),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: SteelOpsColors.rust, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: steelMonoStyle(
                          fontSize: 11, color: SteelOpsColors.rust),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _error = null),
                    child: const Icon(Icons.close,
                        color: SteelOpsColors.muted, size: 16),
                  ),
                ],
              ),
            ),

          if (!_sessionStarted)
            Expanded(child: _StartPrompt(onStart: _startSession))
          else ...[
            // Exercise cards
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(
                      child: SteelEmptyState(
                        icon: Icons.add_circle_outline,
                        title: 'No exercises yet',
                        subtitle:
                            'Tap an exercise below to start logging sets.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _exercises.length,
                      itemBuilder: (_, i) => _QuickExerciseRow(
                        entry: _exercises[i],
                        onSetLogged: (set) =>
                            _persistSet(_exercises[i], set),
                      ),
                    ),
            ),

            // Quick-add bar
            _QuickAddBar(onAdd: _addExercise),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start prompt
// ─────────────────────────────────────────────────────────────────────────────

class _StartPrompt extends StatelessWidget {
  const _StartPrompt({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: SteelOpsColors.orange, size: 48),
            const SizedBox(height: 16),
            Text('READY TO TRAIN?', style: steelHeadingStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Start a freeform session and log\nexercises as you go.',
              textAlign: TextAlign.center,
              style: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.muted),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: SteelOpsColors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'START SESSION',
                  style: steelMonoStyle(
                    fontSize: 13,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add bar
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAddBar extends StatefulWidget {
  const _QuickAddBar({required this.onAdd});
  final ValueChanged<String> onAdd;

  @override
  State<_QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<_QuickAddBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SteelOpsColors.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADD EXERCISE',
            style: steelMonoStyle(
                fontSize: 9,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickExercises
                .map(
                  (ex) => GestureDetector(
                    onTap: () => widget.onAdd(ex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: SteelOpsColors.borderStrong),
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
// Per-exercise row with per-set logging
// ─────────────────────────────────────────────────────────────────────────────

class _LoggedSet {
  const _LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.rpe,
  });
  final int setNumber;
  final int reps;
  final double weight;
  final double rpe;
}

class _ExerciseEntry {
  _ExerciseEntry({required this.name});
  final String name;
  final List<_LoggedSet> loggedSets = [];
}

class _QuickExerciseRow extends StatefulWidget {
  const _QuickExerciseRow({
    required this.entry,
    required this.onSetLogged,
  });

  final _ExerciseEntry entry;
  final ValueChanged<_LoggedSet> onSetLogged;

  @override
  State<_QuickExerciseRow> createState() => _QuickExerciseRowState();
}

class _QuickExerciseRowState extends State<_QuickExerciseRow> {
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

    final set = _LoggedSet(
      setNumber: widget.entry.loggedSets.length + 1,
      reps: reps,
      weight: weight,
      rpe: rpe,
    );
    setState(() => widget.entry.loggedSets.add(set));
    widget.onSetLogged(set);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            entry.name.toUpperCase(),
            style: steelMonoStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w700),
          ),

          // Logged sets
          if (entry.loggedSets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...entry.loggedSets.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Text(
                      'SET ${s.setNumber}',
                      style: steelMonoStyle(
                          fontSize: 9, color: SteelOpsColors.forge),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${s.reps} reps  ·  '
                      '${s.weight.toStringAsFixed(s.weight % 1 == 0 ? 0 : 1)} kg  ·  '
                      'RPE ${s.rpe.toStringAsFixed(0)}',
                      style: steelMonoStyle(
                          fontSize: 10, color: SteelOpsColors.inkMid),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Input row
          Row(
            children: [
              _QuickNumField(
                  label: 'REPS',
                  controller: _repsCtrl,
                  decimal: false),
              const SizedBox(width: 8),
              _QuickNumField(
                  label: 'KG',
                  controller: _weightCtrl,
                  decimal: true),
              const SizedBox(width: 8),
              _QuickNumField(
                  label: 'RPE',
                  controller: _rpeCtrl,
                  decimal: true),
              const SizedBox(width: 10),
              SteelForgeButton(
                label: '+ SET',
                expanded: false,
                onPressed: _addSet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Finish sheet — mood / energy / notes
// ─────────────────────────────────────────────────────────────────────────────

class _QuickFinishSheet extends StatefulWidget {
  const _QuickFinishSheet({
    required this.exercises,
    required this.elapsed,
    required this.onConfirm,
  });

  final List<_ExerciseEntry> exercises;
  final Duration elapsed;
  final void Function(String? mood, int energy, String? notes) onConfirm;

  @override
  State<_QuickFinishSheet> createState() => _QuickFinishSheetState();
}

class _QuickFinishSheetState extends State<_QuickFinishSheet> {
  String? _mood;
  int _energy = 3;
  final _notesCtrl = TextEditingController();

  static const _moods = ['great', 'good', 'okay', 'tired', 'bad'];
  static const _moodLabels = ['GREAT', 'GOOD', 'OKAY', 'TIRED', 'BAD'];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final totalSets =
        widget.exercises.fold<int>(0, (acc, e) => acc + e.loggedSets.length);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SESSION COMPLETE', style: steelHeadingStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              '${widget.exercises.length} exercises · $totalSets sets · '
              '${widget.elapsed.inMinutes}m ${widget.elapsed.inSeconds % 60}s',
              style: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.inkMid),
            ),
            const SizedBox(height: 24),

            // Mood
            Text(
              'MOOD',
              style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.muted,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                      _moodLabels[i],
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

            // Energy
            Text(
              'ENERGY LEVEL  $_energy / 5',
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
              'NOTES (optional)',
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
                hintText: 'Any notes about today\'s session...',
                hintStyle: steelMonoStyle(
                    fontSize: 12, color: SteelOpsColors.inkDim),
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
            ),
            const SizedBox(height: 24),

            SteelForgeButton(
              label: 'SAVE SESSION',
              onPressed: () => widget.onConfirm(
                _mood,
                _energy,
                _notesCtrl.text.trim().isEmpty
                    ? null
                    : _notesCtrl.text.trim(),
              ),
            ),
            const SizedBox(height: 8),
            SteelGhostButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact numeric input
// ─────────────────────────────────────────────────────────────────────────────

class _QuickNumField extends StatelessWidget {
  const _QuickNumField({
    required this.label,
    required this.controller,
    required this.decimal,
  });

  final String label;
  final TextEditingController controller;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: steelMonoStyle(fontSize: 8, color: SteelOpsColors.muted),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType:
                TextInputType.numberWithOptions(decimal: decimal),
            inputFormatters: decimal
                ? [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*')),
                  ]
                : [FilteringTextInputFormatter.digitsOnly],
            style: steelMonoStyle(
                fontSize: 12, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: const BorderSide(
                    color: SteelOpsColors.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide:
                    const BorderSide(color: SteelOpsColors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
