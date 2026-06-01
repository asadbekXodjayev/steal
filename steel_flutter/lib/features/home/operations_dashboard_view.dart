import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import 'data/ops_dashboard_sample.dart';
import 'widgets/ops_deploy_button.dart';
import 'widgets/ops_mission_briefing.dart';
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
    final now = DateTime.now();
    final streak = ref.watch(streakProvider);
    final activePlanAsync = ref.watch(activePlanProvider);

    // Build stat cards with live streak data.
    final stats = [
      OpsStatItem(
        label: 'CURRENT STREAK',
        value: '${streak.currentStreak}',
        unit: 'DAYS',
        accent: SteelOpsColors.green,
        valueColor: SteelOpsColors.green,
      ),
      OpsStatItem(
        label: 'THIS WEEK',
        value: '${streak.thisWeekSessions}',
        unit: 'SESSIONS',
        accent: SteelOpsColors.orange,
        valueColor: SteelOpsColors.orange,
      ),
      OpsStatItem(
        label: 'TOTAL SESSIONS',
        value: '${streak.totalSessions}',
        unit: 'COMPLETED',
        accent: SteelOpsColors.orange,
        valueColor: SteelOpsColors.orange,
      ),
      OpsStatItem(
        label: 'LONGEST STREAK',
        value: '${streak.longestStreak}',
        unit: 'DAYS',
        accent: SteelOpsColors.blue,
        valueColor: SteelOpsColors.blue,
      ),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              OpsTopBar(
                operatorInitial: operatorInitial,
                onProfileTap: onProfileTap,
              ),
              Text(
                'DASHBOARD.STEEL',
                style: steelMonoStyle(fontSize: 10, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'OPERATIONS DASHBOARD',
                      style: steelHeadingStyle(fontSize: 34, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'OPERATOR: $operatorName',
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
              const SizedBox(height: 20),
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
                loading: () => _PlanLoadingCard(),
                error: (err, st) => _PlanErrorCard(),
                data: (plan) {
                  if (plan == null) {
                    return _NoPlanCard(onTap: () => context.goNamed(SteelRoutes.home));
                  }
                  return _LiveMissionBriefing(plan: plan);
                },
              ),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.pushNamed(SteelRoutes.onboarding),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: SteelOpsColors.borderStrong),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: SteelOpsColors.muted,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RUN SETUP',
                        style: steelMonoStyle(
                          fontSize: 11,
                          color: SteelOpsColors.muted,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OpsDeployButton(
                onPressed: () => context.pushNamed(SteelRoutes.therapySession),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Plan loading skeleton ────────────────────────────────────────────────────

class _PlanLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSION BRIEFING',
            style: steelHeadingStyle(fontSize: 20, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SteelOpsColors.orange,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Plan error state ─────────────────────────────────────────────────────────

class _PlanErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        'MISSION DATA UNAVAILABLE',
        style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
      ),
    );
  }
}

// ── No active plan CTA ───────────────────────────────────────────────────────

class _NoPlanCard extends StatelessWidget {
  const _NoPlanCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SteelOpsColors.surface,
          border: Border.all(color: SteelOpsColors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION BRIEFING',
              style: steelHeadingStyle(fontSize: 20, letterSpacing: 2),
            ),
            const SizedBox(height: 14),
            Text(
              'NO ACTIVE PROGRAM',
              style: steelMonoStyle(
                fontSize: 12,
                color: SteelOpsColors.muted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
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
                  Icon(Icons.add, color: SteelOpsColors.forge, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'START A PROGRAM',
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
    final planDaysAsync = ref.watch(planDaysProvider(plan.id));
    final completedAsync = ref.watch(completedPlanDaysProvider(plan.id));

    return planDaysAsync.when(
      loading: () => _buildShell(
        plan: plan,
        child: Center(
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
        plan: plan,
        child: Text(
          'UNABLE TO LOAD DAYS',
          style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
        ),
      ),
      data: (days) {
        final completedIds = completedAsync.valueOrNull ?? {};
        final thisWeekDays = days
            .where((d) => d.week == plan.currentWeek)
            .toList()
          ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

        // Build OpsExerciseLine entries from plan days (label + focus chips).
        final exerciseLines = thisWeekDays
            .asMap()
            .entries
            .map((entry) {
              final idx = (entry.key + 1).toString().padLeft(2, '0');
              final day = entry.value;
              final done = completedIds.contains(day.id);
              final focusStr = day.focus.isNotEmpty
                  ? day.focus.map((f) => f.toUpperCase()).join(', ')
                  : 'REST';
              return OpsExerciseLine(
                index: done ? '✓ ' : idx,
                name: day.label.toUpperCase(),
                setsReps: focusStr,
              );
            })
            .toList();

        // Build focus chips from all unique focus tags this week.
        final allFocus = thisWeekDays
            .expand((d) => d.focus)
            .map((f) => f.toUpperCase())
            .toSet()
            .toList();
        final chips = ['WEEK ${plan.currentWeek}', ...allFocus];

        final mission = OpsMissionSample(
          programTitle: plan.title.toUpperCase(),
          weekCurrent: plan.currentWeek,
          weekTotal: plan.durationWeeks,
          focusChips: chips,
          activeChipIndex: 0,
          exercises: exerciseLines,
          estimatedMinutes: thisWeekDays.length * 55,
        );

        return OpsMissionBriefing(mission: mission);
      },
    );
  }

  Widget _buildShell({required WorkoutPlan plan, required Widget child}) {
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
                'WK ${plan.currentWeek} / ${plan.durationWeeks}',
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
