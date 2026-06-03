// lib/features/plans/plans_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
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
    final t = ref.read(tProvider);
    try {
      await ref.read(repositoryProvider).updatePlanStatus(plan.id, 'active');
      ref.invalidate(plansProvider);
      ref.invalidate(activePlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.surface,
            content: Text(
              '${plan.title.toUpperCase()} ${t('plans.SET_AS_ACTIVE_MSG')}',
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
            content: Text('${t('common.ERROR')}: $e',
                style: steelMonoStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      }
    }
  }

  Future<void> _archivePlan(WorkoutPlan plan) async {
    final t = ref.read(tProvider);
    try {
      await ref.read(repositoryProvider).updatePlanStatus(plan.id, 'archived');
      ref.invalidate(plansProvider);
      ref.invalidate(activePlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SteelOpsColors.surface,
            content: Text(
              '${plan.title.toUpperCase()} ${t('plans.ARCHIVED_MSG')}',
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
            content: Text('${t('common.ERROR')}: $e',
                style: steelMonoStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      }
    }
  }

  Future<void> _deletePlan(WorkoutPlan plan) async {
    final t = ref.read(tProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteelOpsColors.surface,
        title: Text(
          t('plans.DELETE_PROGRAM'),
          style: steelHeadingStyle(fontSize: 18),
        ),
        content: Text(
          t('plans.DELETE_PROGRAM_DESC').replaceFirst('{title}', plan.title),
          style: steelMonoStyle(
              fontSize: 12, color: SteelOpsColors.inkMid, letterSpacing: 0.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('common.CANCEL'),
                style:
                    steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('common.DELETE'),
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
              '${plan.title.toUpperCase()} ${t('plans.DELETED_MSG')}',
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
            content: Text('${t('common.ERROR')}: $e',
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
    final t = ref.watch(tProvider);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title gets the full width so the heading never wraps mid-word.
                  Text(
                    t('plans.TITLE'),
                    style: steelHeadingStyle(
                        fontSize: 42, fontWeight: FontWeight.w900),
                  ),
                  Container(
                    width: 48,
                    height: 3,
                    margin: const EdgeInsets.only(top: 4),
                    color: SteelOpsColors.orange,
                  ),
                  const SizedBox(height: 14),
                  // Actions on their own row, right-aligned.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _GhostActionButton(
                        icon: Icons.bolt,
                        label: t('quick.TITLE'),
                        onTap: () =>
                            context.pushNamed(SteelRoutes.quickSession),
                      ),
                      const SizedBox(width: 8),
                      _FilledActionButton(
                        icon: Icons.edit_outlined,
                        label: t('plans.BUILD'),
                        onTap: _openBuildScreen,
                      ),
                    ],
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
                tabs: [
                  Tab(text: t('plans.TAB_ACTIVE')),
                  Tab(text: t('plans.TAB_ALL')),
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
                        title: t('plans.COULD_NOT_LOAD'),
                        subtitle: '$err',
                        icon: Icons.cloud_off,
                        actionLabel: t('common.RETRY'),
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
                                  title: t('plans.NO_ACTIVE_TITLE'),
                                  subtitle: t('plans.NO_ACTIVE_DESC'),
                                  actionLabel: t('plans.BUILD_A_PROGRAM'),
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
                        title: t('plans.COULD_NOT_LOAD'),
                        subtitle: '$err',
                        icon: Icons.cloud_off,
                        actionLabel: t('common.RETRY'),
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
                                  title: t('plans.NO_PLANS_TITLE'),
                                  subtitle: t('plans.NO_PLANS_DESC'),
                                  actionLabel: t('plans.BUILD_A_PROGRAM'),
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

  String _statusLabel(String Function(String) t, String status) {
    switch (status) {
      case 'active':
        return t('plans.STATUS_ACTIVE');
      case 'archived':
        return t('plans.STATUS_ARCHIVED');
      case 'completed':
        return t('plans.STATUS_COMPLETED');
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(tProvider);
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
                              _statusLabel(t, p.status),
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
                      t('plans.WEEK'),
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
                          child: Text(t('plans.SET_ACTIVE'),
                              style: steelMonoStyle(
                                  fontSize: 11, color: SteelOpsColors.green)),
                        ),
                        PopupMenuItem<String>(
                          value: 'archive',
                          child: Text(t('plans.ARCHIVE'),
                              style: steelMonoStyle(
                                  fontSize: 11,
                                  color: SteelOpsColors.inkMid)),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(t('plans.DELETE'),
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
                    _expanded ? t('plans.HIDE_DAYS') : t('plans.VIEW_DAYS'),
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
                child: Text('${t('plans.COULD_NOT_LOAD_DAYS')}: $err',
                    style: steelMonoStyle(
                        fontSize: 10, color: SteelOpsColors.rust)),
              ),
              data: (days) {
                if (days.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      t('plans.NO_DAYS'),
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
                    final dayName = day.dayOfWeek >= 1 && day.dayOfWeek <= 7
                        ? t('plans.DOW_${day.dayOfWeek}')
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
                                  : t('plans.TRAINING'),
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

// ── Ghost action button (outline) ─────────────────────────────────

class _GhostActionButton extends StatelessWidget {
  const _GhostActionButton({
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
          border: Border.all(color: SteelOpsColors.borderStrong),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: SteelOpsColors.orange, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: steelMonoStyle(
                  fontSize: 10,
                  color: SteelOpsColors.inkMid,
                  letterSpacing: 1),
            ),
          ],
        ),
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
