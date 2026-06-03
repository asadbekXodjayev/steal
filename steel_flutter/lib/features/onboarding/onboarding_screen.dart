// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel/l10n/app_localizations.dart';

import '../../data/providers.dart';
import '../../shared/ops_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.onComplete});
  final VoidCallback? onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0-3

  // Step 1 - Stats
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '75');
  String _gender = 'Male';
  String _experience = 'BEGINNER';

  // Step 2 - Injuries
  final _injuryNotesController = TextEditingController();
  final List<String> _injuries = [];

  // Step 3 - Mission
  String _mission = 'BUILD MUSCLE';
  double _daysPerWeek = 4;
  double _sessionLength = 45;

  // Step 4 - Arena
  String _arena = 'GYM';
  final Set<String> _gear = {'Bodyweight'};

  bool _saving = false;

  // Maps UI labels to PocketBase field values.
  static const _missionToGoalType = <String, String>{
    'BUILD MUSCLE': 'muscle_building',
    'GET STRONGER': 'strength',
    'LOSE FAT': 'fat_loss',
    'BUILD ENDURANCE': 'endurance',
    'REHAB & RECOVERY': 'rehab',
  };

  static const _arenaToEnvironment = <String, String>{
    'GYM': 'gym',
    'HOME': 'home',
    'OUTDOOR': 'outdoor',
    'MIXED': 'mixed',
  };

  static const _experienceToLevel = <String, String>{
    'BEGINNER': 'beginner',
    'INTERMEDIATE': 'intermediate',
    'ADVANCED': 'advanced',
    'ELITE': 'elite',
  };

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _injuryNotesController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final injuryText = [
        ..._injuries,
        if (_injuryNotesController.text.trim().isNotEmpty)
          _injuryNotesController.text.trim(),
      ].join('; ');

      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final height = double.tryParse(_heightController.text.trim()) ?? 0;
      final weight = double.tryParse(_weightController.text.trim()) ?? 0;
      final goalType = _missionToGoalType[_mission] ?? 'muscle_building';
      final environment = _arenaToEnvironment[_arena] ?? 'gym';
      final fitnessLevel = _experienceToLevel[_experience] ?? 'beginner';

      await ref.read(repositoryProvider).saveProfile({
        'age': age,
        'height': height,
        'weight': weight,
        'gender': _gender.toLowerCase(),
        'fitnessLevel': fitnessLevel,
        'goalType': goalType,
        'environment': environment,
        'injuryHistory': injuryText,
      });

      ref.invalidate(profileProvider);
      widget.onComplete?.call();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.blood,
            content: Text(
              '${tr(ref, 'onboarding.SETUP_FAILED')}: $e',
              style: steelMonoStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
    final steps = [
      t('onboarding.STEPS.STATS'),
      t('onboarding.STEPS.INJURIES'),
      t('onboarding.STEPS.MISSION'),
      t('onboarding.STEPS.ARENA'),
    ];

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                children: [
                  Text(
                    'STEEL',
                    style: steelHeadingStyle(
                      fontSize: 18,
                      color: SteelOpsColors.orange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: SteelOpsColors.borderStrong,
                  ),
                  Text(
                    t('onboarding.BRAND'),
                    style: steelMonoStyle(
                      fontSize: 11,
                      color: SteelOpsColors.inkMid,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onComplete,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: SteelOpsColors.borderStrong),
                      ),
                      child: Center(
                        child: Text(
                          'X',
                          style: steelMonoStyle(
                            fontSize: 12,
                            color: SteelOpsColors.inkMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('onboarding.STEP_OF')
                            .replaceFirst('{current}', '${_step + 1}')
                            .replaceFirst('{total}', '4'),
                        style: steelMonoStyle(
                          fontSize: 11,
                          color: SteelOpsColors.muted,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        steps[_step],
                        style: steelMonoStyle(
                          fontSize: 11,
                          color: SteelOpsColors.orange,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(height: 2, color: SteelOpsColors.border),
                      FractionallySizedBox(
                        widthFactor: (_step + 1) / 4,
                        child: Container(
                          height: 2,
                          color: SteelOpsColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ][_step],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: _NavButton(
                        label: t('onboarding.BACK'),
                        icon: Icons.arrow_back,
                        filled: false,
                        onTap: _saving ? () {} : _back,
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _saving
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: SteelOpsColors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : _NavButton(
                            label: _step == 3
                                ? t('onboarding.FINISH')
                                : t('onboarding.NEXT'),
                            icon: _step == 3 ? Icons.check : Icons.arrow_forward,
                            filled: true,
                            onTap: _next,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Your Stats ──────────────────────────────────────────────────────
  Widget _buildStep1() {
    // (canonical key, localized label, localized description)
    final levels = [
      ('BEGINNER', tr(ref, 'onboarding.EXPERIENCE.BEGINNER'),
          tr(ref, 'onboarding.EXPERIENCE.BEGINNER_DESC')),
      ('INTERMEDIATE', tr(ref, 'onboarding.EXPERIENCE.INTERMEDIATE'),
          tr(ref, 'onboarding.EXPERIENCE.INTERMEDIATE_DESC')),
      ('ADVANCED', tr(ref, 'onboarding.EXPERIENCE.ADVANCED'),
          tr(ref, 'onboarding.EXPERIENCE.ADVANCED_DESC')),
      ('ELITE', tr(ref, 'onboarding.EXPERIENCE.ELITE'),
          tr(ref, 'onboarding.EXPERIENCE.ELITE_DESC')),
    ];

    // (canonical gender value, localized label)
    final genders = [
      ('Male', tr(ref, 'onboarding.GENDER.MALE')),
      ('Female', tr(ref, 'onboarding.GENDER.FEMALE')),
      ('Other', tr(ref, 'onboarding.GENDER.OTHER')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'onboarding.STATS.TITLE'),
          style: steelHeadingStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          tr(ref, 'onboarding.STATS.SUBTITLE'),
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 28),

        _fieldLabel(tr(ref, 'onboarding.STATS.AGE')),
        const SizedBox(height: 6),
        _DarkField(
          controller: _ageController,
          hint: '25',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 18),

        _fieldLabel(tr(ref, 'onboarding.STATS.GENDER')),
        const SizedBox(height: 6),
        _DropdownField(
          value: _gender,
          items: genders,
          onChanged: (v) => setState(() => _gender = v!),
        ),
        const SizedBox(height: 18),

        _fieldLabel(tr(ref, 'onboarding.STATS.HEIGHT')),
        const SizedBox(height: 6),
        _DarkField(
          controller: _heightController,
          hint: '175',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 18),

        _fieldLabel(tr(ref, 'onboarding.STATS.WEIGHT')),
        const SizedBox(height: 6),
        _DarkField(
          controller: _weightController,
          hint: '75',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 28),

        _fieldLabel(tr(ref, 'onboarding.STATS.EXPERIENCE')),
        const SizedBox(height: 4),
        Text(
          tr(ref, 'onboarding.STATS.EXPERIENCE_HINT'),
          style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 12),

        ...levels.map((l) {
          final selected = _experience == l.$1;
          return GestureDetector(
            onTap: () => setState(() => _experience = l.$1),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? SteelOpsColors.surface : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? SteelOpsColors.orange
                      : SteelOpsColors.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.$2,
                    style: steelHeadingStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? SteelOpsColors.heroText
                          : SteelOpsColors.inkMid,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.$3,
                    style: steelMonoStyle(
                      fontSize: 11,
                      color: SteelOpsColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Step 2: Injuries ────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'onboarding.INJURIES.TITLE'),
          style: steelHeadingStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          tr(ref, 'onboarding.INJURIES.SUBTITLE'),
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 28),

        GestureDetector(
          onTap: () => _showAddInjuryDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: SteelOpsColors.borderStrong),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: SteelOpsColors.inkMid, size: 16),
                const SizedBox(width: 8),
                Text(
                  tr(ref, 'onboarding.INJURIES.ADD'),
                  style: steelMonoStyle(
                    fontSize: 12,
                    color: SteelOpsColors.inkMid,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_injuries.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._injuries.map(
            (inj) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SteelOpsColors.surface,
                border: Border.all(color: SteelOpsColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      inj,
                      style: steelMonoStyle(
                        fontSize: 12,
                        color: SteelOpsColors.inkMid,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _injuries.remove(inj)),
                    child: Icon(
                      Icons.close,
                      color: SteelOpsColors.muted,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        _fieldLabel(tr(ref, 'onboarding.INJURIES.NOTES_LABEL')),
        const SizedBox(height: 8),
        TextField(
          controller: _injuryNotesController,
          maxLines: 4,
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.inkHigh),
          decoration: InputDecoration(
            hintText: tr(ref, 'onboarding.INJURIES.NOTES_HINT'),
            hintStyle: steelMonoStyle(
              fontSize: 12,
              color: SteelOpsColors.inkDim,
            ),
            filled: true,
            fillColor: SteelOpsColors.surfaceElevated,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: SteelOpsColors.borderStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: SteelOpsColors.borderStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: SteelOpsColors.orange, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddInjuryDialog() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteelOpsColors.surface,
        title: Text(
          tr(ref, 'onboarding.INJURIES.ADD'),
          style: steelHeadingStyle(fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.inkHigh),
          decoration: InputDecoration(
            hintText: tr(ref, 'onboarding.INJURIES.DIALOG_HINT'),
            hintStyle: steelMonoStyle(
              fontSize: 12,
              color: SteelOpsColors.inkDim,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr(ref, 'common.CANCEL'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
            ),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _injuries.add(ctrl.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: Text(
              tr(ref, 'onboarding.INJURIES.ADD_CONFIRM'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.orange),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Mission ─────────────────────────────────────────────────────────
  Widget _buildStep3() {
    // (icon, canonical key, localized label, localized description)
    final missions = [
      (Icons.bolt, 'BUILD MUSCLE', tr(ref, 'onboarding.MISSION.BUILD_MUSCLE'),
          tr(ref, 'onboarding.MISSION.BUILD_MUSCLE_DESC')),
      (Icons.show_chart, 'GET STRONGER', tr(ref, 'onboarding.MISSION.GET_STRONGER'),
          tr(ref, 'onboarding.MISSION.GET_STRONGER_DESC')),
      (Icons.local_fire_department, 'LOSE FAT', tr(ref, 'onboarding.MISSION.LOSE_FAT'),
          tr(ref, 'onboarding.MISSION.LOSE_FAT_DESC')),
      (Icons.favorite_border, 'BUILD ENDURANCE',
          tr(ref, 'onboarding.MISSION.BUILD_ENDURANCE'),
          tr(ref, 'onboarding.MISSION.BUILD_ENDURANCE_DESC')),
      (Icons.track_changes, 'REHAB & RECOVERY', tr(ref, 'onboarding.MISSION.REHAB'),
          tr(ref, 'onboarding.MISSION.REHAB_DESC')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'onboarding.MISSION.TITLE'),
          style: steelHeadingStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          tr(ref, 'onboarding.MISSION.SUBTITLE'),
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 28),

        ...missions.map((m) {
          final selected = _mission == m.$2;
          return GestureDetector(
            onTap: () => setState(() => _mission = m.$2),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? SteelOpsColors.surface : Colors.transparent,
                border: Border.all(
                  color: selected ? SteelOpsColors.orange : SteelOpsColors.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    m.$1,
                    color: selected ? SteelOpsColors.orange : SteelOpsColors.muted,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.$3,
                          style: steelHeadingStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? SteelOpsColors.heroText
                                : SteelOpsColors.inkMid,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.$4,
                          style: steelMonoStyle(
                            fontSize: 11,
                            color: SteelOpsColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),

        Row(
          children: [
            Text(
              tr(ref, 'onboarding.MISSION.DAYS_PER_WEEK'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
            ),
            Text(
              '${_daysPerWeek.round()}',
              style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.heroText,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: SteelOpsColors.orange,
            inactiveTrackColor: SteelOpsColors.border,
            thumbColor: Colors.white,
            overlayColor: SteelOpsColors.forgeGlow,
            trackHeight: 3,
          ),
          child: Slider(
            value: _daysPerWeek,
            min: 2,
            max: 7,
            divisions: 5,
            onChanged: (v) => setState(() => _daysPerWeek = v),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              tr(ref, 'onboarding.MISSION.SESSION_LENGTH'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
            ),
            Text(
              '${_sessionLength.round()} ${tr(ref, 'onboarding.MISSION.MIN')}',
              style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.heroText,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: SteelOpsColors.orange,
            inactiveTrackColor: SteelOpsColors.border,
            thumbColor: Colors.white,
            overlayColor: SteelOpsColors.forgeGlow,
            trackHeight: 3,
          ),
          child: Slider(
            value: _sessionLength,
            min: 20,
            max: 120,
            divisions: 10,
            onChanged: (v) => setState(() => _sessionLength = v),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Step 4: Arena ───────────────────────────────────────────────────────────
  Widget _buildStep4() {
    // (icon, canonical key, localized label, localized description)
    final arenas = [
      (Icons.fitness_center, 'GYM', tr(ref, 'onboarding.ARENA.GYM'),
          tr(ref, 'onboarding.ARENA.GYM_DESC')),
      (Icons.home_outlined, 'HOME', tr(ref, 'onboarding.ARENA.HOME'),
          tr(ref, 'onboarding.ARENA.HOME_DESC')),
      (Icons.park_outlined, 'OUTDOOR', tr(ref, 'onboarding.ARENA.OUTDOOR'),
          tr(ref, 'onboarding.ARENA.OUTDOOR_DESC')),
      (Icons.shuffle, 'MIXED', tr(ref, 'onboarding.ARENA.MIXED'),
          tr(ref, 'onboarding.ARENA.MIXED_DESC')),
    ];

    const gearItems = [
      'Bodyweight', 'Dumbbells', 'Barbell', 'Kettlebell',
      'Resistance Bands', 'Pull-up Bar', 'Bench', 'Squat Rack',
      'Cable Machine', 'Gym Machines', 'Dip Bars', 'Foam Roller',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'onboarding.ARENA.TITLE'),
          style: steelHeadingStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          tr(ref, 'onboarding.ARENA.SUBTITLE'),
          style: steelMonoStyle(fontSize: 12, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 28),

        ...arenas.map((a) {
          final selected = _arena == a.$2;
          return GestureDetector(
            onTap: () => setState(() => _arena = a.$2),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? SteelOpsColors.surface : Colors.transparent,
                border: Border.all(
                  color: selected ? SteelOpsColors.orange : SteelOpsColors.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    a.$1,
                    color: selected ? SteelOpsColors.orange : SteelOpsColors.muted,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.$3,
                          style: steelHeadingStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? SteelOpsColors.heroText
                                : SteelOpsColors.inkMid,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.$4,
                          style: steelMonoStyle(
                            fontSize: 11,
                            color: SteelOpsColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
        _fieldLabel(tr(ref, 'onboarding.ARENA.GEAR_LABEL')),
        const SizedBox(height: 4),
        Text(
          tr(ref, 'onboarding.ARENA.GEAR_HINT'),
          style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 4,
          children: gearItems.map((item) {
            final selected = _gear.contains(item);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _gear.remove(item);
                } else {
                  _gear.add(item);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? SteelOpsColors.surface : Colors.transparent,
                  border: Border.all(
                    color: selected ? SteelOpsColors.orange : SteelOpsColors.border,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  tr(ref, 'onboarding.EQUIPMENT.$item'),
                  style: steelMonoStyle(
                    fontSize: 11,
                    color: selected ? SteelOpsColors.inkHigh : SteelOpsColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: steelMonoStyle(
      fontSize: 11,
      color: SteelOpsColors.muted,
      letterSpacing: 2,
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: steelMonoStyle(fontSize: 13, color: SteelOpsColors.inkHigh),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: steelMonoStyle(fontSize: 13, color: SteelOpsColors.inkDim),
        filled: true,
        fillColor: SteelOpsColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: SteelOpsColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: SteelOpsColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: SteelOpsColors.orange, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;

  /// (canonical value, localized label) pairs.
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border.all(color: SteelOpsColors.borderStrong),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: SteelOpsColors.surface,
          icon: Icon(Icons.keyboard_arrow_down, color: SteelOpsColors.muted),
          style: steelMonoStyle(fontSize: 13, color: SteelOpsColors.inkHigh),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e.$1,
                  child: Text(
                    e.$2,
                    style: steelMonoStyle(
                      fontSize: 13,
                      color: SteelOpsColors.inkHigh,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? SteelOpsColors.orange : Colors.transparent,
          border: Border.all(
            color: filled ? SteelOpsColors.orange : SteelOpsColors.borderStrong,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!filled) ...[
              Icon(icon, color: SteelOpsColors.inkMid, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: steelMonoStyle(
                fontSize: 12,
                color: filled ? Colors.white : SteelOpsColors.inkMid,
                letterSpacing: 1.5,
              ),
            ),
            if (filled) ...[
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
