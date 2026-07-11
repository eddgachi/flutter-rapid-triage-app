import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;

  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.com/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get client => _dio;
}
