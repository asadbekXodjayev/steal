import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ops_theme.dart';
import '../data/dashboard_data.dart';
import '../data/ops_dashboard_sample.dart';

/// The MISSION BRIEFING card shell: header, program title, week, goal type,
/// a [child] (the next-session body), and the weekly schedule strip.
class OpsMissionShell extends ConsumerWidget {
  const OpsMissionShell({
    super.key,
    required this.title,
    required this.weekLabel,
    required this.goalType,
    required this.child,
    required this.schedule,
  });

  final String title;
  final String weekLabel;
  final String goalType;
  final Widget child;
  final List<ScheduleEntry> schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final goal = goalType.isEmpty
        ? ''
        : ' · ${goalType.replaceAll('_', ' ').toUpperCase()}';

    return Container(
      decoration: BoxDecoration(
        color: SteelOpsColors.surface,
        border: Border.all(color: SteelOpsColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('home.MISSION_BRIEFING'),
                  style: steelHeadingStyle(fontSize: 20, letterSpacing: 2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SteelOpsColors.tactical.withValues(alpha: 0.25),
                  border: Border.all(
                    color: SteelOpsColors.green.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  t('home.ACTIVE'),
                  style: steelMonoStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SteelOpsColors.green,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: steelHeadingStyle(fontSize: 26, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            '$weekLabel$goal',
            style: steelMonoStyle(fontSize: 10),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: SteelOpsColors.border),
          const SizedBox(height: 12),
          child,
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ScheduleStrip(schedule: schedule),
          ],
        ],
      ),
    );
  }
}

/// The next-session body: DAY label + focus chips, the exercise list and the
/// estimated session time. Mirrors web `ActiveMissionPanel`.
class OpsNextSessionBody extends ConsumerWidget {
  const OpsNextSessionBody({
    super.key,
    required this.dayLabel,
    required this.focus,
    required this.lines,
    required this.estimatedMinutes,
  });

  final String dayLabel;
  final List<String> focus;
  final List<OpsExerciseLine> lines;
  final int estimatedMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              t('home.DAY'),
              style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.inkDim),
            ),
            Text(
              dayLabel,
              style: steelMonoStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: SteelOpsColors.inkHigh,
              ),
            ),
            ...focus.map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: SteelOpsColors.border),
                  ),
                  child: Text(
                    f.toUpperCase(),
                    style: steelMonoStyle(
                      fontSize: 10,
                      color: SteelOpsColors.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        if (lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              t('home.NO_TRAINING_DAYS'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
            ),
          )
        else ...[
          ...lines.take(6).map((e) => _ExerciseRow(line: e)),
          if (lines.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 28),
              child: Text(
                '+${lines.length - 6} ${t('home.MORE')}',
                style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.inkDim),
              ),
            ),
        ],
        if (estimatedMinutes > 0) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${t('home.EST_MIN')} ~$estimatedMinutes ${t('home.MIN')}',
              style: steelMonoStyle(fontSize: 11),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.line});
  final OpsExerciseLine line;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  line.index,
                  style: steelMonoStyle(
                    fontSize: 11,
                    color: SteelOpsColors.forge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  line.name,
                  style: steelMonoStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: SteelOpsColors.inkHigh,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                line.setsReps,
                style: steelMonoStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: SteelOpsColors.border.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

/// The weekly schedule strip: UPCOMING (next + locked) and DONE rows.
class _ScheduleStrip extends ConsumerWidget {
  const _ScheduleStrip({required this.schedule});
  final List<ScheduleEntry> schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final upcoming = schedule.where((e) => !e.isCompleted).toList();
    final completed = schedule.where((e) => e.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (upcoming.isNotEmpty) ...[
          _StripHeader(label: t('home.UPCOMING'), color: SteelOpsColors.orange),
          const SizedBox(height: 8),
          ...upcoming.map((e) => _ScheduleRow(entry: e, t: t)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 12),
          _StripHeader(label: t('home.DONE'), color: SteelOpsColors.green),
          const SizedBox(height: 8),
          ...completed.map((e) => _ScheduleRow(entry: e, t: t)),
        ],
      ],
    );
  }
}

class _StripHeader extends StatelessWidget {
  const _StripHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: steelMonoStyle(fontSize: 10, color: color, letterSpacing: 1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: SteelOpsColors.border),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.entry, required this.t});
  final ScheduleEntry entry;
  final String Function(String) t;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData icon;
    if (entry.isCompleted) {
      iconColor = SteelOpsColors.green;
      icon = Icons.check_circle_outline;
    } else if (entry.isLocked) {
      iconColor = SteelOpsColors.inkDim;
      icon = Icons.lock_outline;
    } else {
      iconColor = SteelOpsColors.orange;
      icon = Icons.event_outlined;
    }

    final String? tag = entry.isCompleted
        ? t('home.DONE')
        : entry.isNext
            ? t('home.NEXT')
            : entry.isLocked
                ? t('home.LOCKED')
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SteelOpsColors.surfaceElevated,
        border: Border.all(color: SteelOpsColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.dayLabel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: steelMonoStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: entry.isLocked
                              ? SteelOpsColors.inkDim
                              : SteelOpsColors.inkHigh,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        tag,
                        style: steelMonoStyle(
                          fontSize: 9,
                          color: iconColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
                if (entry.focus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.focus
                          .take(3)
                          .map((f) => f.toUpperCase())
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: steelMonoStyle(
                        fontSize: 8,
                        color: SteelOpsColors.inkDim,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (entry.dateLabel != null && !entry.isLocked) ...[
            const SizedBox(width: 8),
            Text(
              entry.dateLabel!,
              style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.inkDim),
            ),
          ],
        ],
      ),
    );
  }
}
