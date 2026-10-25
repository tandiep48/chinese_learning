/// Core API — the single `dio` HTTP client for the backend.
///
/// The web uses TWO response shapes, so this client exposes two paths (ported
/// from `yi-chinese-manage/lib/api/client.ts`):
///   • envelope — `/api/auth/*` (web `apiFetch`): body is `{success, data}`;
///     [getEnvelope]/[postEnvelope] unwrap `data` and throw on `success:false`.
///   • raw — every lesson-study read (web `legacyApiFetch`): body is raw JSON
///     with the payload under a key (`books`/`passages`/`passage`/`vocab`);
///     [getRaw]/[postRaw] return the decoded body untouched for the repository
///     to pick its key. Do NOT blind-unwrap `{success, data}` on this path.
///
/// Either path maps HTTP 401 to [UnauthenticatedException]. The request
/// interceptor injects `Authorization: Bearer <token>` from
/// [bearerTokenProvider] (null until Phase 3's auth notifier sets it).
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env.dart';
import 'api_exception.dart';
import 'validators.dart';

/// Holds the current access token the request interceptor injects, or null
/// when signed out. This is the seam between core (which reads it) and the
/// auth module (which sets it): the auth notifier calls
/// `ref.read(bearerTokenProvider.notifier).set(...)` on launch/login/logout.
class BearerTokenHolder extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

final bearerTokenProvider =
    NotifierProvider<BearerTokenHolder, String?>(BearerTokenHolder.new);

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
    // Inspect status codes ourselves so we can map them to typed exceptions.
    validateStatus: (_) => true,
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(bearerTokenProvider);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
  return ApiClient(dio);
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  // ── Enveloped `{success, data}` endpoints (auth) ──────────────────────────
  Future<dynamic> getEnvelope(String path, {Map<String, dynamic>? query}) =>
      _unwrapEnvelope(() => _dio.get(path, queryParameters: query));

  Future<dynamic> postEnvelope(String path, {Object? body}) =>
      _unwrapEnvelope(() => _dio.post(path, data: body));

  // ── Raw JSON endpoints (lesson study) ─────────────────────────────────────
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? query}) =>
      _raw(() => _dio.get(path, queryParameters: query));

  Future<dynamic> postRaw(String path, {Object? body}) =>
      _raw(() => _dio.post(path, data: body));

  Future<Response> _call(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      throw NetworkException(e.message ?? 'Network error.');
    }
  }

  Future<dynamic> _unwrapEnvelope(Future<Response> Function() request) async {
    final res = await _call(request);
    if (res.statusCode == 401) throw const UnauthenticatedException();
    final body = asMap(res.data, what: 'response envelope');
    if (body['success'] != true) {
      final error = body['error'];
      throw ApiException(
        error is String ? error : 'API error ${res.statusCode}',
        statusCode: res.statusCode,
      );
    }
    return body['data'];
  }

  Future<dynamic> _raw(Future<Response> Function() request) async {
    final res = await _call(request);
    final status = res.statusCode ?? 0;
    if (status == 401) throw const UnauthenticatedException();
    if (status < 200 || status >= 300) {
      final data = res.data;
      final error = data is Map ? data['error'] : null;
      throw ApiException(
        error is String ? error : 'API error $status',
        statusCode: status,
      );
    }
    return res.data;
  }
}
