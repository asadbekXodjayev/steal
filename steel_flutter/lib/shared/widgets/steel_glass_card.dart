import 'dart:ui';

import 'package:flutter/material.dart';

import '../ops_theme.dart';

class SteelGlassCard extends StatelessWidget {
  const SteelGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.accented = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accented;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: accented ? SteelOpsColors.taglineBg : SteelOpsColors.glassBg,
            border: Border.all(
              color: accented ? SteelOpsColors.taglineBorder : SteelOpsColors.glassBorder,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
