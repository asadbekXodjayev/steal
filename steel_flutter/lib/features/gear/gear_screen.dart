import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:steel/l10n/app_localizations.dart';

import '../../core/legal_links.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../auth/auth_provider.dart';
import '../stats/stats_screen.dart';

class GearScreen extends ConsumerStatefulWidget {
  const GearScreen({super.key});

  @override
  ConsumerState<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends ConsumerState<GearScreen> {
  // Profile form controllers.
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _injuryController = TextEditingController();

  String _gender = 'male';
  String _fitnessLevel = 'beginner';
  String _goalType = 'muscle_building';
  String _environment = 'gym';

  bool _formInitialised = false;
  bool _saving = false;
  bool _deleting = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {/* version row falls back to em dash */}
  }

  static const _genders = ['male', 'female', 'other'];
  static const _fitnessLevels = ['beginner', 'intermediate', 'advanced', 'elite'];
  static const _goalTypes = [
    'muscle_building',
    'strength',
    'fat_loss',
    'endurance',
    'rehab',
  ];
  static const _environments = ['gym', 'home', 'outdoor', 'mixed'];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _injuryController.dispose();
    super.dispose();
  }

  /// Populate controllers once profile loads (only on first load).
  void _initForm(dynamic profile) {
    if (_formInitialised) return;
    _formInitialised = true;
    if (profile == null) return;
    _ageController.text =
        profile.age > 0 ? '${profile.age}' : '';
    _heightController.text =
        profile.height > 0 ? '${profile.height.toStringAsFixed(0)}' : '';
    _weightController.text =
        profile.weight > 0 ? '${profile.weight.toStringAsFixed(1)}' : '';
    _injuryController.text = profile.injuryHistory;
    final g = profile.gender.toLowerCase();
    if (_genders.contains(g)) _gender = g;
    final fl = profile.fitnessLevel.toLowerCase();
    if (_fitnessLevels.contains(fl)) _fitnessLevel = fl;
    final gt = profile.goalType.toLowerCase();
    if (_goalTypes.contains(gt)) _goalType = gt;
    final env = profile.environment.toLowerCase();
    if (_environments.contains(env)) _environment = env;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final height = double.tryParse(_heightController.text.trim()) ?? 0;
      final weight = double.tryParse(_weightController.text.trim()) ?? 0;

      await ref.read(repositoryProvider).saveProfile({
        'age': age,
        'height': height,
        'weight': weight,
        'gender': _gender,
        'fitnessLevel': _fitnessLevel,
        'goalType': _goalType,
        'environment': _environment,
        'injuryHistory': _injuryController.text.trim(),
      });

      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.tactical,
            content: Text(
              tr(ref, 'gear.PROFILE_SAVED'),
              style: steelMonoStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.blood,
            content: Text(
              '${tr(ref, 'gear.SAVE_FAILED')}: $e',
              style: steelMonoStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final profileAsync = ref.watch(profileProvider);
    final language = ref.watch(languageProvider);
    final t = ref.watch(tProvider);
    final email = auth.email?.toUpperCase() ?? '';

    // Populate form fields once data arrives.
    profileAsync.whenData(_initForm);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Text(
                t('gear.TITLE'),
                style: steelHeadingStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              _redUnderline(),
              const SizedBox(height: 6),
              Text(
                email,
                style: steelMonoStyle(
                  fontSize: 13,
                  color: SteelOpsColors.muted,
                ),
              ),
              const SizedBox(height: 24),

              // ── Profile card ─────────────────────────────────────────────
              _SectionCard(
                child: profileAsync.when(
                  loading: () => _profileFormSkeleton(),
                  error: (e, _) => Text(
                    '${t('gear.PROFILE_LOAD_ERROR')}: $e',
                    style: steelMonoStyle(
                      fontSize: 13,
                      color: SteelOpsColors.muted,
                    ),
                  ),
                  data: (_) => _profileForm(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Performance (Stats merged into the profile tab) ──────────
              const StatsContent(),
              const SizedBox(height: 16),

              // ── Language card ─────────────────────────────────────────────
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.translate,
                          color: SteelOpsColors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('settings.LANGUAGE'),
                          style: steelMonoStyle(
                            fontSize: 13,
                            color: SteelOpsColors.inkHigh,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('settings.LANGUAGE_DESC'),
                      style: steelMonoStyle(
                        fontSize: 13,
                        color: SteelOpsColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: kSupportedLanguages.map((lang) {
                        final selected = language == lang;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: selected
                                ? null
                                : () => setLanguage(ref, lang),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? SteelOpsColors.surfaceElevated
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? SteelOpsColors.orange
                                      : SteelOpsColors.borderStrong,
                                  width: selected ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang.toUpperCase(),
                                    style: steelMonoStyle(
                                      fontSize: 13,
                                      color: selected
                                          ? SteelOpsColors.orange
                                          : SteelOpsColors.inkDim,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    kLanguageNames[lang] ?? lang,
                                    style: steelMonoStyle(
                                      fontSize: 13,
                                      color: selected
                                          ? SteelOpsColors.inkHigh
                                          : SteelOpsColors.inkMid,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (selected)
                                    Icon(
                                      Icons.check,
                                      color: SteelOpsColors.orange,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Sign out ─────────────────────────────────────────────────
              _SectionCard(
                child: GestureDetector(
                  onTap: auth.isBusy
                      ? null
                      : () => ref.read(authProvider.notifier).logout(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: SteelOpsColors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t('gear.SIGN_OUT'),
                        style: steelMonoStyle(
                          fontSize: 13,
                          color: SteelOpsColors.orange,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── About / Legal ────────────────────────────────────────────
              _SectionCard(child: _aboutSection(t)),
              const SizedBox(height: 16),

              // ── Delete account (Play requirement) ────────────────────────
              _SectionCard(child: _deleteSection(t)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── About / Legal section ────────────────────────────────────────────────────

  Widget _aboutSection(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, color: SteelOpsColors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              t('legal.ABOUT'),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.inkHigh,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _LegalRow(
          icon: Icons.privacy_tip_outlined,
          label: t('legal.PRIVACY_POLICY'),
          onTap: () => _openUrl(LegalLinks.privacyPolicyUrl, t),
        ),
        _LegalRow(
          icon: Icons.description_outlined,
          label: t('legal.TERMS'),
          onTap: () => _openUrl(LegalLinks.termsOfUseUrl, t),
        ),
        _LegalRow(
          icon: Icons.mail_outline,
          label: t('legal.CONTACT'),
          onTap: () => _openUrl('mailto:${LegalLinks.supportEmail}', t),
        ),
        const SizedBox(height: 4),
        Divider(color: SteelOpsColors.border, height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              t('legal.VERSION').toUpperCase(),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              _appVersion.isEmpty ? '—' : _appVersion,
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.inkMid,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Delete account section ───────────────────────────────────────────────────

  Widget _deleteSection(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _deleting ? null : () => _confirmDelete(t),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_deleting)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SteelOpsColors.rust,
                  ),
                )
              else
                Icon(Icons.delete_forever, color: SteelOpsColors.rust, size: 16),
              const SizedBox(width: 8),
              Text(
                t('legal.DELETE_ACCOUNT'),
                style: steelMonoStyle(
                  fontSize: 13,
                  color: SteelOpsColors.rust,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t('legal.DATA_DELETE_NOTE')
              .replaceAll('{email}', LegalLinks.supportEmail)
              .replaceAll('{url}', LegalLinks.accountDeletionUrl),
          style: steelMonoStyle(
            fontSize: 13,
            color: SteelOpsColors.inkDim,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(String Function(String) t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteelOpsColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(
          t('legal.DELETE_CONFIRM_TITLE'),
          style: steelHeadingStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: SteelOpsColors.inkHigh,
          ),
        ),
        content: Text(
          t('legal.DELETE_CONFIRM_BODY'),
          style: steelMonoStyle(
            fontSize: 13,
            color: SteelOpsColors.inkMid,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t('common.CANCEL'),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t('legal.DELETE_CONFIRM_CTA'),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.rust,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    setState(() => _deleting = true);
    try {
      await ref.read(authProvider.notifier).deleteAccount();
      // Auth state flips to unauthenticated → router redirects automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.blood,
            content: Text(
              '${t('legal.DELETE_FAILED')}: $e',
              style: steelMonoStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _openUrl(String url, String Function(String) t) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.blood,
          content: Text(
            t('legal.OPEN_LINK_FAILED'),
            style: steelMonoStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    }
  }

  // ── Profile form (data loaded) ──────────────────────────────────────────────

  Widget _profileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: SteelOpsColors.orange,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              tr(ref, 'gear.PROFILE'),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.inkHigh,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _fieldLabel(tr(ref, 'gear.AGE')),
        const SizedBox(height: 6),
        _StyledTextField(
          controller: _ageController,
          hint: '25',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.HEIGHT')),
        const SizedBox(height: 6),
        _StyledTextField(
          controller: _heightController,
          hint: '175',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.WEIGHT')),
        const SizedBox(height: 6),
        _StyledTextField(
          controller: _weightController,
          hint: '75.0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.GENDER')),
        const SizedBox(height: 6),
        _ChipSelector(
          options: _genders,
          selected: _gender,
          onSelect: (v) => setState(() => _gender = v),
          labelBuilder: (v) => tr(ref, 'gear.GENDER_OPT.$v'),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.FITNESS_LEVEL')),
        const SizedBox(height: 6),
        _ChipSelector(
          options: _fitnessLevels,
          selected: _fitnessLevel,
          onSelect: (v) => setState(() => _fitnessLevel = v),
          labelBuilder: (v) => tr(ref, 'gear.FITNESS_OPT.$v'),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.GOAL')),
        const SizedBox(height: 6),
        _ChipSelector(
          options: _goalTypes,
          selected: _goalType,
          onSelect: (v) => setState(() => _goalType = v),
          labelBuilder: (v) => tr(ref, 'gear.GOAL_OPT.$v'),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.ENVIRONMENT')),
        const SizedBox(height: 6),
        _ChipSelector(
          options: _environments,
          selected: _environment,
          onSelect: (v) => setState(() => _environment = v),
          labelBuilder: (v) => tr(ref, 'gear.ENV_OPT.$v'),
        ),
        const SizedBox(height: 16),

        _fieldLabel(tr(ref, 'gear.INJURY_LABEL')),
        const SizedBox(height: 6),
        _StyledTextField(
          controller: _injuryController,
          hint: tr(ref, 'gear.INJURY_HINT'),
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: SteelOpsColors.orange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: SteelOpsColors.border,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    tr(ref, 'gear.SAVE_PROFILE'),
                    style: steelMonoStyle(
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _profileFormSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: SteelOpsColors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              tr(ref, 'gear.PROFILE'),
              style: steelMonoStyle(
                fontSize: 13,
                color: SteelOpsColors.inkHigh,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SteelOpsColors.orange,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _redUnderline() => Container(
    width: 48,
    height: 3,
    margin: const EdgeInsets.only(bottom: 8),
    color: SteelOpsColors.orange,
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: steelMonoStyle(
      fontSize: 13,
      color: SteelOpsColors.muted,
      letterSpacing: 2,
    ),
  );
}

// ── Chip selector ─────────────────────────────────────────────────────────────

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.labelBuilder,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? SteelOpsColors.surface : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? SteelOpsColors.orange
                    : SteelOpsColors.borderStrong,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              labelBuilder(opt),
              style: steelMonoStyle(
                fontSize: 13,
                color: isSelected ? SteelOpsColors.orange : SteelOpsColors.inkMid,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Legal / external-link row ─────────────────────────────────────────────────

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: SteelOpsColors.inkDim, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: steelMonoStyle(
                  fontSize: 13,
                  color: SteelOpsColors.inkMid,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: SteelOpsColors.inkDim,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

// ── Styled text field ─────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: steelMonoStyle(
        fontSize: 13,
        color: SteelOpsColors.inkHigh,
        letterSpacing: 1,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: steelMonoStyle(
          fontSize: 13,
          color: SteelOpsColors.inkDim,
          letterSpacing: 1,
        ),
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
