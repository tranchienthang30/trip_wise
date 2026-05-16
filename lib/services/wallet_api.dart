import 'package:dio/dio.dart';

import '../models/wallet_overview.dart';
import 'api_client.dart';

/// Carries the server's human-readable message (e.g. "Card has insufficient
/// funds") so screens can surface it directly.
class WalletApiException implements Exception {
  WalletApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WalletApi {
  Future<WalletOverview> fetchWallet() async {
    final response =
        await ApiClient.instance.dio.get<Map<String, dynamic>>('/wallet');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /wallet');
    }
    return WalletOverview.fromJson(data);
  }

  Future<WalletTransactionPage> fetchTransactions({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/wallet/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /wallet/transactions');
    }
    return WalletTransactionPage.fromJson(data);
  }

  Future<WalletOverview> topUp({required double amount, String? cardId}) =>
      _mutate('/wallet/topup', {'amount': amount, 'cardId': cardId});

  Future<WalletOverview> withdraw({required double amount, String? cardId}) =>
      _mutate('/wallet/withdraw', {'amount': amount, 'cardId': cardId});

  Future<WalletOverview> addCard({
    String? brand,
    String? last4,
    String? holderName,
  }) =>
      _mutate('/wallet/cards', {
        'brand': brand,
        'last4': last4,
        'holderName': holderName,
      });

  Future<WalletOverview> _mutate(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        path,
        data: body..removeWhere((_, v) => v == null),
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from $path');
      }
      return WalletOverview.fromJson(data);
    } on DioException catch (e) {
      final resp = e.response?.data;
      if (resp is Map && resp['message'] is String) {
        throw WalletApiException(resp['message'] as String);
      }
      throw WalletApiException('Something went wrong. Please try again.');
    }
  }
}
