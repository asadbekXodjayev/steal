import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/pb_provider.dart';
import 'core/pocketbase.dart';
import 'core/router.dart';
import 'data/providers.dart' show languageProvider;
import 'l10n/app_localizations.dart';
import 'shared/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the PocketBase client once (restores any persisted session)
  // and make it available to every provider via an override.
  final pb = await SteelPocketBase.instance();

  // Restore the user's saved language before the first frame.
  final savedLanguage = await loadSavedLanguage();

  runApp(
    ProviderScope(
      overrides: [
        pocketbaseProvider.overrideWithValue(pb),
        languageProvider.overrideWith((ref) => savedLanguage),
      ],
      child: const SteelApp(),
    ),
  );
}

class SteelApp extends ConsumerWidget {
  const SteelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'STEEL',
      debugShowCheckedModeBanner: false,
      theme: buildSteelTheme(),
      locale: Locale(lang),
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Material/Cupertino bundles may not ship every supported app language
      // (e.g. uz). Fall back to English for framework strings while our own
      // strings still honour the chosen language.
      localeResolutionCallback: (locale, supported) {
        for (final l in supported) {
          if (l.languageCode == lang) return l;
        }
        return const Locale('en');
      },
      routerConfig: router,
    );
  }
}
