import '../models/profile_data.dart';
import 'api_client.dart';

class ProfileApi {
  Future<ProfileData> fetchProfile() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/profile',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /profile');
    }
    return ProfileData.fromJson(data);
  }
}
