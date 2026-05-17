import '../models/provider_dashboard.dart';
import 'api_client.dart';

class ProviderDashboardApi {
  Future<ProviderDashboardData> fetchDashboard() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/dashboard',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/dashboard');
    }
    return ProviderDashboardData.fromJson(data);
  }
}
