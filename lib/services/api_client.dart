import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient._() {
    const envBase = String.fromEnvironment('API_BASE_URL');
    final baseUrl = envBase.isNotEmpty ? envBase : _platformDefaultBaseUrl();
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  // Android emulator routes localhost through the special alias 10.0.2.2.
  // Web / iOS sim / macOS / Linux / Windows can reach the host directly.
  static String _platformDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:4000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }
    return 'http://localhost:4000/api';
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;

  void setAuthToken(String? token) {
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }
    dio.options.headers['Authorization'] = 'Bearer $normalized';
  }
}
