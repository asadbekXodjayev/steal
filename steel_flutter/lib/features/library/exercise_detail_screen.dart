import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:steel/l10n/app_localizations.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';

/// Full-page exercise detail — mirrors the web `/exercises/[slug]` route.
///
/// When navigated to from the library, the [ExerciseCatalogItem] is passed via
/// `GoRouterState.extra`. On a cold deep-link it's null, so we fetch by [id]
/// through [exerciseByIdProvider].
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final ExerciseCatalogItem? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);

    if (initial != null) {
      return _DetailScaffold(exercise: initial!, t: t);
    }

    final async = ref.watch(exerciseByIdProvider(id));
    return async.when(
      data: (exercise) {
        if (exercise == null) {
          return _MessageScaffold(
            t: t,
            message: t('exercises.NOT_FOUND'),
            color: SteelOpsColors.rust,
          );
        }
        return _DetailScaffold(exercise: exercise, t: t);
      },
      loading: () => Scaffold(
        backgroundColor: SteelOpsColors.background,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: SteelOpsColors.orange,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (_, _) => _MessageScaffold(
        t: t,
        message: t('exercises.LOAD_ERROR'),
        color: SteelOpsColors.rust,
      ),
    );
  }
}

// ── Detail body ──────────────────────────────────────────────────────────────

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.exercise, required this.t});
  final ExerciseCatalogItem exercise;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final media = exercise.gifUrl.isNotEmpty ? exercise.gifUrl : exercise.image;

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          children: [
            // Back button (mono link, like the web)
            _BackLink(label: t('exercises.BACK_TO_LIBRARY')),
            const SizedBox(height: 16),

            // ── Media frame ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: SteelOpsColors.surface,
                border: Border.all(color: SteelOpsColors.borderStrong),
              ),
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _Media(url: media, label: t('exercises.NO_MEDIA')),
              ),
            ),
            const SizedBox(height: 20),

            // ── Name ─────────────────────────────────────────────────────
            Text(
              exercise.name.toUpperCase(),
              style: steelHeadingStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              width: 48,
              height: 3,
              margin: const EdgeInsets.only(top: 6, bottom: 20),
              color: SteelOpsColors.orange,
            ),

            // ── Tag grid ─────────────────────────────────────────────────
            _TagGrid(
              entries: [
                _MetaEntry(t('exercises.BODY_PART'), exercise.bodyPart),
                _MetaEntry(t('exercises.EQUIPMENT'), exercise.equipment),
                _MetaEntry(t('exercises.TARGET'), exercise.target),
                _MetaEntry(t('exercises.MUSCLE_GROUP'), exercise.muscleGroup),
              ],
              naLabel: t('exercises.NA'),
            ),

            // ── Steps / instructions ─────────────────────────────────────
            if (exercise.steps.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: t('exercises.STEPS')),
              const SizedBox(height: 12),
              ...List.generate(exercise.steps.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (i + 1).toString().padLeft(2, '0'),
                        style: steelMonoStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: SteelOpsColors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exercise.steps[i],
                          style: steelMonoStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SteelOpsColors.inkMid,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else if (exercise.instructions.trim().isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: t('exercises.INSTRUCTIONS')),
              const SizedBox(height: 12),
              Text(
                exercise.instructions,
                style: steelMonoStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: SteelOpsColors.inkMid,
                  letterSpacing: 0.4,
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              _SectionHeader(label: t('exercises.INSTRUCTIONS')),
              const SizedBox(height: 12),
              Text(
                t('exercises.NO_INSTRUCTIONS'),
                style: steelMonoStyle(
                  fontSize: 12,
                  color: SteelOpsColors.inkDim,
                ),
              ),
            ],

            // ── Secondary muscles ────────────────────────────────────────
            if (exercise.secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: t('exercises.SECONDARY_MUSCLES')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in exercise.secondaryMuscles)
                    _Chip(label: m.toUpperCase()),
                ],
              ),
            ],

            // ── Footer summary ───────────────────────────────────────────
            const SizedBox(height: 28),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: SteelOpsColors.orange, width: 2),
                ),
              ),
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _FooterCell(
                      label: t('exercises.MUSCLE_GROUP'),
                      value: exercise.muscleGroup,
                    ),
                  ),
                  Container(width: 1, height: 36, color: SteelOpsColors.border),
                  Expanded(
                    child: _FooterCell(
                      label: t('exercises.TARGET'),
                      value: exercise.target,
                    ),
                  ),
                  Container(width: 1, height: 36, color: SteelOpsColors.border),
                  Expanded(
                    child: _FooterCell(
                      label: t('exercises.EXERCISE_ID'),
                      value: exercise.id.length > 8
                          ? exercise.id.substring(0, 8)
                          : exercise.id,
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
}

// ── Media (gif / image / placeholder) ────────────────────────────────────────

class _Media extends StatelessWidget {
  const _Media({required this.url, required this.label});
  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, _) => const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SteelOpsColors.orange,
          ),
        ),
      ),
      errorWidget: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: SteelOpsColors.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center,
            color: SteelOpsColors.inkDim,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: steelMonoStyle(
              fontSize: 10,
              color: SteelOpsColors.inkDim,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small building blocks ────────────────────────────────────────────────────

class _BackLink extends StatelessWidget {
  const _BackLink({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chevron_left,
            size: 16,
            color: SteelOpsColors.muted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: steelMonoStyle(
              fontSize: 10,
              color: SteelOpsColors.muted,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: SteelOpsColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: steelMonoStyle(
              fontSize: 10,
              color: SteelOpsColors.muted,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: SteelOpsColors.border)),
      ],
    );
  }
}

class _MetaEntry {
  const _MetaEntry(this.label, this.value);
  final String label;
  final String value;
}

class _TagGrid extends StatelessWidget {
  const _TagGrid({required this.entries, required this.naLabel});
  final List<_MetaEntry> entries;
  final String naLabel;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: [
        for (final e in entries)
          Container(
            decoration: const BoxDecoration(
              color: SteelOpsColors.surface,
              border: Border(
                left: BorderSide(color: SteelOpsColors.orange, width: 2),
                top: BorderSide(color: SteelOpsColors.border),
                right: BorderSide(color: SteelOpsColors.border),
                bottom: BorderSide(color: SteelOpsColors.border),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.label,
                  style: steelMonoStyle(
                    fontSize: 8,
                    color: SteelOpsColors.inkDim,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.value.trim().isEmpty ? naLabel : e.value.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: steelMonoStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SteelOpsColors.inkHigh,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: SteelOpsColors.borderStrong),
      ),
      child: Text(
        label,
        style: steelMonoStyle(
          fontSize: 9,
          color: SteelOpsColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _FooterCell extends StatelessWidget {
  const _FooterCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: steelMonoStyle(
            fontSize: 8,
            color: SteelOpsColors.inkDim,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.trim().isEmpty ? '—' : value.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: steelMonoStyle(
            fontSize: 10,
            color: SteelOpsColors.muted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Error / not-found scaffold ───────────────────────────────────────────────

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({
    required this.t,
    required this.message,
    required this.color,
  });
  final String Function(String) t;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackLink(label: t('exercises.BACK_TO_LIBRARY')),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: color, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: steelHeadingStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
