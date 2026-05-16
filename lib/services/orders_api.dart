import '../models/provider_order.dart';
import 'api_client.dart';

class OrdersApi {
  Future<ProviderOrdersResponse> fetchOrders({
    required String status,
    String? providerId,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: {
        'status': status,
        if (providerId != null && providerId.isNotEmpty)
          'providerId': providerId,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /orders');
    }

    return ProviderOrdersResponse.fromJson(data);
  }

  Future<ProviderOrder> acceptOrder(String id) async {
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/orders/$id/accept',
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /orders/$id/accept');
    }

    return ProviderOrder.fromJson(data);
  }
}
