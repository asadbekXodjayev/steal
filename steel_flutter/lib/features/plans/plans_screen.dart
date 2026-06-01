// lib/features/plans/plans_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../programs/build_program_screen.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setActive(WorkoutPlan plan) async {
    try {
      await ref.read(repositoryProvider).updatePlanStatus(plan.id, 'active');
      ref.invalidate(plansProvider);
      ref.invalidate(activePlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.surface,
            content: Text(
              '${plan.title.toUpperCase()} SET AS ACTIVE',
              style: steelMonoStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.rust,
            content: Text('ERROR: $e',
                style: steelMonoStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      }
    }
  }

  Future<void> _archivePlan(WorkoutPlan plan) async {
    try {
      await ref.read(repositoryProvider).updatePlanStatus(plan.id, 'archived');
      ref.invalidate(plansProvider);
      ref.invalidate(activePlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.surface,
            content: Text(
              '${plan.title.toUpperCase()} ARCHIVED',
              style: steelMonoStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.rust,
            content: Text('ERROR: $e',
                style: steelMonoStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      }
    }
  }

  Future<void> _deletePlan(WorkoutPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteelOpsColors.surface,
        title: Text(
          'DELETE PROGRAM?',
          style: steelHeadingStyle(fontSize: 18),
        ),
        content: Text(
          'This will permanently delete "${plan.title}" and all its days and exercises.',
          style: steelMonoStyle(
              fontSize: 12, color: SteelOpsColors.inkMid, letterSpacing: 0.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL',
                style:
                    steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
                style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.rust)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref.read(repositoryProvider).deletePlan(plan.id);
      ref.invalidate(plansProvider);
      ref.invalidate(activePlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.surface,
            content: Text(
              '${plan.title.toUpperCase()} DELETED',
              style: steelMonoStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.rust,
            content: Text('ERROR: $e',
                style: steelMonoStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      }
    }
  }

  void _openBuildScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BuildProgramScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROGRAMS',
                          style: steelHeadingStyle(
                              fontSize: 42, fontWeight: FontWeight.w900),
                        ),
                        Container(
                          width: 48,
                          height: 3,
                          margin: const EdgeInsets.only(top: 4),
                          color: SteelOpsColors.orange,
                        ),
                      ],
                    ),
                  ),
                  _FilledActionButton(
                    icon: Icons.edit_outlined,
                    label: 'BUILD',
                    onTap: _openBuildScreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Tab bar ─────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: SteelOpsColors.surface,
                border: Border.all(color: SteelOpsColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: SteelOpsColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(3),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: steelMonoStyle(
                  fontSize: 11,
                  color: SteelOpsColors.orange,
                  letterSpacing: 1.5,
                ),
                unselectedLabelStyle: steelMonoStyle(
                  fontSize: 11,
                  color: SteelOpsColors.muted,
                  letterSpacing: 1.5,
                ),
                labelColor: SteelOpsColors.orange,
                unselectedLabelColor: SteelOpsColors.muted,
                tabs: const [
                  Tab(text: 'ACTIVE'),
                  Tab(text: 'ALL PROGRAMS'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab content ─────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Active plans
                  plansAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: SteelEmptyState(
                        title: 'Could not load programs',
                        subtitle: '$err',
                        icon: Icons.cloud_off,
                        actionLabel: 'RETRY',
                        onAction: () => ref.invalidate(plansProvider),
                      ),
                    ),
                    data: (plans) {
                      final active = plans
                          .where((p) => p.status == 'active')
                          .toList();
                      if (active.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(plansProvider),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 40),
                              child: Center(
                                child: SteelEmptyState(
                                  title: 'No active program',
                                  subtitle:
                                      'Build a custom plan or start a template to begin training.',
                                  actionLabel: 'BUILD A PROGRAM',
                                  onAction: _openBuildScreen,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => ref.invalidate(plansProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: active.length,
                          itemBuilder: (_, i) => _PlanCard(
                            plan: active[i],
                            onSetActive: () => _setActive(active[i]),
                            onArchive: () => _archivePlan(active[i]),
                            onDelete: () => _deletePlan(active[i]),
                          ),
                        ),
                      );
                    },
                  ),

                  // Tab 1: All plans
                  plansAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: SteelEmptyState(
                        title: 'Could not load programs',
                        subtitle: '$err',
                        icon: Icons.cloud_off,
                        actionLabel: 'RETRY',
                        onAction: () => ref.invalidate(plansProvider),
                      ),
                    ),
                    data: (plans) {
                      if (plans.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(plansProvider),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 40),
                              child: Center(
                                child: SteelEmptyState(
                                  title: 'No programs yet',
                                  subtitle:
                                      'Build your own or pick a template.',
                                  actionLabel: 'BUILD A PROGRAM',
                                  onAction: _openBuildScreen,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => ref.invalidate(plansProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: plans.length,
                          itemBuilder: (_, i) => _PlanCard(
                            plan: plans[i],
                            onSetActive: () => _setActive(plans[i]),
                            onArchive: () => _archivePlan(plans[i]),
                            onDelete: () => _deletePlan(plans[i]),
                          ),
                        ),
                      );
                    },
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

// ── Plan Card ────────────────────────────────────────────────────

class _PlanCard extends ConsumerStatefulWidget {
  const _PlanCard({
    required this.plan,
    required this.onSetActive,
    required this.onArchive,
    required this.onDelete,
  });

  final WorkoutPlan plan;
  final VoidCallback onSetActive;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  ConsumerState<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<_PlanCard> {
  bool _expanded = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return SteelOpsColors.green;
      case 'archived':
        return SteelOpsColors.inkDim;
      case 'completed':
        return SteelOpsColors.blue;
      default:
        return SteelOpsColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;
    final daysAsync = _expanded
        ? ref.watch(planDaysProvider(p.id))
        : const AsyncData<List<PlanDay>>([]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(
          color: p.isActive ? SteelOpsColors.orange : SteelOpsColors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // ── Card header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge + source
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            color: _statusColor(p.status).withValues(alpha: 0.15),
                            child: Text(
                              p.status.toUpperCase(),
                              style: steelMonoStyle(
                                fontSize: 8,
                                color: _statusColor(p.status),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.source.toUpperCase(),
                            style: steelMonoStyle(
                                fontSize: 8, color: SteelOpsColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        p.title,
                        style: steelHeadingStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      // Goal type
                      if (p.goalType.isNotEmpty)
                        Text(
                          p.goalType
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: steelMonoStyle(
                              fontSize: 9, color: SteelOpsColors.muted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Week progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'WEEK',
                      style: steelMonoStyle(
                          fontSize: 8, color: SteelOpsColors.muted),
                    ),
                    Text(
                      '${p.currentWeek}/${p.durationWeeks}',
                      style:
                          steelHeadingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    // Menu
                    PopupMenuButton<String>(
                      color: SteelOpsColors.surfaceElevated,
                      icon: Icon(Icons.more_vert,
                          color: SteelOpsColors.muted, size: 18),
                      onSelected: (value) {
                        switch (value) {
                          case 'active':
                            widget.onSetActive();
                          case 'archive':
                            widget.onArchive();
                          case 'delete':
                            widget.onDelete();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem<String>(
                          value: 'active',
                          child: Text('SET ACTIVE',
                              style: steelMonoStyle(
                                  fontSize: 11, color: SteelOpsColors.green)),
                        ),
                        PopupMenuItem<String>(
                          value: 'archive',
                          child: Text('ARCHIVE',
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid)),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('DELETE',
                              style: steelMonoStyle(
                                  fontSize: 11, color: SteelOpsColors.rust)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Expand toggle ────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: SteelOpsColors.border),
                ),
                color: SteelOpsColors.background,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'HIDE DAYS' : 'VIEW DAYS',
                    style: steelMonoStyle(
                        fontSize: 9,
                        color: SteelOpsColors.muted,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: SteelOpsColors.muted,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded plan days ───────────────────────────────
          if (_expanded)
            daysAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Could not load days: $err',
                    style: steelMonoStyle(
                        fontSize: 10, color: SteelOpsColors.rust)),
              ),
              data: (days) {
                if (days.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No training days found.',
                      style: steelMonoStyle(
                          fontSize: 11, color: SteelOpsColors.muted),
                    ),
                  );
                }
                // Show only current week's days
                final currentDays = days
                    .where((d) => d.week == p.currentWeek)
                    .toList()
                  ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
                final displayDays =
                    currentDays.isNotEmpty ? currentDays : days.take(7).toList();
                return Column(
                  children: displayDays.map((day) {
                    const dayNames = [
                      'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
                    ];
                    final dayName = day.dayOfWeek >= 1 && day.dayOfWeek <= 7
                        ? dayNames[day.dayOfWeek - 1]
                        : 'D${day.dayOfWeek}';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: SteelOpsColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              dayName,
                              style: steelMonoStyle(
                                fontSize: 10,
                                color: SteelOpsColors.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              day.label.isNotEmpty
                                  ? day.label.toUpperCase()
                                  : 'TRAINING',
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid),
                            ),
                          ),
                          if (day.focus.isNotEmpty)
                            Text(
                              day.focus.take(2).join(' · ').toUpperCase(),
                              style: steelMonoStyle(
                                  fontSize: 8,
                                  color: SteelOpsColors.muted),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SteelOpsColors.orange,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: steelMonoStyle(
                  fontSize: 10, color: Colors.white, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
