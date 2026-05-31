import 'package:dio/dio.dart';

import '../models/trip_timeline.dart';
import 'api_client.dart';

/// Carries the server's human-readable message (e.g. "Activity not found").
class TripsApiException implements Exception {
  TripsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class TripsApi {
  Future<TripsResponse> fetchTrips() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/trips',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /trips');
    }
    return TripsResponse.fromJson(data);
  }

  Future<Trip> createTrip({
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/trips',
        data: {
          'title': title,
          'destination': destination,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /trips');
      }
      return Trip.fromJson(data);
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw TripsApiException(resp['message'] as String);
      }
      throw TripsApiException('Something went wrong. Please try again.');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await ApiClient.instance.dio.delete<Map<String, dynamic>>(
        '/trips/$tripId',
      );
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw TripsApiException(resp['message'] as String);
      }
      throw TripsApiException('Could not delete trip. Please try again.');
    }
  }

  /// Append a real activity onto a given day of a trip. Returns the updated
  /// trip; callers may also just re-fetch the list.
  Future<Trip> addItem({
    required String tripId,
    required int dayIndex,
    int? activityId,
    String? bookingItemId,
    String? time,
  }) async {
    try {
      final payload = <String, dynamic>{'dayIndex': dayIndex};
      if (bookingItemId != null && bookingItemId.trim().isNotEmpty) {
        payload['bookingItemId'] = bookingItemId.trim();
      }
      if (activityId != null) {
        payload['activityId'] = activityId;
      }
      if (time != null && time.trim().isNotEmpty) {
        payload['time'] = time.trim();
      }
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/trips/$tripId/items',
        data: payload,
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /trips/$tripId/items');
      }
      return Trip.fromJson(data);
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw TripsApiException(resp['message'] as String);
      }
      throw TripsApiException('Something went wrong. Please try again.');
    }
  }

  Future<Trip> updateItemTime({
    required String tripId,
    required int dayIndex,
    required int itemIndex,
    required String time,
  }) async {
    try {
      final response = await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/trips/$tripId/items/time',
        data: {'dayIndex': dayIndex, 'itemIndex': itemIndex, 'time': time},
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /trips/$tripId/items/time');
      }
      return Trip.fromJson(data);
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw TripsApiException(resp['message'] as String);
      }
      throw TripsApiException('Something went wrong. Please try again.');
    }
  }
}
