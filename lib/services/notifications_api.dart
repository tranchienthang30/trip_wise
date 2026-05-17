import 'package:dio/dio.dart';

import '../models/notification_feed.dart';
import 'api_client.dart';

/// Carries the server's human-readable message so screens can surface it
/// directly (mirrors WalletApiException).
class NotificationApiException implements Exception {
  NotificationApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NotificationApi {
  Future<NotificationPage> fetchFeed({int limit = 10, int offset = 0}) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /notifications');
    }
    return NotificationPage.fromJson(data);
  }

  Future<NotificationSummary> fetchSummary() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/notifications/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /notifications/summary');
    }
    return NotificationSummary.fromJson(data);
  }

  Future<NotificationSummary> markRead(String id) =>
      _summaryMutation('/notifications/$id/read');

  Future<NotificationSummary> markAllRead() =>
      _summaryMutation('/notifications/read-all');

  Future<NotificationSummary> _summaryMutation(String path) async {
    try {
      final response =
          await ApiClient.instance.dio.post<Map<String, dynamic>>(path);
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from $path');
      }
      return NotificationSummary.fromJson(data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<NotificationPreferences> fetchPreferences() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/notifications/preferences',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /notifications/preferences');
    }
    return NotificationPreferences.fromJson(data);
  }

  Future<NotificationPreferences> savePreferences(
    NotificationPreferences prefs,
  ) async {
    try {
      final response = await ApiClient.instance.dio.put<Map<String, dynamic>>(
        '/notifications/preferences',
        data: prefs.toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /notifications/preferences');
      }
      return NotificationPreferences.fromJson(data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  NotificationApiException _toException(DioException e) {
    final resp = e.response?.data;
    if (resp is Map && resp['message'] is String) {
      return NotificationApiException(resp['message'] as String);
    }
    return NotificationApiException('Something went wrong. Please try again.');
  }
}
