import '../models/inventory_overview.dart';
import 'api_client.dart';

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
}
