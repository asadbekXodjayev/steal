import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';

class PlaceholderTabScreen extends ConsumerWidget {
  const PlaceholderTabScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(tProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: steelHeadingStyle(fontSize: 28, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              t('home.PLACEHOLDER_ONLINE'),
              style: steelMonoStyle(
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
