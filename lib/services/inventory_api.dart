import 'package:dio/dio.dart';

import '../models/inventory_overview.dart';
import 'api_client.dart';

/// Carries the server's human-readable message (e.g. "price must be a
/// positive number") so screens can surface it directly.
class InventoryApiException implements Exception {
  InventoryApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class InventoryApi {
  Future<InventoryOverview> fetchInventory({String? month}) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/inventory',
      queryParameters: {if (month != null) 'month': month},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /inventory');
    }
    return InventoryOverview.fromJson(data);
  }

  /// Persist a single day's availability + price for the active listing.
  Future<InventoryOverview> updateDay({
    required String date,
    required bool available,
    required double price,
  }) =>
      _mutate(
        'PATCH',
        '/inventory/day',
        {'date': date, 'available': available, 'price': price},
      );

  /// Persist the dynamic-pricing rules; `month` keeps the calendar in place.
  Future<InventoryOverview> updateRules({
    required double weekendSurgePct,
    required double holidayPeakPct,
    required double lastMinuteDiscPct,
    required bool weekendEnabled,
    required bool holidayEnabled,
    required bool lastMinuteEnabled,
    String? month,
  }) =>
      _mutate('PUT', '/inventory/rules', {
        'weekendSurgePct': weekendSurgePct,
        'holidayPeakPct': holidayPeakPct,
        'lastMinuteDiscPct': lastMinuteDiscPct,
        'weekendEnabled': weekendEnabled,
        'holidayEnabled': holidayEnabled,
        'lastMinuteEnabled': lastMinuteEnabled,
        if (month != null) 'month': month,
      });

  Future<InventoryOverview> _mutate(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await ApiClient.instance.dio.request<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(method: method),
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from $path');
      }
      return InventoryOverview.fromJson(data);
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw InventoryApiException(resp['message'] as String);
      }
      throw InventoryApiException('Something went wrong. Please try again.');
    }
  }
}
