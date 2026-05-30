import 'package:dio/dio.dart';

import '../models/my_trip_detail.dart';
import '../models/my_trips.dart';
import '../models/review.dart';
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

  Future<MyTripDetail> fetchTripDetail(String bookingItemId) async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/my-trips/$bookingItemId',
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /my-trips/$bookingItemId');
      }
      return MyTripDetail.fromJson(data);
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not load booking details. Please try again.');
    }
  }

  Future<String> cancelTrip(String bookingItemId) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/my-trips/$bookingItemId/cancel',
      );
      final message = response.data?['message'];
      return message is String && message.trim().isNotEmpty
          ? message.trim()
          : 'Cancellation request sent.';
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not cancel trip. Please try again.');
    }
  }

  Future<Review> submitReview({
    required String bookingItemId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/my-trips/$bookingItemId/review',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /my-trips/$bookingItemId/review');
      }
      return Review.fromJson(data);
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not submit review. Please try again.');
    }
  }
}
