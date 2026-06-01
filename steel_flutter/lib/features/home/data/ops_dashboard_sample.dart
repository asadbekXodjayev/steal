import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';

class OpsStatItem {
  const OpsStatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;
  final Color valueColor;
}

class OpsExerciseLine {
  const OpsExerciseLine({
    required this.index,
    required this.name,
    required this.setsReps,
  });

  final String index;
  final String name;
  final String setsReps;
}

class OpsMissionSample {
  const OpsMissionSample({
    required this.programTitle,
    required this.weekCurrent,
    required this.weekTotal,
    required this.focusChips,
    required this.activeChipIndex,
    required this.exercises,
    required this.estimatedMinutes,
  });

  final String programTitle;
  final int weekCurrent;
  final int weekTotal;
  final List<String> focusChips;
  final int activeChipIndex;
  final List<OpsExerciseLine> exercises;
  final int estimatedMinutes;
}

OpsMissionSample defaultOpsMission() {
  return const OpsMissionSample(
    programTitle: 'PUSH PULL LEGS',
    weekCurrent: 2,
    weekTotal: 10,
    focusChips: ['DAY PUSH', 'CHEST', 'SHOULDERS', 'TRICEPS'],
    activeChipIndex: 0,
    exercises: [
      OpsExerciseLine(index: '01', name: 'INCLINE BARBELL BENCH PRESS', setsReps: '2 x 6-10'),
      OpsExerciseLine(index: '02', name: 'PECK DECK (BUTTERFLY)', setsReps: '2 x 7-12'),
      OpsExerciseLine(index: '03', name: 'CABLE FLY (LOWER PECS)', setsReps: '2 x 8-12'),
      OpsExerciseLine(index: '04', name: 'TRICEPS PUSH DOWN', setsReps: '3 x 7-12'),
      OpsExerciseLine(index: '05', name: 'ONE HAND PUSH DOWN', setsReps: '2 x 8-12'),
      OpsExerciseLine(index: '06', name: 'SIDE DELT', setsReps: '4 x 8-12'),
    ],
    estimatedMinutes: 56,
  );
}

List<OpsStatItem> defaultOpsStats() {
  return const [
    OpsStatItem(
      label: 'CURRENT STREAK',
      value: '0',
      unit: 'DAYS',
      accent: SteelOpsColors.green,
      valueColor: SteelOpsColors.green,
    ),
    OpsStatItem(
      label: 'THIS WEEK',
      value: '0',
      unit: 'SESSIONS',
      accent: SteelOpsColors.orange,
      valueColor: SteelOpsColors.orange,
    ),
    OpsStatItem(
      label: 'TOTAL VOLUME',
      value: '73',
      unit: 'TONNES LIFTED',
      accent: SteelOpsColors.orange,
      valueColor: SteelOpsColors.orange,
    ),
    OpsStatItem(
      label: 'PRS THIS MONTH',
      value: '0',
      unit: 'RECORDS SET',
      accent: SteelOpsColors.blue,
      valueColor: SteelOpsColors.blue,
    ),
  ];
}
