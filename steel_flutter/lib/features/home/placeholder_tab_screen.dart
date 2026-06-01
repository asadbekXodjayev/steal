import 'package:flutter/material.dart';

import '../../shared/ops_theme.dart';

class PlaceholderTabScreen extends StatelessWidget {
  const PlaceholderTabScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
              'COMING ONLINE',
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
