import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ops_theme.dart';

class OpsBottomNav extends ConsumerWidget {
  const OpsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  // Tab order matches HomeScreen's IndexedStack children.
  static const _items = <_NavSpec>[
    _NavSpec('nav.HOME', Icons.grid_view_rounded),
    _NavSpec('nav.PROGRAMS', Icons.view_list_rounded),
    _NavSpec('nav.PLANS', Icons.description_outlined),
    _NavSpec('nav.LIBRARY', Icons.menu_book_outlined),
    // Stats merged into the GEAR (profile) tab — see GearScreen.
    _NavSpec('nav.GEAR', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
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
                              t(spec.labelKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
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
  const _NavSpec(this.labelKey, this.icon);
  final String labelKey;
  final IconData icon;
}
