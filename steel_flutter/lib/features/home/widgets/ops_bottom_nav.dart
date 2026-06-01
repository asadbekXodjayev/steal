import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/ops_theme.dart';

class OpsBottomNav extends StatelessWidget {
  const OpsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = <_NavSpec>[
    _NavSpec('HOME', Icons.grid_view_rounded),
    _NavSpec('PROGRAMS', Icons.view_list_rounded),
    _NavSpec('PLANS', Icons.description_outlined),
    _NavSpec('STATS', Icons.show_chart_rounded),
    _NavSpec('LIBRARY', Icons.menu_book_outlined),
    _NavSpec('GEAR', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          color: const Color(0xD9050505),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x0FFFFFFF))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(_items.length, (i) {
                  final spec = _items[i];
                  final selected = i == currentIndex;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              spec.icon,
                              size: 22,
                              color: selected ? SteelOpsColors.forge : SteelOpsColors.inkDim,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              spec.label,
                              style: steelMonoStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: selected ? SteelOpsColors.forge : SteelOpsColors.inkDim,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 28,
                              color: selected ? SteelOpsColors.forge : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.label, this.icon);
  final String label;
  final IconData icon;
}
