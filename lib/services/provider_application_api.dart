import 'package:dio/dio.dart';

import '../models/provider_application.dart';
import 'api_client.dart';

class ProviderApplicationApiException implements Exception {
  const ProviderApplicationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProviderApplicationApi {
  Future<ProviderApplication> submitApplication({
    required String fullName,
    required String phone,
    required String specialty,
    required int yearsExperience,
    required String bio,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/provider-applications',
        data: {
          'fullName': fullName,
          'phone': phone,
          'specialty': specialty,
          'yearsExperience': yearsExperience,
          'bio': bio,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ProviderApplicationApiException(
          'Empty response from /provider-applications',
        );
      }
      return ProviderApplication.fromJson(data);
    } on DioException catch (error) {
      throw ProviderApplicationApiException(_messageFromDio(error));
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
