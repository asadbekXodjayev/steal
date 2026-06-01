import 'package:flutter/material.dart';

import 'steel_forge_button.dart';

class SteelPrimaryButton extends StatelessWidget {
  const SteelPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SteelForgeButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
