import '../models/home_content.dart';
import 'api_client.dart';

class HomeApi {
  Future<HomeContent> fetchHome() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>('/home');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /home');
    }
    return HomeContent.fromJson(data);
  }
}
