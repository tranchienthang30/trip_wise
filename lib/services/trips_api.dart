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
    final response =
        await ApiClient.instance.dio.get<Map<String, dynamic>>('/trips');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /trips');
    }
    return TripsResponse.fromJson(data);
  }

  /// Append a real activity onto a given day of a trip. Returns the updated
  /// trip; callers may also just re-fetch the list.
  Future<Trip> addItem({
    required String tripId,
    required int dayIndex,
    required int activityId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/trips/$tripId/items',
        data: {'dayIndex': dayIndex, 'activityId': activityId},
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
}
