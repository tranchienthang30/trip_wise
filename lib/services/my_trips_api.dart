import 'package:dio/dio.dart';

import '../models/my_trips.dart';
import 'api_client.dart';

class MyTripsApi {
  Future<MyTripsResponse> fetchTrips({
    required String status,
    String? bookingId,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/my-trips',
      queryParameters: {
        'status': status,
        if (bookingId != null && bookingId.trim().isNotEmpty)
          'bookingId': bookingId.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /my-trips');
    }
    return MyTripsResponse.fromJson(data);
  }

  Future<void> cancelTrip(String bookingItemId) async {
    try {
      await ApiClient.instance.dio.post<void>(
        '/my-trips/$bookingItemId/cancel',
      );
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not cancel trip. Please try again.');
    }
  }
}
