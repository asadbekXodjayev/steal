import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../landing/landing_screen.dart';
import 'home_screen.dart';

/// Routes `/` to landing (guest) or dashboard shell (signed in).
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return switch (auth.status) {
      AuthStatus.unknown => const Scaffold(
          backgroundColor: Color(0xFF050505),
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => const HomeScreen(),
      AuthStatus.unauthenticated => const LandingScreen(),
    };
  }
}
