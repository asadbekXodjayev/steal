import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/providers.dart' show languageProvider;
import 'additions/index.dart';

/// Supported app languages — single source of truth.
const List<String> kSupportedLanguages = ['en', 'ru', 'uz'];

/// Language a fresh install starts in (before the user picks one).
const String kInitialLanguage = 'ru';

/// Language used as the lookup fallback when a key is missing in the active
/// language. English is the most complete locale, so keep it as the fallback.
const String kDefaultLanguage = 'en';

const String kLanguagePrefKey = 'language';

const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('uz'),
];

/// Human-readable language names for the settings switcher.
const Map<String, String> kLanguageNames = {
  'en': 'English',
  'ru': 'Русский',
  'uz': "O'zbek",
};

// ── Base strings ─────────────────────────────────────────────────────────────
// Shared, app-wide strings. Feature-specific strings live in l10n/additions/*.

const Map<String, dynamic> _baseEn = {
  'nav': {
    'HOME': 'HOME',
    'PROGRAMS': 'PROGRAMS',
    'PLANS': 'PLANS',
    'TRAIN': 'TRAIN',
    'LIBRARY': 'LIBRARY',
    'STATS': 'STATS',
    'GEAR': 'GEAR',
  },
  'common': {
    'LOADING': 'Loading...',
    'ERROR': 'Error',
    'RETRY': 'RETRY',
    'SAVE': 'SAVE',
    'CANCEL': 'CANCEL',
    'CLOSE': 'Close',
    'CONFIRM': 'CONFIRM',
    'DELETE': 'DELETE',
    'EDIT': 'EDIT',
    'BACK': 'BACK',
    'NEXT': 'NEXT',
    'DONE': 'DONE',
    'EMPTY': 'Nothing here yet',
    'TODAY': 'Today',
    'YESTERDAY': 'Yesterday',
  },
  'settings': {
    'TITLE': 'SETTINGS',
    'LANGUAGE': 'LANGUAGE',
    'LANGUAGE_DESC': 'Choose your interface language',
  },
};

const Map<String, dynamic> _baseRu = {
  'nav': {
    'HOME': 'ГЛАВНАЯ',
    'PROGRAMS': 'ПРОГРАММЫ',
    'PLANS': 'ПЛАНЫ',
    'TRAIN': 'ТРЕНИРОВКА',
    'LIBRARY': 'БИБЛИОТЕКА',
    'STATS': 'СТАТИСТИКА',
    'GEAR': 'СНАРЯЖЕНИЕ',
  },
  'common': {
    'LOADING': 'Загрузка...',
    'ERROR': 'Ошибка',
    'RETRY': 'ПОВТОРИТЬ',
    'SAVE': 'СОХРАНИТЬ',
    'CANCEL': 'ОТМЕНА',
    'CLOSE': 'Закрыть',
    'CONFIRM': 'ПОДТВЕРДИТЬ',
    'DELETE': 'УДАЛИТЬ',
    'EDIT': 'ИЗМЕНИТЬ',
    'BACK': 'НАЗАД',
    'NEXT': 'ДАЛЕЕ',
    'DONE': 'ГОТОВО',
    'EMPTY': 'Здесь пока пусто',
    'TODAY': 'Сегодня',
    'YESTERDAY': 'Вчера',
  },
  'settings': {
    'TITLE': 'НАСТРОЙКИ',
    'LANGUAGE': 'ЯЗЫК',
    'LANGUAGE_DESC': 'Выберите язык интерфейса',
  },
};

const Map<String, dynamic> _baseUz = {
  'nav': {
    'HOME': 'BOSH SAHIFA',
    'PROGRAMS': 'DASTURLAR',
    'PLANS': 'REJALAR',
    'TRAIN': 'MASHQ',
    'LIBRARY': 'KUTUBXONA',
    'STATS': 'STATISTIKA',
    'GEAR': 'JIHOZLAR',
  },
  'common': {
    'LOADING': 'Yuklanmoqda...',
    'ERROR': 'Xato',
    'RETRY': 'QAYTA URINISH',
    'SAVE': 'SAQLASH',
    'CANCEL': 'BEKOR QILISH',
    'CLOSE': 'Yopish',
    'CONFIRM': 'TASDIQLASH',
    'DELETE': "O'CHIRISH",
    'EDIT': 'TAHRIRLASH',
    'BACK': 'ORQAGA',
    'NEXT': 'KEYINGI',
    'DONE': 'TAYYOR',
    'EMPTY': "Bu yerda hali hech narsa yo'q",
    'TODAY': 'Bugun',
    'YESTERDAY': 'Kecha',
  },
  'settings': {
    'TITLE': 'SOZLAMALAR',
    'LANGUAGE': 'TIL',
    'LANGUAGE_DESC': 'Interfeys tilini tanlang',
  },
};

// ── Merge machinery ──────────────────────────────────────────────────────────

Map<String, dynamic> _deepMerge(Map<String, dynamic> base, Map<String, dynamic> extra) {
  final out = Map<String, dynamic>.from(base);
  extra.forEach((key, value) {
    final existing = out[key];
    if (value is Map && existing is Map) {
      out[key] = _deepMerge(
        Map<String, dynamic>.from(existing),
        Map<String, dynamic>.from(value),
      );
    } else {
      out[key] = value;
    }
  });
  return out;
}

Map<String, dynamic> _buildLanguage(
  Map<String, dynamic> base,
  List<Map<String, dynamic>> additions,
) {
  var merged = base;
  for (final add in additions) {
    merged = _deepMerge(merged, add);
  }
  return merged;
}

/// Fully merged strings per language (base + all feature additions).
final Map<String, Map<String, dynamic>> localizedStrings = {
  'en': _buildLanguage(_baseEn, additionsEn),
  'ru': _buildLanguage(_baseRu, additionsRu),
  'uz': _buildLanguage(_baseUz, additionsUz),
};

dynamic _walk(Map<String, dynamic>? root, String path) {
  dynamic cur = root;
  for (final seg in path.split('.')) {
    if (cur is Map && cur.containsKey(seg)) {
      cur = cur[seg];
    } else {
      return null;
    }
  }
  return cur;
}

/// Resolve a dot-path key for [lang], falling back to English, then to the key.
String trLookup(String lang, String path) {
  final value = _walk(localizedStrings[lang], path);
  if (value is String) return value;
  final fallback = _walk(localizedStrings[kDefaultLanguage], path);
  if (fallback is String) return fallback;
  return path;
}

// ── Riverpod wiring ──────────────────────────────────────────────────────────

/// Translator bound to the active language. Usage in a widget:
///   final t = ref.watch(tProvider);
///   Text(t('nav.HOME'));
final tProvider = Provider<String Function(String)>((ref) {
  final lang = ref.watch(languageProvider);
  final safe = kSupportedLanguages.contains(lang) ? lang : kDefaultLanguage;
  return (key) => trLookup(safe, key);
});

/// Convenience: read a string once without watching.
String tr(WidgetRef ref, String key) => ref.read(tProvider)(key);

/// Load the persisted language (call before runApp).
Future<String> loadSavedLanguage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(kLanguagePrefKey);
    if (saved != null && kSupportedLanguages.contains(saved)) return saved;
  } catch (_) {/* ignore — fall back to the initial language */}
  return kInitialLanguage;
}

/// Switch language and persist it.
Future<void> setLanguage(WidgetRef ref, String code) async {
  if (!kSupportedLanguages.contains(code)) return;
  ref.read(languageProvider.notifier).state = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLanguagePrefKey, code);
  } catch (_) {/* best-effort persistence */}
}
