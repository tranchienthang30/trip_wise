import 'package:dio/dio.dart';

import '../models/provider_vip.dart';
import 'api_client.dart';

class ProviderVipApiException implements Exception {
  ProviderVipApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProviderVipApi {
  Future<ProviderVipData> fetchVipServices() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/vip',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/vip');
    }
    return ProviderVipData.fromJson(data);
  }

  Future<ProviderVipData> upgradeToElite() async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/provider/vip/upgrade',
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /provider/vip/upgrade');
      }
      return ProviderVipData.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      final serverMessage = data is Map ? data['message']?.toString() : null;
      if (serverMessage == 'Wallet has insufficient funds') {
        throw ProviderVipApiException(
          'Insufficient wallet balance. Please add funds to continue.',
        );
      }
      throw ProviderVipApiException(
        serverMessage ?? 'Unable to upgrade right now. Please try again.',
      );
    }
  }

  Future<ProviderVipData> selectPromotion(String promotionId) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/provider/vip/promotions/select',
        data: {'promotionId': promotionId},
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /provider/vip/promotions/select');
      }
      return ProviderVipData.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      final serverMessage = data is Map ? data['message']?.toString() : null;
      throw ProviderVipApiException(
        serverMessage ?? 'Unable to select this promotion. Please try again.',
      );
    }
  }

  Future<ProviderVipData> updateAutoRenew(bool autoRenew) async {
    try {
      final response = await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/provider/vip/auto-renew',
        data: {'autoRenew': autoRenew},
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /provider/vip/auto-renew');
      }
      return ProviderVipData.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      final serverMessage = data is Map ? data['message']?.toString() : null;
      throw ProviderVipApiException(
        serverMessage ?? 'Unable to update auto-renew. Please try again.',
      );
    }
  }
}
