import 'package:flutter/material.dart';

import '../ops_theme.dart';
import 'steel_forge_button.dart';

class SteelEmptyState extends StatelessWidget {
  const SteelEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.fitness_center_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: SteelOpsColors.forge),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: steelHeadingStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: steelMonoStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            SteelForgeButton(
              label: actionLabel!,
              expanded: false,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
