import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// Registers this device's FCM token with the backend so server-side
/// createNotification() can push to it. Best-effort: token registration must
/// never crash app start, so failures are swallowed (logged in debug).
class DeviceApi {
  Future<void> registerToken(String token, {String platform = 'android'}) async {
    try {
      await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/devices',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[push] token registration failed: ${e.message}');
      }
    }
  }

  Future<void> unregisterToken(String token) async {
    try {
      await ApiClient.instance.dio.delete<Map<String, dynamic>>(
        '/devices',
        data: {'token': token},
      );
    } on DioException catch (_) {
      // Best-effort.
    }
  }
}
