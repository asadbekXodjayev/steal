import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ops_theme.dart';
import '../data/dashboard_data.dart';

/// LAST SESSIONS card — the recent completed-session activity feed.
/// Mirrors the web dashboard's RecentFeed (date · day label · sets · volume).
class OpsSessionFeed extends ConsumerWidget {
  const OpsSessionFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    final progressAsync = ref.watch(progressDataProvider);

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
              Text(
                t('home.LAST_SESSIONS'),
                style: steelMonoStyle(fontSize: 10, letterSpacing: 1),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: SteelOpsColors.border)),
            ],
          ),
          const SizedBox(height: 12),
          progressAsync.when(
            loading: () => const Padding(
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
            error: (err, st) => Text(
              t('home.NO_SESSION_HISTORY'),
              style: steelMonoStyle(fontSize: 11, color: SteelOpsColors.muted),
            ),
            data: (_) {
              final activity = ref.watch(recentActivityProvider);
              if (activity.isEmpty) {
                return _EmptyFeed(label: t('home.NO_SESSION_HISTORY'));
              }
              return Column(
                children: [
                  for (var i = 0; i < activity.length; i++)
                    _FeedRow(
                      activity: activity[i],
                      setsLabel: t('home.SETS'),
                      fallbackLabel: t('home.WORKOUT'),
                      isLast: i == activity.length - 1,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(
          color: SteelOpsColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: steelMonoStyle(fontSize: 10, color: SteelOpsColors.inkDim),
        ),
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({
    required this.activity,
    required this.setsLabel,
    required this.fallbackLabel,
    required this.isLast,
  });

  final DashboardActivity activity;
  final String setsLabel;
  final String fallbackLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatTacticalDate(activity.session.effectiveDate);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: SteelOpsColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              dateStr,
              style: steelMonoStyle(fontSize: 9, color: SteelOpsColors.inkDim),
            ),
          ),
          Expanded(
            child: Text(
              activity.dayLabel.isNotEmpty ? activity.dayLabel : fallbackLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: steelMonoStyle(
                fontSize: 11,
                color: SteelOpsColors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${activity.setCount} $setsLabel',
            style: steelMonoStyle(fontSize: 9, color: SteelOpsColors.inkDim),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              activity.volumeLabel,
              textAlign: TextAlign.right,
              style: steelMonoStyle(
                fontSize: 10,
                color: SteelOpsColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
