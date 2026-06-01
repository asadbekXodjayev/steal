import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressDataProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: SteelOpsColors.orange,
          backgroundColor: SteelOpsColors.surfaceElevated,
          onRefresh: () async => ref.invalidate(progressDataProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ANALYTICS',
                            style: steelMonoStyle(
                              fontSize: 10,
                              color: SteelOpsColors.muted,
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 1,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            color: SteelOpsColors.borderStrong,
                          ),
                          Text(
                            'FORGED IN IRON',
                            style: steelMonoStyle(
                              fontSize: 10,
                              color: SteelOpsColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'STATS',
                        style: steelHeadingStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 3,
                        margin: const EdgeInsets.only(top: 4, bottom: 24),
                        color: SteelOpsColors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SteelAsyncBody<ProgressData>(
                  isLoading: progressAsync.isLoading,
                  errorMessage: progressAsync.hasError
                      ? progressAsync.error.toString()
                      : null,
                  data: progressAsync.valueOrNull,
                  onRetry: () => ref.invalidate(progressDataProvider),
                  builder: (context, data) {
                    if (data.sessions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          decoration: BoxDecoration(
                            color: SteelOpsColors.surface,
                            border:
                                Border.all(color: SteelOpsColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const SteelEmptyState(
                            icon: Icons.bar_chart_outlined,
                            title:
                                'No training logged yet — start a session',
                            subtitle:
                                'Complete a workout to unlock your analytics',
                          ),
                        ),
                      );
                    }

                    final streak = ref.watch(streakProvider);
                    final prs = ref.watch(personalRecordsProvider);
                    final muscles = ref.watch(muscleDistributionProvider);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StreakSection(streak: streak),
                          const SizedBox(height: 28),
                          if (prs.isNotEmpty) ...[
                            _PersonalRecordsSection(records: prs),
                            const SizedBox(height: 28),
                          ],
                          if (muscles.isNotEmpty) ...[
                            _MuscleDistributionSection(slices: muscles),
                            const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Streak section ───────────────────────────────────────────────────────────

class _StreakSection extends StatelessWidget {
  const _StreakSection({required this.streak});
  final StreakData streak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'CONSISTENCY',
          title: 'STREAK & SESSIONS',
        ),
        const SizedBox(height: 12),

        // Primary streak cards (2 col)
        Row(
          children: [
            Expanded(
              child: _StreakCard(
                value: '${streak.currentStreak}',
                unit: 'DAYS',
                label: 'CURRENT STREAK',
                accent: SteelOpsColors.orange,
                isHero: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakCard(
                value: '${streak.longestStreak}',
                unit: 'DAYS',
                label: 'LONGEST STREAK',
                accent: SteelOpsColors.forge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Secondary stat row (3 col)
        Row(
          children: [
            Expanded(
              child: _StatMini(
                value: '${streak.totalSessions}',
                label: 'TOTAL',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                value: '${streak.thisWeekSessions}',
                label: 'THIS WEEK',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                value: '${streak.thisMonthSessions}',
                label: 'THIS MONTH',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.accent,
    this.isHero = false,
  });
  final String value;
  final String unit;
  final String label;
  final Color accent;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHero ? accent.withAlpha(20) : SteelOpsColors.surfaceElevated,
        border: Border.all(
          color: isHero ? accent : SteelOpsColors.border,
          width: isHero ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: steelHeadingStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: steelMonoStyle(
                  fontSize: 10,
                  color: accent.withAlpha(180),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: steelMonoStyle(
              fontSize: 9,
              color: SteelOpsColors.muted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border.all(color: SteelOpsColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: steelHeadingStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: SteelOpsColors.inkHigh,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: steelMonoStyle(
              fontSize: 8,
              color: SteelOpsColors.muted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Personal records section ─────────────────────────────────────────────────

class _PersonalRecordsSection extends StatelessWidget {
  const _PersonalRecordsSection({required this.records});
  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    // Show top 8 by estimated 1RM (already sorted by provider).
    final top = records.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'PERSONAL BESTS',
          title: 'RECORDS',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SteelOpsColors.surfaceElevated,
            border: Border.all(color: SteelOpsColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              // Column headers
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'EXERCISE',
                        style: steelMonoStyle(
                          fontSize: 8,
                          color: SteelOpsColors.inkDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'BEST SET',
                        textAlign: TextAlign.right,
                        style: steelMonoStyle(
                          fontSize: 8,
                          color: SteelOpsColors.inkDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        'EST 1RM',
                        textAlign: TextAlign.right,
                        style: steelMonoStyle(
                          fontSize: 8,
                          color: SteelOpsColors.inkDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: SteelOpsColors.border),
              ...top.asMap().entries.map((entry) {
                final idx = entry.key;
                final pr = entry.value;
                final isLast = idx == top.length - 1;
                return _PRRow(pr: pr, isLast: isLast);
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PRRow extends StatelessWidget {
  const _PRRow({required this.pr, required this.isLast});
  final PersonalRecord pr;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateStr = () {
      try {
        final dt = DateTime.parse(pr.date).toLocal();
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}';
      } catch (_) {
        return '';
      }
    }();
    String fmtNum(double v) {
      if (v == v.truncate()) return v.toInt().toString();
      return v.toStringAsFixed(1);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pr.exerciseName,
                      style: steelHeadingStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: steelMonoStyle(
                          fontSize: 8,
                          color: SteelOpsColors.inkDim,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '${fmtNum(pr.weight)} kg × ${pr.reps}',
                  textAlign: TextAlign.right,
                  style: steelMonoStyle(
                    fontSize: 10,
                    color: SteelOpsColors.inkMid,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '${fmtNum(pr.estimated1RM)} kg',
                  textAlign: TextAlign.right,
                  style: steelMonoStyle(
                    fontSize: 11,
                    color: SteelOpsColors.orange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Container(height: 1, color: SteelOpsColors.border),
      ],
    );
  }
}

// ── Muscle distribution section ───────────────────────────────────────────────

class _MuscleDistributionSection extends StatelessWidget {
  const _MuscleDistributionSection({required this.slices});
  final List<MuscleSlice> slices;

  @override
  Widget build(BuildContext context) {
    final maxVol = slices.fold(0.0, (m, s) => s.volume > m ? s.volume : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'VOLUME BREAKDOWN',
          title: 'MUSCLE MAP',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SteelOpsColors.surfaceElevated,
            border: Border.all(color: SteelOpsColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: slices.asMap().entries.map((entry) {
              final idx = entry.key;
              final slice = entry.value;
              final isLast = idx == slices.length - 1;
              final ratio = maxVol > 0 ? slice.volume / maxVol : 0.0;
              return _MuscleBar(
                slice: slice,
                ratio: ratio,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MuscleBar extends StatelessWidget {
  const _MuscleBar({
    required this.slice,
    required this.ratio,
    required this.isLast,
  });
  final MuscleSlice slice;
  final double ratio;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    String fmtVol(double v) {
      final i = v.round();
      if (i >= 1000) {
        final thousands = i ~/ 1000;
        final remainder = i % 1000;
        return '$thousands,${remainder.toString().padLeft(3, '0')}';
      }
      return i.toString();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slice.name,
                style: steelMonoStyle(
                  fontSize: 10,
                  color: SteelOpsColors.inkMid,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${fmtVol(slice.volume)} kg',
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.orange,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${slice.count} sets',
                    style: steelMonoStyle(
                      fontSize: 9,
                      color: SteelOpsColors.inkDim,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Bar track
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: SteelOpsColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: SteelOpsColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.title});
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: steelMonoStyle(
            fontSize: 10,
            color: SteelOpsColors.muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              title,
              style: steelHeadingStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                color: SteelOpsColors.border,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
