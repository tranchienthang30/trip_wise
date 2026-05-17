import '../models/my_trips.dart';
import 'api_client.dart';

class MyTripsApi {
  Future<MyTripsResponse> fetchTrips({required String status}) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/my-trips',
      queryParameters: {'status': status},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /my-trips');
    }
    return MyTripsResponse.fromJson(data);
  }
}
