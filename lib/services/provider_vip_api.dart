import '../models/provider_vip.dart';
import 'api_client.dart';

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
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/provider/vip/upgrade',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/vip/upgrade');
    }
    return ProviderVipData.fromJson(data);
  }

  Future<ProviderVipData> selectPromotion(String promotionId) async {
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/provider/vip/promotions/select',
      data: {'promotionId': promotionId},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/vip/promotions/select');
    }
    return ProviderVipData.fromJson(data);
  }
}
