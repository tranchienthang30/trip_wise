import '../models/provider_finance.dart';
import 'api_client.dart';

class ProviderFinanceApi {
  Future<ProviderFinance> fetchFinance({String period = 'monthly'}) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/finance',
      queryParameters: {'period': period},
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
