import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';
import 'data/dashboard_data.dart';
import 'data/ops_dashboard_sample.dart';
import 'widgets/ops_deploy_button.dart';
import 'widgets/ops_mission_briefing.dart';
import 'widgets/ops_session_feed.dart';
import 'widgets/ops_stat_card.dart';
import 'widgets/ops_top_bar.dart';

class OperationsDashboardView extends ConsumerWidget {
  const OperationsDashboardView({
    super.key,
    required this.operatorName,
    required this.operatorInitial,
    required this.onProfileTap,
  });

  final String operatorName;
  final String operatorInitial;
  final VoidCallback onProfileTap;

  String _opsTimestamp(DateTime now) {
    const m = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final d = now.day.toString().padLeft(2, '0');
    final mo = m[now.month - 1];
    final y = (now.year % 100).toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$d$mo$y $h:$min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final now = DateTime.now();
    final streak = ref.watch(streakProvider);
    final totalVolume = ref.watch(totalVolumeTonsProvider);
    final prsThisMonth = ref.watch(prsThisMonthProvider);
    final activePlanAsync = ref.watch(activePlanProvider);

    // KPIs mirror the web dashboard: streak, this week, total volume, PRs.
    final stats = [
      OpsStatItem(
        label: t('home.CURRENT_STREAK'),
        value: '${streak.currentStreak}',
        unit: t('home.DAYS'),
        accent: SteelOpsColors.green,
        valueColor: SteelOpsColors.green,
      ),
      OpsStatItem(
        label: t('home.THIS_WEEK'),
        value: '${streak.thisWeekSessions}',
        unit: t('home.SESSIONS'),
        accent: SteelOpsColors.orange,
        valueColor: SteelOpsColors.orange,
      ),
      OpsStatItem(
        label: t('home.TOTAL_VOLUME'),
        value: '$totalVolume',
        unit: t('home.TONNES_LIFTED'),
        accent: SteelOpsColors.orange,
        valueColor: SteelOpsColors.orange,
      ),
      OpsStatItem(
        label: t('home.PRS_THIS_MONTH'),
        value: '$prsThisMonth',
        unit: t('home.RECORDS_SET'),
        accent: SteelOpsColors.blue,
        valueColor: SteelOpsColors.blue,
      ),
    ];

    // SafeArea + clear top padding so the ops bar sits below the notch/status
    // bar — the dashboard is the first screen and must not be glued to the top.
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                OpsTopBar(
                  operatorInitial: operatorInitial,
                  onProfileTap: onProfileTap,
                ),
                Text(
                  t('home.DASHBOARD_TAG'),
                  style: steelMonoStyle(fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        t('home.OPERATIONS_DASHBOARD'),
                        style: steelHeadingStyle(fontSize: 34, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${t('home.OPERATOR')}: $operatorName',
                          style: steelMonoStyle(fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _opsTimestamp(now),
                          style: steelMonoStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 2,
                  width: 32,
                  margin: const EdgeInsets.only(top: 8),
                  color: SteelOpsColors.orange,
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats.map((s) => OpsStatCard(item: s)).toList(),
                ),
                const SizedBox(height: 16),

                // Active plan / mission briefing section.
                activePlanAsync.when(
                  loading: () => const _PlanLoadingCard(),
                  error: (err, st) => _PlanErrorCard(message: t('home.MISSION_DATA_UNAVAILABLE')),
                  data: (plan) {
                    if (plan == null) {
                      return _NoPlanCard(t: t);
                    }
                    return _LiveMissionBriefing(plan: plan);
                  },
                ),

                const SizedBox(height: 12),

                // LAST SESSIONS feed (recent completed sessions).
                OpsSessionFeed(),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.pushNamed(SteelRoutes.quickSession),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: SteelOpsColors.forge),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: SteelOpsColors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  t('quick.TITLE'),
                                  overflow: TextOverflow.ellipsis,
                                  style: steelMonoStyle(
                                    fontSize: 11,
                                    color: SteelOpsColors.orange,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            context.pushNamed(SteelRoutes.onboarding),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: SteelOpsColors.borderStrong),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.settings_outlined,
                                color: SteelOpsColors.muted,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  t('home.RUN_SETUP'),
                                  overflow: TextOverflow.ellipsis,
                                  style: steelMonoStyle(
                                    fontSize: 11,
                                    color: SteelOpsColors.muted,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OpsDeployButton(
                  onPressed: () => context.pushNamed(SteelRoutes.therapySession),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan loading skeleton ────────────────────────────────────────────────────

class _PlanLoadingCard extends StatelessWidget {
  const _PlanLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SteelOpsColors.orange,
          ),
        ),
      ),
    );
  }
}

// ── Plan error state ─────────────────────────────────────────────────────────

class _PlanErrorCard extends StatelessWidget {
  const _PlanErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
      ),
    );
  }
}

// ── No active plan CTA ───────────────────────────────────────────────────────

class _NoPlanCard extends StatelessWidget {
  const _NoPlanCard({required this.t});
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('home.MISSION_BRIEFING'),
            style: steelHeadingStyle(fontSize: 20, letterSpacing: 2),
          ),
          const SizedBox(height: 14),
          Text(
            t('home.NO_ACTIVE_PROGRAM'),
            style: steelMonoStyle(
              fontSize: 12,
              color: SteelOpsColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('home.NO_PROGRAM_DESC'),
            style: steelMonoStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: SteelOpsColors.inkDim,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SteelOpsColors.forge.withValues(alpha: 0.15),
              border: Border.all(color: SteelOpsColors.forge),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: SteelOpsColors.forge, size: 16),
                const SizedBox(width: 8),
                Text(
                  t('home.FIND_A_PROGRAM'),
                  style: steelMonoStyle(
                    fontSize: 11,
                    color: SteelOpsColors.forge,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live mission briefing backed by real plan data ────────────────────────────

class _LiveMissionBriefing extends ConsumerWidget {
  const _LiveMissionBriefing({required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final planDaysAsync = ref.watch(planDaysProvider(plan.id));
    final completedAsync = ref.watch(completedPlanDaysProvider(plan.id));
    final displayWeek = ref.watch(displayWeekProvider);

    return planDaysAsync.when(
      loading: () => _buildShell(
        t: t,
        plan: plan,
        week: displayWeek,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SteelOpsColors.orange,
            ),
          ),
        ),
      ),
      error: (err, st) => _buildShell(
        t: t,
        plan: plan,
        week: displayWeek,
        child: Text(
          t('home.MISSION_DATA_UNAVAILABLE'),
          style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
        ),
      ),
      data: (days) {
        final completedIds = completedAsync.valueOrNull ?? {};
        final nextDay = firstUncompletedDay(days, completedIds);

        // Weekly schedule strip (upcoming + recently completed days).
        final schedule = buildSchedule(days, completedIds, displayWeek: displayWeek);

        return _MissionBriefingWithNext(
          plan: plan,
          displayWeek: displayWeek,
          nextDay: nextDay,
          hasDays: days.isNotEmpty,
          schedule: schedule,
        );
      },
    );
  }

  Widget _buildShell({
    required String Function(String) t,
    required WorkoutPlan plan,
    required int week,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  plan.title.toUpperCase(),
                  style: steelHeadingStyle(fontSize: 20, letterSpacing: 2),
                ),
              ),
              Text(
                t('home.WK_OF')
                    .replaceAll('{n}', '$week')
                    .replaceAll('{weeks}', '${plan.durationWeeks}'),
                style: steelMonoStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Mission briefing that loads the NEXT session's exercises and renders them,
/// plus the weekly schedule strip. Matches the web dashboard's content.
class _MissionBriefingWithNext extends ConsumerWidget {
  const _MissionBriefingWithNext({
    required this.plan,
    required this.displayWeek,
    required this.nextDay,
    required this.hasDays,
    required this.schedule,
  });

  final WorkoutPlan plan;
  final int displayWeek;
  final PlanDay? nextDay;
  final bool hasDays;
  final List<ScheduleEntry> schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final nd = nextDay;
    final weekLabel = t('home.WK_OF')
        .replaceAll('{n}', '$displayWeek')
        .replaceAll('{weeks}', '${plan.durationWeeks}');

    // No next session: either program complete or no days configured.
    if (nd == null) {
      return OpsMissionShell(
        title: plan.title.toUpperCase(),
        weekLabel: weekLabel,
        goalType: plan.goalType,
        schedule: schedule,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            hasDays ? t('home.PROGRAM_COMPLETE') : t('home.NO_TRAINING_DAYS'),
            style: steelMonoStyle(
              fontSize: 12,
              color: hasDays ? SteelOpsColors.green : SteelOpsColors.muted,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    final exercisesAsync = ref.watch(planExercisesProvider(nd.id));

    return exercisesAsync.when(
      loading: () => OpsMissionShell(
        title: plan.title.toUpperCase(),
        weekLabel: weekLabel,
        goalType: plan.goalType,
        schedule: schedule,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SteelOpsColors.orange,
              ),
            ),
          ),
        ),
      ),
      error: (err, st) => OpsMissionShell(
        title: plan.title.toUpperCase(),
        weekLabel: weekLabel,
        goalType: plan.goalType,
        schedule: schedule,
        child: Text(
          t('home.MISSION_DATA_UNAVAILABLE'),
          style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
        ),
      ),
      data: (exercises) {
        final lines = exercises
            .asMap()
            .entries
            .map((e) => OpsExerciseLine(
                  index: (e.key + 1).toString().padLeft(2, '0'),
                  name: (e.value.name.isNotEmpty
                          ? e.value.name
                          : t('home.EXERCISE'))
                      .toUpperCase(),
                  setsReps: '${e.value.sets}x${e.value.repsLabel}',
                ))
            .toList();

        return OpsMissionShell(
          title: plan.title.toUpperCase(),
          weekLabel: weekLabel,
          goalType: plan.goalType,
          schedule: schedule,
          child: OpsNextSessionBody(
            dayLabel: nd.label.toUpperCase(),
            focus: nd.focus,
            lines: lines,
            estimatedMinutes: estimateMinutes(exercises),
          ),
        );
      },
    );
  }
}
