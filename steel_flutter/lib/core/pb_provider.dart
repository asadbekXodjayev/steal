import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../features/auth/auth_provider.dart';

/// The live PocketBase client.
///
/// Overridden in `main()` with the initialised singleton from
/// [SteelPocketBase.instance]. Reading it before the override throws, which is
/// intentional — it means the app forgot to wire the override.
final pocketbaseProvider = Provider<PocketBase>(
  (ref) => throw UnimplementedError(
    'pocketbaseProvider must be overridden in main() with the PB instance',
  ),
);

/// Current authenticated user id (null when signed out). Recomputed whenever the
/// PocketBase auth store changes, so dependent providers refetch on login/logout.
final currentUserIdProvider = Provider<String?>((ref) {
  // Recompute whenever auth state flips (login / logout / restore).
  final auth = ref.watch(authProvider);
  if (auth.status != AuthStatus.authenticated) return null;
  final pb = ref.watch(pocketbaseProvider);
  return pb.authStore.isValid ? pb.authStore.record?.id : null;
});
