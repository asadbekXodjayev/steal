import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PocketBase client singleton for the whole app.
///
/// - Uses [AsyncAuthStore] backed by SharedPreferences for persisted sessions.
/// - A native app talks to PocketBase **directly** (no `/pb` proxy — that only
///   exists to dodge browser mixed-content rules on the web build).
///
/// The base URL can be overridden at build/run time without touching code:
///   flutter run --dart-define=POCKETBASE_URL=http://host:8090
/// If no override is provided, [_defaultBaseUrl] is used.
class SteelPocketBase {
  SteelPocketBase._();

  static PocketBase? _pb;

  /// Default backend — the same PocketBase instance the web app points at
  /// (`NEXT_PUBLIC_API_URL`). Override per-environment with `--dart-define`.
  static const String _defaultBaseUrl = 'http://34.56.67.158:8090';

  /// Optional compile-time override.
  static const String _envBaseUrl = String.fromEnvironment('POCKETBASE_URL');

  /// Resolved base URL: the `--dart-define` value if present, else the default.
  static String get baseUrl =>
      _envBaseUrl.trim().isEmpty ? _defaultBaseUrl : _envBaseUrl.trim();

  static Future<PocketBase> instance() async {
    final existing = _pb;
    if (existing != null) return existing;

    final prefs = await SharedPreferences.getInstance();
    final store = AsyncAuthStore(
      initial: prefs.getString('pb_auth'),
      save: (data) async => prefs.setString('pb_auth', data),
      clear: () async => prefs.remove('pb_auth'),
    );

    final pb = PocketBase(baseUrl, authStore: store);
    _pb = pb;
    return pb;
  }

  /// Clear the cached client + persisted auth (used on logout).
  static Future<void> reset() async {
    _pb?.authStore.clear();
    _pb = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pb_auth');
  }
}
