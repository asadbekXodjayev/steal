import 'package:flutter/material.dart';

/// Standard loading / error / data layout for feature screens.
class SteelAsyncBody<T> extends StatelessWidget {
  const SteelAsyncBody({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.builder,
    this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final value = data;
    if (value == null) {
      return const SizedBox.shrink();
    }
    return builder(context, value);
  }
}
