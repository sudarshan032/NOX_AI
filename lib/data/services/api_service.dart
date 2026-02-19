/// API Service Template
/// 
/// This file contains the base API service for making network requests.
/// Uses Dio for HTTP requests with interceptors for auth and error handling.
/// Uncomment when ready to connect to backend APIs.

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: API Service Implementation (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:dio/dio.dart';
// import '../../core/constants/app_constants.dart';
// 
// /// Custom exception for API errors
// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;
//   final dynamic data;
// 
//   ApiException({
//     required this.message,
//     this.statusCode,
//     this.data,
//   });
// 
//   @override
//   String toString() => 'ApiException: $message (Status: $statusCode)';
// }
// 
// /// Base API service with Dio client
// class ApiService {
//   late final Dio _dio;
// 
//   ApiService() {
//     _dio = Dio(BaseOptions(
//       baseUrl: '${AppConstants.baseUrl}/${AppConstants.apiVersion}',
//       connectTimeout: AppConstants.apiTimeout,
//       receiveTimeout: AppConstants.apiTimeout,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ));
// 
//     _dio.interceptors.addAll([
//       _AuthInterceptor(),
//       _LoggingInterceptor(),
//       _ErrorInterceptor(),
//     ]);
//   }
// 
//   /// GET request
//   Future<Response<T>> get<T>(
//     String path, {
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return _dio.get<T>(
//       path,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// 
//   /// POST request
//   Future<Response<T>> post<T>(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return _dio.post<T>(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// 
//   /// PUT request
//   Future<Response<T>> put<T>(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return _dio.put<T>(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// 
//   /// PATCH request
//   Future<Response<T>> patch<T>(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return _dio.patch<T>(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// 
//   /// DELETE request
//   Future<Response<T>> delete<T>(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return _dio.delete<T>(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// }
// 
// /// Authentication interceptor - adds auth token to requests
// class _AuthInterceptor extends Interceptor {
//   @override
//   void onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     // TODO: Get token from secure storage
//     // final token = await SecureStorage.getToken();
//     // if (token != null) {
//     //   options.headers['Authorization'] = 'Bearer $token';
//     // }
//     handler.next(options);
//   }
// 
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       // TODO: Handle token refresh
//       // try {
//       //   await refreshToken();
//       //   return handler.resolve(await _dio.fetch(err.requestOptions));
//       // } catch (_) {
//       //   // Redirect to login
//       // }
//     }
//     handler.next(err);
//   }
// }
// 
// /// Logging interceptor for debugging
// class _LoggingInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
//     handler.next(options);
//   }
// 
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
//     handler.next(response);
//   }
// 
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
//     handler.next(err);
//   }
// }
// 
// /// Error handling interceptor
// class _ErrorInterceptor extends Interceptor {
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     final message = switch (err.type) {
//       DioExceptionType.connectionTimeout => 'Connection timeout',
//       DioExceptionType.sendTimeout => 'Send timeout',
//       DioExceptionType.receiveTimeout => 'Receive timeout',
//       DioExceptionType.connectionError => 'No internet connection',
//       DioExceptionType.badResponse => err.response?.data?['message'] ?? 'Server error',
//       _ => 'An unexpected error occurred',
//     };
// 
//     throw ApiException(
//       message: message,
//       statusCode: err.response?.statusCode,
//       data: err.response?.data,
//     );
//   }
// }
