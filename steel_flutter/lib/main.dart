import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/pb_provider.dart';
import 'core/pocketbase.dart';
import 'core/router.dart';
import 'shared/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the PocketBase client once (restores any persisted session)
  // and make it available to every provider via an override.
  final pb = await SteelPocketBase.instance();

  runApp(
    ProviderScope(
      overrides: [pocketbaseProvider.overrideWithValue(pb)],
      child: const SteelApp(),
    ),
  );
}

class SteelApp extends ConsumerWidget {
  const SteelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'STEEL',
      debugShowCheckedModeBanner: false,
      theme: buildSteelTheme(),
      routerConfig: router,
    );
  }
}
