import '../models/wallet_overview.dart';
import 'api_client.dart';

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
}
