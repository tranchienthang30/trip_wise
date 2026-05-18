import 'package:dio/dio.dart';

import '../models/auth_session.dart';
import 'api_client.dart';

class AuthApiError implements Exception {
  AuthApiError(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  Future<AuthSessionData> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      final data = response.data;
      if (data == null) {
        throw AuthApiError('Empty response from /auth/register');
      }
      return AuthSessionData.fromAuthResponse(data);
    } on DioException catch (error) {
      throw AuthApiError(_messageFromDio(error));
    }
  }

  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = response.data;
      if (data == null) {
        throw AuthApiError('Empty response from /auth/login');
      }
      return AuthSessionData.fromAuthResponse(data);
    } on DioException catch (error) {
      throw AuthApiError(_messageFromDio(error));
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post<void>('/auth/logout');
    } on DioException catch (error) {
      throw AuthApiError(_messageFromDio(error));
    }
  }

  Future<AuthSessionData> signInWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {
          'idToken': idToken,
        },
      );
      final data = response.data;
      if (data == null) {
        throw AuthApiError('Empty response from /auth/google');
      }
      return AuthSessionData.fromAuthResponse(data);
    } on DioException catch (error) {
      throw AuthApiError(_messageFromDio(error));
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return error.message ?? 'Request failed';
  }
}
