import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client for the self-hosted ExerciseDB API
/// (https://github.com/exercisedb/exercisedb-api), the same data source the
/// web app uses. Mirrors `src/lib/exercise-db-api.ts` + `exercise-library.ts`.
///
/// Responses are wrapped in an envelope `{ success, data, metadata }` — every
/// helper here unwraps `data` before returning.
class ExerciseDbApi {
  ExerciseDbApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? defaultBaseUrl;

  /// Verified working public instance (see task contract).
  static const String defaultBaseUrl = 'https://fork-ivory-chi.vercel.app/api/v1';

  static const int pageSize = 100; // API max page size
  static const int maxPages = 40; // safety cap (~4000 exercises)

  final http.Client _client;
  final String _baseUrl;

  /// GET a path and unwrap the `data` envelope when present.
  Future<dynamic> _get(String path, {Duration? timeout}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final res = await _client
        .get(uri, headers: const {'accept': 'application/json'})
        .timeout(timeout ?? const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception(
        'ExerciseDB API error: ${res.statusCode} ${res.reasonPhrase} — $uri',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  /// Fetch a single page of raw exercise maps.
  Future<List<Map<String, dynamic>>> fetchExercises({
    int limit = pageSize,
    int offset = 0,
  }) async {
    final data = await _get('/exercises?limit=$limit&offset=$offset');
    return _asMapList(data);
  }

  /// Paginate until a page comes back short/empty — mirrors the web's
  /// `fetchAllPaginated`. Returns raw maps; the caller maps them to models.
  Future<List<Map<String, dynamic>>> fetchAllExercises() async {
    final all = <Map<String, dynamic>>[];
    for (var page = 0; page < maxPages; page++) {
      final chunk = await fetchExercises(limit: pageSize, offset: page * pageSize);
      if (chunk.isEmpty) break;
      all.addAll(chunk);
      if (chunk.length < pageSize) break;
    }
    return all;
  }

  /// Fetch a single exercise by id (envelope unwrapped to a single map).
  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    final data = await _get(
      '/exercises/${Uri.encodeComponent(id)}',
      timeout: const Duration(seconds: 15),
    );
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return null;
  }

  /// Server-side name search (`/exercises/search?q=`).
  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final data = await _get(
      '/exercises/search?q=${Uri.encodeComponent(query)}',
      timeout: const Duration(seconds: 15),
    );
    return _asMapList(data);
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
