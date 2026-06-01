// lib/features/programs/program_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  const ProgramDetailScreen({super.key, required this.template});
  final ProgramTemplate template;

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  int? _expandedDay;
  bool _starting = false;

  Future<void> _startProgram() async {
    setState(() => _starting = true);
    try {
      await ref
          .read(repositoryProvider)
          .createPlanFromTemplate(widget.template);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.surface,
          content: Text(
            'PROGRAM STARTED: ${widget.template.title.toUpperCase()}',
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
          content: Text(
            'ERROR: $e',
            style: steelMonoStyle(fontSize: 11, color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: SteelOpsColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  t.image.isNotEmpty
                      ? Image.network(
                          t.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, err, stack) => Container(
                            color: SteelOpsColors.surfaceElevated,
                            child: const Icon(Icons.fitness_center,
                                color: SteelOpsColors.muted, size: 48),
                          ),
                        )
                      : Container(
                          color: SteelOpsColors.surfaceElevated,
                          child: const Icon(Icons.fitness_center,
                              color: SteelOpsColors.muted, size: 48),
                        ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          SteelOpsColors.background,
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Difficulty badge
                  if (t.difficulty.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        color: SteelOpsColors.orange,
                        child: Text(
                          t.difficulty.toUpperCase(),
                          style: steelMonoStyle(
                              fontSize: 9,
                              color: Colors.white,
                              letterSpacing: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Title block ──────────────────────────────────
                if (t.athleteName.isNotEmpty)
                  Text(
                    t.athleteName.toUpperCase(),
                    style:
                        steelMonoStyle(fontSize: 10, color: SteelOpsColors.muted),
                  ),
                const SizedBox(height: 4),
                Text(
                  t.title,
                  style:
                      steelHeadingStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                Container(
                  width: 48,
                  height: 3,
                  margin: const EdgeInsets.only(top: 6, bottom: 12),
                  color: SteelOpsColors.orange,
                ),
                if (t.description.isNotEmpty)
                  Text(
                    t.description,
                    style: steelMonoStyle(
                        fontSize: 12, color: SteelOpsColors.inkDim),
                  ),
                const SizedBox(height: 20),

                // ── Stats row ────────────────────────────────────
                Row(
                  children: [
                    _StatChip(label: 'DAYS/WEEK', value: '${t.daysPerWeek}'),
                    const SizedBox(width: 8),
                    _StatChip(label: 'SESSION', value: t.sessionLength),
                    const SizedBox(width: 8),
                    _StatChip(
                        label: 'WEEKS',
                        value: t.durationWeeks > 0
                            ? '${t.durationWeeks}'
                            : '—'),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Tags ─────────────────────────────────────────
                if (t.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: t.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: SteelOpsColors.borderStrong),
                            ),
                            child: Text(
                              tag,
                              style: steelMonoStyle(
                                  fontSize: 9,
                                  color: SteelOpsColors.inkMid,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Split / Best For ─────────────────────────────
                if (t.split.isNotEmpty || t.bestFor.isNotEmpty) ...[
                  _SectionHeader(label: 'OVERVIEW'),
                  if (t.split.isNotEmpty)
                    _InfoRow(label: 'SPLIT', value: t.split),
                  if (t.bestFor.isNotEmpty)
                    _InfoRow(label: 'BEST FOR', value: t.bestFor),
                  const SizedBox(height: 16),
                ],

                // ── Characteristics ──────────────────────────────
                if (t.characteristics.isNotEmpty) ...[
                  _SectionHeader(label: 'CHARACTERISTICS'),
                  ...t.characteristics.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 5, right: 10),
                            decoration: const BoxDecoration(
                              color: SteelOpsColors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              c,
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Weekly Schedule ──────────────────────────────
                _SectionHeader(label: 'WEEKLY SCHEDULE'),
                if (t.days.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No schedule available.',
                      style: steelMonoStyle(
                          fontSize: 11, color: SteelOpsColors.muted),
                    ),
                  )
                else
                  ...List.generate(t.days.length, (i) {
                    final day = t.days[i];
                    final isRest = day.isRest || day.exercises.isEmpty;
                    final isExpanded = _expandedDay == i;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: isRest
                              ? null
                              : () => setState(
                                  () => _expandedDay = isExpanded ? null : i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: SteelOpsColors.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    'D${day.dayNumber}',
                                    style: steelMonoStyle(
                                      fontSize: 11,
                                      color: SteelOpsColors.orange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    day.label.isNotEmpty
                                        ? day.label.toUpperCase()
                                        : 'REST',
                                    style: steelMonoStyle(
                                      fontSize: 12,
                                      color: isRest
                                          ? SteelOpsColors.muted
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                if (!isRest) ...[
                                  Text(
                                    '${day.exercises.length} EXERCISES',
                                    style: steelMonoStyle(
                                        fontSize: 9,
                                        color: SteelOpsColors.muted),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: SteelOpsColors.muted,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            color: SteelOpsColors.surface,
                            padding:
                                const EdgeInsets.fromLTRB(36, 8, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: day.exercises
                                  .map(
                                    (ex) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                                top: 5, right: 10),
                                            decoration: const BoxDecoration(
                                              color: SteelOpsColors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ex.name,
                                                  style: steelMonoStyle(
                                                    fontSize: 11,
                                                    color:
                                                        SteelOpsColors.inkMid,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    if (ex.sets.isNotEmpty) ...[
                                                      Text(
                                                        '${ex.sets} × ${ex.reps}',
                                                        style: steelMonoStyle(
                                                          fontSize: 9,
                                                          color: SteelOpsColors
                                                              .orange,
                                                        ),
                                                      ),
                                                    ],
                                                    if (ex.rest.isNotEmpty) ...[
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'REST ${ex.rest}',
                                                        style: steelMonoStyle(
                                                          fontSize: 9,
                                                          color: SteelOpsColors
                                                              .muted,
                                                        ),
                                                      ),
                                                    ],
                                                    if (ex.tempo.isNotEmpty) ...[
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        ex.tempo,
                                                        style: steelMonoStyle(
                                                          fontSize: 9,
                                                          color: SteelOpsColors
                                                              .inkDim,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (ex.notes.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    ex.notes,
                                                    style: steelMonoStyle(
                                                      fontSize: 9,
                                                      color:
                                                          SteelOpsColors.inkDim,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    );
                  }),

                const SizedBox(height: 20),

                // ── Progression guidelines ───────────────────────
                if (t.progression.isNotEmpty) ...[
                  _SectionHeader(label: 'PROGRESSION'),
                  ...t.progression.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin:
                                const EdgeInsets.only(top: 5, right: 10),
                            decoration: const BoxDecoration(
                              color: SteelOpsColors.forge,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              p,
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Recovery guidelines ──────────────────────────
                if (t.recovery.isNotEmpty) ...[
                  _SectionHeader(label: 'RECOVERY'),
                  ...t.recovery.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin:
                                const EdgeInsets.only(top: 5, right: 10),
                            decoration: const BoxDecoration(
                              color: SteelOpsColors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              r,
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom action bar ──────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SteelForgeButton(
            label: 'START PROGRAM',
            isLoading: _starting,
            onPressed: _starting ? null : _startProgram,
          ),
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: steelMonoStyle(
                fontSize: 11, color: SteelOpsColors.muted, letterSpacing: 2),
          ),
          Container(
            height: 1,
            color: SteelOpsColors.border,
            margin: const EdgeInsets.only(top: 6, bottom: 2),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: steelMonoStyle(
                  fontSize: 11, color: SteelOpsColors.inkMid, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: SteelOpsColors.surface,
          border: Border.all(color: SteelOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              value,
              style:
                  steelHeadingStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: steelMonoStyle(
                  fontSize: 8, color: SteelOpsColors.muted, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
