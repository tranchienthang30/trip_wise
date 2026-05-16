import '../models/search_data.dart';
import 'api_client.dart';

class SearchApi {
  Future<SearchData> fetchSearch({
    required String query,
    required String category,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/search',
      queryParameters: {
        'query': query,
        'category': category,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /search');
    }

    return SearchData.fromJson(data);
  }
}
