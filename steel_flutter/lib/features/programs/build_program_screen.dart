// lib/features/programs/build_program_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';

// Stable English day labels — also persisted to the DB `label`/`focus` fields.
const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

// Localization keys for each day label (display only).
const _dayLabelKeys = [
  'build.DAY_MON',
  'build.DAY_TUE',
  'build.DAY_WED',
  'build.DAY_THU',
  'build.DAY_FRI',
  'build.DAY_SAT',
  'build.DAY_SUN',
];

// (dbValue, localizationKey) — first is the stable DB key, second is display.
const _goalOptions = [
  ('muscle_building', 'build.GOAL_HYPERTROPHY'),
  ('strength', 'build.GOAL_STRENGTH'),
  ('fat_loss', 'build.GOAL_FAT_LOSS'),
  ('endurance', 'build.GOAL_ENDURANCE'),
];

const _environmentOptions = [
  ('gym', 'build.ENV_GYM'),
  ('home', 'build.ENV_HOME'),
  ('outdoor', 'build.ENV_OUTDOOR'),
];

class BuildProgramScreen extends ConsumerStatefulWidget {
  const BuildProgramScreen({super.key});

  @override
  ConsumerState<BuildProgramScreen> createState() =>
      _BuildProgramScreenState();
}

class _BuildProgramScreenState extends ConsumerState<BuildProgramScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _currentStep = 0; // 0=name, 1=days, 2=exercises
  bool _saving = false;

  String _goalType = 'muscle_building';
  String _environment = 'gym';
  int _durationWeeks = 4;

  // day index (0=Mon … 6=Sun) → list of exercises
  final Map<int, List<String>> _dayExercises = {};
  final Set<int> _activeDays = {};
  int _selectedDayIndex = 0;
  String _searchQuery = '';

  // Rank for the exercise picker: lower = shown first. Matches on the English
  // OR localized name, prefers prefix/word-start matches, and within that
  // prefers SIMPLE exercises (fewer words / shorter names) so the basic
  // compounds (Bench Press, Pull Up, Lat Pulldown) rank above obscure
  // variations ("precision style lever bent-over row …").
  double _exerciseScore(
      ({String id, String englishName, String displayName}) e, String q) {
    final n = e.englishName.toLowerCase();
    final d = e.displayName.toLowerCase();
    final words = n.split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty).length;
    double rel;
    if (q.isEmpty) {
      rel = 0;
    } else if (n == q || d == q) {
      rel = -1000;
    } else if (n.startsWith(q) || d.startsWith(q)) {
      rel = 0;
    } else if (n.split(RegExp(r'\s+')).any((w) => w.startsWith(q)) ||
        d.split(RegExp(r'\s+')).any((w) => w.startsWith(q))) {
      rel = 100;
    } else {
      rel = 200;
    }
    return rel + words * 8.0 + n.length * 0.2;
  }

  void _toggleDay(int i) {
    setState(() {
      if (_activeDays.contains(i)) {
        _activeDays.remove(i);
        _dayExercises.remove(i);
      } else {
        _activeDays.add(i);
        _dayExercises[i] = [];
      }
    });
  }

  void _toggleExercise(String ex) {
    final list = List<String>.from(_dayExercises[_selectedDayIndex] ?? []);
    setState(() {
      if (list.contains(ex)) {
        list.remove(ex);
      } else {
        list.add(ex);
      }
      _dayExercises[_selectedDayIndex] = list;
    });
  }

  Future<void> _saveProgram() async {
    final t = ref.read(tProvider);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.rust,
          content: Text(t('build.NAME_REQUIRED'),
              style: steelMonoStyle(fontSize: 11, color: Colors.white)),
        ),
      );
      return;
    }

    final days = _activeDays.toList()
      ..sort();
    final dayPayload = days.map((dayIndex) {
      final exercises = (_dayExercises[dayIndex] ?? [])
          .map(
            (name) => <String, dynamic>{
              'name': name,
              'sets': 3,
              'repsMin': 8,
              'repsMax': 12,
              'rpeTarget': 8,
              'restSeconds': 90,
              'notes': '',
            },
          )
          .toList();
      return <String, dynamic>{
        'dayOfWeek': dayIndex + 1, // 1=Mon … 7=Sun
        'label': _dayLabels[dayIndex],
        'focus': exercises.isNotEmpty
            ? <String>[_dayLabels[dayIndex]]
            : <String>[],
        'exercises': exercises,
      };
    }).toList();

    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).createManualPlan(
            title: name,
            description: _descController.text.trim(),
            goalType: _goalType,
            environment: _environment,
            durationWeeks: _durationWeeks,
            days: dayPayload,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.surface,
          content: Text(
            t('build.PROGRAM_SAVED').replaceAll('{title}', name.toUpperCase()),
            style: steelMonoStyle(fontSize: 11, color: Colors.white),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.rust,
          content: Text('${t('programs.ERROR_PREFIX')}: $e',
              style: steelMonoStyle(fontSize: 11, color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: AppBar(
        backgroundColor: SteelOpsColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t('build.TITLE'), style: steelHeadingStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Container(height: 3, color: SteelOpsColors.orange),

          // ── Step indicator ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: List.generate(3, (i) {
                final labels = [
                  t('build.STEP_NAME'),
                  t('build.STEP_DAYS'),
                  t('build.STEP_EXERCISES'),
                ];
                final active = i == _currentStep;
                final done = i < _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: done || active
                              ? SteelOpsColors.orange
                              : Colors.transparent,
                          border: Border.all(
                            color: done || active
                                ? SteelOpsColors.orange
                                : SteelOpsColors.borderStrong,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : Text(
                                  '${i + 1}',
                                  style: steelMonoStyle(
                                    fontSize: 11,
                                    color: active
                                        ? Colors.white
                                        : SteelOpsColors.muted,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        labels[i],
                        style: steelMonoStyle(
                          fontSize: 10,
                          color: active ? Colors.white : SteelOpsColors.muted,
                        ),
                      ),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: SteelOpsColors.border,
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                );
              }),
            ),
          ),

          Expanded(child: _buildStep()),

          // ── Bottom navigation ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: _saving
                          ? null
                          : () => setState(() => _currentStep--),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: SteelOpsColors.borderStrong),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t('build.BACK'),
                          textAlign: TextAlign.center,
                          style: steelMonoStyle(
                            fontSize: 12,
                            color: SteelOpsColors.inkMid,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _saving
                        ? null
                        : () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _saveProgram();
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: SteelOpsColors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _saving && _currentStep == 2
                          ? const Center(
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _currentStep < 2
                                  ? t('build.NEXT')
                                  : t('build.SAVE_PROGRAM'),
                              textAlign: TextAlign.center,
                              style: steelMonoStyle(
                                fontSize: 12,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildDaysStep();
      case 2:
        return _buildExercisesStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildNameStep() {
    final t = ref.watch(tProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program name
          Text(
            t('build.PROGRAM_NAME'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: steelHeadingStyle(fontSize: 22),
            cursorColor: SteelOpsColors.orange,
            decoration: InputDecoration(
              hintText: t('build.NAME_HINT'),
              hintStyle:
                  steelHeadingStyle(fontSize: 22, color: SteelOpsColors.muted),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: SteelOpsColors.border),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: SteelOpsColors.orange, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Description (optional)
          Text(
            t('build.DESCRIPTION_OPTIONAL'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            style: steelMonoStyle(fontSize: 12, color: Colors.white),
            cursorColor: SteelOpsColors.orange,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: t('build.DESCRIPTION_HINT'),
              hintStyle: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.muted),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: SteelOpsColors.border),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: SteelOpsColors.orange, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Goal type
          Text(
            t('build.GOAL'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goalOptions.map((opt) {
              final selected = _goalType == opt.$1;
              return GestureDetector(
                onTap: () => setState(() => _goalType = opt.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? SteelOpsColors.orange
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? SteelOpsColors.orange
                          : SteelOpsColors.borderStrong,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    t(opt.$2),
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: selected
                          ? Colors.white
                          : SteelOpsColors.inkMid,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Environment
          Text(
            t('build.ENVIRONMENT'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _environmentOptions.map((opt) {
              final selected = _environment == opt.$1;
              return GestureDetector(
                onTap: () => setState(() => _environment = opt.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? SteelOpsColors.orange
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? SteelOpsColors.orange
                          : SteelOpsColors.borderStrong,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    t(opt.$2),
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: selected
                          ? Colors.white
                          : SteelOpsColors.inkMid,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Duration weeks
          Text(
            t('build.DURATION').replaceAll('{n}', '$_durationWeeks'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SteelOpsColors.orange,
              inactiveTrackColor: SteelOpsColors.border,
              thumbColor: SteelOpsColors.orange,
              overlayColor: SteelOpsColors.forgeGlow,
              trackHeight: 2,
            ),
            child: Slider(
              value: _durationWeeks.toDouble(),
              min: 1,
              max: 16,
              divisions: 15,
              onChanged: (v) => setState(() => _durationWeeks = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('build.ONE_WEEK'),
                  style: steelMonoStyle(
                      fontSize: 9, color: SteelOpsColors.muted)),
              Text(t('build.SIXTEEN_WEEKS'),
                  style: steelMonoStyle(
                      fontSize: 9, color: SteelOpsColors.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysStep() {
    final t = ref.watch(tProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('build.SELECT_TRAINING_DAYS'),
            style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (i) {
              final active = _activeDays.contains(i);
              return Expanded(
                child: GestureDetector(
                  onTap: () => _toggleDay(i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active
                          ? SteelOpsColors.orange
                          : SteelOpsColors.surface,
                      border: Border.all(
                        color: active
                            ? SteelOpsColors.orange
                            : SteelOpsColors.border,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t(_dayLabelKeys[i]),
                      textAlign: TextAlign.center,
                      style: steelMonoStyle(
                        fontSize: 9,
                        color: active ? Colors.white : SteelOpsColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            t('build.DAYS_SELECTED').replaceAll('{n}', '${_activeDays.length}'),
            style:
                steelMonoStyle(fontSize: 12, color: SteelOpsColors.inkMid),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesStep() {
    final t = ref.watch(tProvider);
    final sortedDays = _activeDays.toList()..sort();
    return Column(
      children: [
        // ── Day selector ─────────────────────────────────────
        if (sortedDays.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: sortedDays.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final dayI = sortedDays[i];
                final sel = _selectedDayIndex == dayI;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = dayI),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? SteelOpsColors.orange : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: sel
                              ? SteelOpsColors.orange
                              : SteelOpsColors.borderStrong,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      t(_dayLabelKeys[dayI]),
                      style: steelMonoStyle(
                        fontSize: 11,
                        color: sel ? Colors.white : SteelOpsColors.inkMid,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        Container(height: 1, color: SteelOpsColors.border),
        const SizedBox(height: 8),

        // ── Search ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: steelMonoStyle(fontSize: 12, color: Colors.white),
            cursorColor: SteelOpsColors.orange,
            decoration: InputDecoration(
              hintText: t('build.SEARCH_EXERCISES'),
              hintStyle: steelMonoStyle(
                  fontSize: 12, color: SteelOpsColors.muted),
              prefixIcon: Icon(Icons.search,
                  color: SteelOpsColors.muted, size: 18),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: SteelOpsColors.border),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: SteelOpsColors.orange, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Exercise count for selected day ──────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            t('build.EXERCISES_SELECTED_FOR')
                .replaceAll(
                    '{n}', '${(_dayExercises[_selectedDayIndex] ?? []).length}')
                .replaceAll(
                    '{day}',
                    _selectedDayIndex < 7
                        ? t(_dayLabelKeys[_selectedDayIndex])
                        : t('build.THIS_DAY')),
            style:
                steelMonoStyle(fontSize: 9, color: SteelOpsColors.muted),
          ),
        ),

        // ── Exercise list (full catalog · localized · ranked) ──
        Expanded(
          child: Builder(builder: (context) {
            final entriesAsync = ref.watch(exercisePickerEntriesProvider);
            return entriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: SteelOpsColors.orange, strokeWidth: 2),
              ),
              error: (e, _) => Center(
                child: Text(t('library.NO_RESULTS'),
                    style: steelMonoStyle(
                        fontSize: 11, color: SteelOpsColors.muted)),
              ),
              data: (all) {
                final q = _searchQuery.trim().toLowerCase();
                final list = (q.isEmpty
                    ? List.of(all)
                    : all
                        .where((e) =>
                            e.displayName.toLowerCase().contains(q) ||
                            e.englishName.toLowerCase().contains(q))
                        .toList())
                  ..sort((a, b) =>
                      _exerciseScore(a, q).compareTo(_exerciseScore(b, q)));
                if (list.isEmpty) {
                  return Center(
                    child: Text(t('library.NO_RESULTS'),
                        style: steelMonoStyle(
                            fontSize: 11, color: SteelOpsColors.muted)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final entry = list[i];
                    final selected = (_dayExercises[_selectedDayIndex] ?? [])
                        .contains(entry.englishName);
                    return GestureDetector(
                      onTap: () => _toggleExercise(entry.englishName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: SteelOpsColors.border),
                          ),
                          color: selected
                              ? SteelOpsColors.surface
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.displayName,
                                style: steelMonoStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : SteelOpsColors.inkMid,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check,
                                  color: SteelOpsColors.orange, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
