// Localization scan-pass additions — Auth + Onboarding + Gear + Landing + Shared widgets.
// Keys deep-merged into base strings. Every key MUST exist in EN, RU and UZ.
//
// Scan result: the auth / onboarding / gear / landing screens were already fully
// localized. The only leftover hardcoded user-facing string was the default
// "Retry" label baked into SteelAsyncBody (lib/shared/widgets/steel_async_body.dart),
// which now resolves through the existing base key `common.RETRY` — no new key
// needed. These maps stay empty (deep-merge tolerates empty additions).
const Map<String, dynamic> scanAuthEn = {};
const Map<String, dynamic> scanAuthRu = {};
const Map<String, dynamic> scanAuthUz = {};
