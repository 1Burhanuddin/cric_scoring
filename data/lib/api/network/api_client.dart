import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/app_error.dart';
import '../../storage/app_preferences.dart';
import '../../utils/constant/firestore_constant.dart';
import 'client.dart';

final apiClientProvider = Provider((ref) => ApiClient(ref));

/// Thin REST client for the CricHeros backend (FastAPI + Postgres), replacing
/// direct Firestore/FirebaseAuth/FirebaseStorage access for the domains that
/// have been cut over. Attaches the JWT access token to every request and
/// clears the local session when the backend reports it's no longer valid.
class ApiClient {
  final Ref _ref;
  late final Dio _dio;

  ApiClient(this._ref) {
    _dio = _ref.read(apiDioProvider);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _ref.read(accessTokenPod);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _ref.read(accessTokenPod.notifier).state = null;
            _ref.read(currentUserJsonPod.notifier).state = null;
            _ref.read(currentUserSessionJsonPod.notifier).state = null;
          }
          handler.next(error);
        },
      ),
    );
  }

  String _url(String path) => '${DataConfig.instance.apiBaseUrl}$path';

  Future<dynamic> _run(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } catch (error, stack) {
      throw AppError.fromError(error, stack);
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get(_url(path), queryParameters: query));

  Future<dynamic> post(String path, {dynamic data}) =>
      _run(() => _dio.post(_url(path), data: data));

  Future<dynamic> patch(String path, {dynamic data}) =>
      _run(() => _dio.patch(_url(path), data: data));

  Future<dynamic> put(String path, {dynamic data}) =>
      _run(() => _dio.put(_url(path), data: data));

  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? query}) =>
      _run(() => _dio.delete(_url(path), data: data, queryParameters: query));
}
