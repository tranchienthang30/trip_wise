import '../models/trip_timeline.dart';
import 'api_client.dart';

class TripsApi {
  Future<TripsResponse> fetchTrips() async {
    final response =
        await ApiClient.instance.dio.get<Map<String, dynamic>>('/trips');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /trips');
    }
    return TripsResponse.fromJson(data);
  }
}
