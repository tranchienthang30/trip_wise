import '../models/provider_finance.dart';
import 'api_client.dart';

class ProviderFinanceApi {
  Future<ProviderFinance> fetchFinance({
    String period = 'monthly',
    String? query,
    String status = 'all',
    int limit = 10,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/finance',
      queryParameters: {
        'period': period,
        'status': status,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/finance');
    }
    return ProviderFinance.fromJson(data);
  }

  Future<void> requestPayout({double? amount}) async {
    await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/provider/finance/payout-requests',
      data: {if (amount != null) 'amount': amount},
    );
  }
}
