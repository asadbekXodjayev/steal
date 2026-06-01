import 'package:flutter/material.dart';

import '../ops_theme.dart';

class SteelForgeButton extends StatelessWidget {
  const SteelForgeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label.toUpperCase()),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ],
          );

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: SteelOpsColors.forge,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class SteelGhostButton extends StatelessWidget {
  const SteelGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: SteelOpsColors.muted,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: Color(0x29FFFFFF)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(label.toUpperCase()),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
