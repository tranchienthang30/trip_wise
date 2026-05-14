import '../models/hotel_detail.dart';
import 'api_client.dart';

class HotelsApi {
  Future<HotelDetail> fetchHotelDetail(int id) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/hotels/$id',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /hotels/$id');
    }
    return HotelDetail.fromJson(data);
  }
}
