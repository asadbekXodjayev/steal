import 'package:flutter/material.dart';

/// A KPI stat card model (live data is supplied by the dashboard view).
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

/// A single exercise line in the mission briefing.
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
