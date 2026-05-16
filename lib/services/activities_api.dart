import '../models/activity_catalog.dart';
import 'api_client.dart';

class ActivitiesApi {
  Future<ActivityCatalog> fetchCatalog({String? category}) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/activities',
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /activities');
    }
    return ActivityCatalog.fromJson(data);
  }
}
