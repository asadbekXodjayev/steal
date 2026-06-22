# STEEL (Steel Therapy) — Flutter app

## Config (no hardcoded URLs)
This app reads the PocketBase base URL from a compile-time define:

```bash
flutter run --dart-define=POCKETBASE_URL=http://34.170.155.242:8090
```

You can also use Flutter’s `--dart-define-from-file` if you prefer keeping it out of shell history:

```bash
flutter run --dart-define-from-file=env.json
```

Example `env.json` (do not commit real secrets):

```json
{ "POCKETBASE_URL": "http://34.170.155.242:8090" }
```

## Architecture
- Riverpod (`StateNotifierProvider`) for state
- `go_router` for navigation with auth redirects
- PocketBase Dart SDK with `AsyncAuthStore` persisted in `SharedPreferences`
