import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';
import '../data/ops_dashboard_sample.dart';

class OpsMissionBriefing extends StatefulWidget {
  const OpsMissionBriefing({super.key, required this.mission});

  final OpsMissionSample mission;

  @override
  State<OpsMissionBriefing> createState() => _OpsMissionBriefingState();
}

class _OpsMissionBriefingState extends State<OpsMissionBriefing> {
  late int _chipIndex;

  @override
  void initState() {
    super.initState();
    _chipIndex = widget.mission.activeChipIndex;
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
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
                  'MISSION BRIEFING',
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
                  'ACTIVE',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  mission.programTitle,
                  style: steelHeadingStyle(fontSize: 26, height: 1),
                ),
              ),
              Text(
                'WK ${mission.weekCurrent} / ${mission.weekTotal}',
                style: steelMonoStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(mission.focusChips.length, (i) {
                final selected = i == _chipIndex;
                final label = mission.focusChips[i];
                return Padding(
                  padding: EdgeInsets.only(
                    right: i == mission.focusChips.length - 1 ? 0 : 8,
                  ),
                  child: Material(
                    color: selected ? SteelOpsColors.inkHigh : SteelOpsColors.surfaceElevated,
                    child: InkWell(
                      onTap: () => setState(() => _chipIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? SteelOpsColors.inkHigh : SteelOpsColors.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: steelMonoStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: selected ? SteelOpsColors.background : SteelOpsColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          ...mission.exercises.map((e) => _OpsExerciseRow(line: e)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'EST ~${mission.estimatedMinutes} MIN',
              style: steelMonoStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpsExerciseRow extends StatelessWidget {
  const _OpsExerciseRow({required this.line});

  final OpsExerciseLine line;

  @override
  Widget build(BuildContext context) {
    final compact = line.setsReps.replaceAll(' ', '');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                compact,
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
