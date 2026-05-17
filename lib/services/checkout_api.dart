import 'package:dio/dio.dart';

import '../models/checkout_data.dart';
import 'api_client.dart';

class CheckoutApiException implements Exception {
  CheckoutApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CheckoutApi {
  Future<CheckoutSummary> fetchSummary({
    int? hotelId,
    int? roomId,
    String? startDate,
    String? endDate,
    int? guests,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/checkout/summary',
      queryParameters: {
        if (hotelId != null) 'hotelId': hotelId,
        if (roomId != null) 'roomId': roomId,
        if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
        if (guests != null) 'guests': guests,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /checkout/summary');
    }
    return CheckoutSummary.fromJson(data);
  }

  Future<CheckoutCompleteResult> complete({
    required int hotelId,
    required int roomId,
    required String startDate,
    required String endDate,
    required int guests,
    required String paymentMethod,
    required bool agreeToTerms,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/checkout/complete',
        data: {
          'hotelId': hotelId,
          'roomId': roomId,
          'startDate': startDate,
          'endDate': endDate,
          'guests': guests,
          'paymentMethod': paymentMethod,
          'agreeToTerms': agreeToTerms,
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /checkout/complete');
      }
      return CheckoutCompleteResult.fromJson(data);
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw CheckoutApiException(response['message'] as String);
      }
      throw CheckoutApiException(
        'Could not complete booking. Please try again.',
      );
    }
  }
}
