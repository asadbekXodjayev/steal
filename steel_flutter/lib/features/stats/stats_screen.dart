import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'stats_aggregations.dart';
import 'widgets/calendar_heatmap.dart';
import 'widgets/kpi_row.dart';
import 'widgets/muscle_pie_chart.dart';
import 'widgets/reps_distribution_chart.dart';
import 'widgets/stats_section_header.dart';
import 'widgets/volume_chart.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
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
              SliverToBoxAdapter(child: _Header(t: t)),
              SliverToBoxAdapter(
                child: SteelAsyncBody<ProgressData>(
                  isLoading: progressAsync.isLoading,
                  errorMessage: progressAsync.hasError
                      ? t('stats.SIGNAL_LOST_DESC')
                      : null,
                  data: progressAsync.valueOrNull,
                  onRetry: () => ref.invalidate(progressDataProvider),
                  builder: (context, data) {
                    if (data.sessions.isEmpty) {
                      return _EmptyState(t: t);
                    }
                    return _StatsBody(t: t);
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

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.t});
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final clock = DateFormat.Hm().format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t('stats.EYEBROW_LEFT'),
                style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.muted),
              ),
              Container(
                width: 40,
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: SteelOpsColors.borderStrong,
              ),
              Expanded(
                child: Text(
                  t('stats.EYEBROW_RIGHT'),
                  style: steelMonoStyle(
                    fontSize: 10,
                    color: SteelOpsColors.orange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${t('stats.LAST_SYNC')} $clock',
                style: steelMonoStyle(
                  fontSize: 9,
                  color: SteelOpsColors.inkDim,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t('stats.TITLE'),
            style: steelHeadingStyle(fontSize: 42, fontWeight: FontWeight.w900),
          ),
          Container(
            width: 48,
            height: 3,
            margin: const EdgeInsets.only(top: 4, bottom: 24),
            color: SteelOpsColors.orange,
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t});
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: SteelOpsColors.surface,
          border: Border.all(color: SteelOpsColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SteelEmptyState(
          icon: Icons.bar_chart_outlined,
          title: t('stats.NO_DATA_TITLE'),
          subtitle: t('stats.NO_DATA_DESC'),
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _StatsBody extends ConsumerWidget {
  const _StatsBody({required this.t});
  final String Function(String) t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final prs = ref.watch(personalRecordsProvider);
    final muscles = ref.watch(muscleDistributionProvider);
    final weeklyVolume = ref.watch(weeklyVolumeProvider);
    final reps = ref.watch(repsDistributionProvider);
    final heatmap = ref.watch(heatmapDaysProvider);
    final hud = ref.watch(hudTotalsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI row ──
          _KpiSection(t: t, streak: streak, hud: hud),
          const SizedBox(height: 28),

          // ── Streak & sessions ──
          _StreakSection(t: t, streak: streak),
          const SizedBox(height: 28),

          // ── Weekly volume ──
          StatsSectionHeader(
            label: t('stats.LAST_8_WEEKS'),
            title: t('stats.WEEKLY_VOLUME'),
            panelNum: '05',
          ),
          const SizedBox(height: 12),
          VolumeChart(
            data: weeklyVolume,
            peakLabel: t('stats.PEAK'),
            avgLabel: t('stats.AVG'),
            sessionsLabel: t('stats.SESSIONS_LABEL'),
            emptyLabel: t('stats.INSUFFICIENT_DATA'),
          ),
          const SizedBox(height: 28),

          // ── Rep distribution ──
          StatsSectionHeader(
            label: t('stats.INTENSITY_PROFILE'),
            title: t('stats.REP_DISTRIBUTION'),
            panelNum: '06',
          ),
          const SizedBox(height: 12),
          RepsDistributionChart(
            data: reps,
            emptyLabel: t('stats.NO_REP_DATA'),
          ),
          const SizedBox(height: 28),

          // ── Contact matrix (calendar heatmap) ──
          StatsSectionHeader(
            label: '${t('stats.YEAR_LABEL')} ${DateTime.now().year}',
            title: t('stats.CONTACT_MATRIX'),
            panelNum: '07',
          ),
          const SizedBox(height: 12),
          CalendarHeatmap(
            days: heatmap,
            lessLabel: t('stats.HEATMAP_LESS'),
            moreLabel: t('stats.HEATMAP_MORE'),
          ),
          const SizedBox(height: 28),

          // ── Muscle map ──
          if (muscles.isNotEmpty) ...[
            StatsSectionHeader(
              label: t('stats.VOLUME_BREAKDOWN'),
              title: t('stats.MUSCLE_MAP'),
              panelNum: '08',
            ),
            const SizedBox(height: 12),
            MusclePieChart(
              slices: muscles,
              setsLabel: t('stats.SETS_LABEL'),
              labelFor: (key) => t('stats.muscle.$key'),
            ),
            const SizedBox(height: 28),
          ],

          // ── Personal records ──
          if (prs.isNotEmpty) ...[
            StatsSectionHeader(
              label: t('stats.PERSONAL_BESTS'),
              title: t('stats.RECORDS'),
              panelNum: '09',
            ),
            const SizedBox(height: 12),
            _PersonalRecordsTable(t: t, records: prs),
            const SizedBox(height: 28),
          ],

          // ── HUD strip ──
          _HudStrip(t: t, hud: hud),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── KPI section ──────────────────────────────────────────────────────────────

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.t, required this.streak, required this.hud});
  final String Function(String) t;
  final StreakData streak;
  final HudTotals hud;

  @override
  Widget build(BuildContext context) {
    final grouped = NumberFormat.decimalPattern();
    final tonnes = (hud.totalVolume / 1000).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatsSectionHeader(
          label: t('stats.KPI'),
          title: t('stats.READOUT'),
          panelNum: '01',
        ),
        const SizedBox(height: 12),
        KpiGrid(
          tiles: [
            KpiPanel(
              label: t('stats.TOTAL_SESSIONS'),
              value: '${streak.totalSessions}',
              subValue: t('stats.LIFETIME'),
              accent: SteelOpsColors.orange,
              panelNum: '01',
            ),
            KpiPanel(
              label: t('stats.CURRENT_STREAK'),
              value: '${streak.currentStreak}',
              subValue: '${t('stats.BEST')}: ${streak.longestStreak}${_d(t)}',
              accent: SteelOpsColors.green,
              panelNum: '02',
            ),
            KpiPanel(
              label: t('stats.TOTAL_VOLUME'),
              value: '$tonnes',
              subValue:
                  '${grouped.format(hud.totalVolume.round())} ${t('stats.KG')}',
              accent: SteelOpsColors.orange,
              panelNum: '03',
            ),
            KpiPanel(
              label: t('stats.THIS_MONTH'),
              value: '${streak.thisMonthSessions}',
              subValue: '${streak.thisWeekSessions} ${t('stats.THIS_WK')}',
              accent: SteelOpsColors.blue,
              panelNum: '04',
            ),
          ],
        ),
      ],
    );
  }

  String _d(String Function(String) t) {
    final days = t('stats.DAYS');
    return days.isNotEmpty ? days[0] : 'D';
  }
}

// ── Streak section ───────────────────────────────────────────────────────────

class _StreakSection extends StatelessWidget {
  const _StreakSection({required this.t, required this.streak});
  final String Function(String) t;
  final StreakData streak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatsSectionHeader(
          label: t('stats.CONSISTENCY'),
          title: t('stats.STREAK_SESSIONS'),
          panelNum: '02',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StreakCard(
                value: '${streak.currentStreak}',
                unit: t('stats.DAYS'),
                label: t('stats.CURRENT_STREAK'),
                accent: SteelOpsColors.orange,
                isHero: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakCard(
                value: '${streak.longestStreak}',
                unit: t('stats.DAYS'),
                label: t('stats.LONGEST_STREAK'),
                accent: SteelOpsColors.forge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatMini(
                value: '${streak.totalSessions}',
                label: t('stats.TOTAL'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                value: '${streak.thisWeekSessions}',
                label: t('stats.THIS_WEEK'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMini(
                value: '${streak.thisMonthSessions}',
                label: t('stats.THIS_MONTH'),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Personal records table ───────────────────────────────────────────────────

class _PersonalRecordsTable extends StatelessWidget {
  const _PersonalRecordsTable({required this.t, required this.records});
  final String Function(String) t;
  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    final top = records.take(8).toList();
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border.all(color: SteelOpsColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    t('stats.EXERCISE'),
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.inkDim,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(
                  width: 88,
                  child: Text(
                    t('stats.BEST_SET'),
                    textAlign: TextAlign.right,
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.inkDim,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(
                  width: 84,
                  child: Text(
                    t('stats.EST_1RM'),
                    textAlign: TextAlign.right,
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.inkDim,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: SteelOpsColors.border),
          ...top.asMap().entries.map((entry) {
            return _PRRow(
              pr: entry.value,
              isLast: entry.key == top.length - 1,
            );
          }),
        ],
      ),
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
      final dt = DateTime.tryParse(pr.date)?.toLocal();
      return dt == null ? '' : DateFormat.MMMd().format(dt);
    }();
    final num = NumberFormat('#.#');
    String fmt(double v) => num.format(v);

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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: steelMonoStyle(
                          fontSize: 10,
                          color: SteelOpsColors.inkDim,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  '${fmt(pr.weight)} kg × ${pr.reps}',
                  textAlign: TextAlign.right,
                  style: steelMonoStyle(
                    fontSize: 12,
                    color: SteelOpsColors.inkMid,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(
                width: 84,
                child: Text(
                  '${fmt(pr.estimated1RM)} kg',
                  textAlign: TextAlign.right,
                  style: steelMonoStyle(
                    fontSize: 13,
                    color: SteelOpsColors.orange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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

// ── HUD strip ────────────────────────────────────────────────────────────────

class _HudStrip extends StatelessWidget {
  const _HudStrip({required this.t, required this.hud});
  final String Function(String) t;
  final HudTotals hud;

  @override
  Widget build(BuildContext context) {
    final grouped = NumberFormat.decimalPattern();
    final num1 = NumberFormat('#.#');

    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: SteelOpsColors.orange, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HudCell(
              label: t('stats.TOTAL_REPS'),
              value: grouped.format(hud.totalReps),
              caption: t('stats.REPS_LOGGED'),
              valueColor: SteelOpsColors.inkHigh,
              captionColor: SteelOpsColors.orange,
            ),
          ),
          Expanded(
            child: _HudCell(
              label: t('stats.AVG_RPE'),
              value: hud.avgRpe > 0 ? num1.format(hud.avgRpe) : '—',
              caption: t('stats.INTENSITY_10'),
              valueColor: hud.avgRpe >= 8
                  ? SteelOpsColors.orange
                  : SteelOpsColors.inkHigh,
              captionColor: SteelOpsColors.inkDim,
            ),
          ),
          Expanded(
            child: _HudCell(
              label: t('stats.HEAVIEST_SET'),
              value: hud.heaviestWeight > 0
                  ? num1.format(hud.heaviestWeight)
                  : '—',
              caption: hud.heaviestWeight > 0
                  ? t('stats.HEAVIEST_CAPTION')
                      .replaceAll('{n}', '${hud.heaviestReps}')
                  : t('stats.NO_DATA'),
              valueColor: SteelOpsColors.green,
              captionColor: SteelOpsColors.inkDim,
            ),
          ),
          Expanded(
            child: _HudCell(
              label: t('stats.TOTAL_VOLUME'),
              value: '${(hud.totalVolume / 1000).round()}',
              caption: t('stats.TONNES'),
              valueColor: SteelOpsColors.orange,
              captionColor: SteelOpsColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudCell extends StatelessWidget {
  const _HudCell({
    required this.label,
    required this.value,
    required this.caption,
    required this.valueColor,
    required this.captionColor,
  });
  final String label;
  final String value;
  final String caption;
  final Color valueColor;
  final Color captionColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: steelMonoStyle(
              fontSize: 8,
              color: SteelOpsColors.inkDim,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: steelMonoStyle(
              fontSize: 22,
              color: valueColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: steelMonoStyle(
              fontSize: 8,
              color: captionColor,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
