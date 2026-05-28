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
    try {
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
    } on DioException catch (e) {
      throw CheckoutApiException(_messageFromDio(e));
    }
  }

  Future<CheckoutCompleteResult> complete({
    required int hotelId,
    required int roomId,
    required String startDate,
    required String endDate,
    required int guests,
    required String paymentMethod,
    required bool usePoints,
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
          'usePoints': usePoints,
          'agreeToTerms': agreeToTerms,
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /checkout/complete');
      }
      return CheckoutCompleteResult.fromJson(data);
    } on DioException catch (e) {
      throw CheckoutApiException(_messageFromDio(e));
    }
  }

  Future<CheckoutPayOSSession> fetchPayOSSession({
    required String bookingId,
    String? paymentId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/checkout/payos/session',
        queryParameters: {
          'bookingId': bookingId,
          if (paymentId != null && paymentId.isNotEmpty) 'paymentId': paymentId,
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /checkout/payos/session');
      }
      return CheckoutPayOSSession.fromJson(data);
    } on DioException catch (e) {
      throw CheckoutApiException(_messageFromDio(e));
    }
  }

  Future<CheckoutPayOSConfirmResult> confirmPayOSPayment({
    required String bookingId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/checkout/payos/confirm',
        data: {'bookingId': bookingId},
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /checkout/payos/confirm');
      }
      return CheckoutPayOSConfirmResult.fromJson(data);
    } on DioException catch (e) {
      throw CheckoutApiException(_messageFromDio(e));
    }
  }

  String _messageFromDio(DioException error) {
    final response = error.response?.data;
    if (response is Map && response['message'] is String) {
      return response['message'] as String;
    }
    return 'Could not complete booking. Please try again.';
  }
}
