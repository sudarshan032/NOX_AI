import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import 'secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/${AppConstants.apiVersion}',
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    _dio.interceptors.addAll([_AuthInterceptor(_dio), _ErrorInterceptor()]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path, {dynamic data}) =>
      _dio.delete<T>(path, data: data);
}

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  _AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final resp = await Dio().post(
            '${AppConstants.baseUrl}/${AppConstants.apiVersion}${AppConstants.authEndpoint}/refresh',
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          final newToken = resp.data['access_token'] as String;
          await SecureStorageService.saveAccessToken(newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retried = await dio.fetch(err.requestOptions);
          return handler.resolve(retried);
        } catch (e) {
          debugPrint('[AUTH] Token refresh failed: $e — clearing session');
          await SecureStorageService.clearAll();
        }
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout. Check your internet.',
      DioExceptionType.sendTimeout => 'Request timeout.',
      DioExceptionType.receiveTimeout => 'Server took too long to respond.',
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.badResponse =>
        err.response?.data?['detail'] ?? err.response?.data?['message'] ?? 'Server error',
      _ => 'An unexpected error occurred.',
    };
    throw ApiException(
      message: message,
      statusCode: err.response?.statusCode,
      data: err.response?.data,
    );
  }
}
