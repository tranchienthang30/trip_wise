import '../models/review.dart';
import 'api_client.dart';

class ReviewsApi {
  Future<ReviewsPage> fetchReviews(
    int hotelId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/hotels/$hotelId/reviews',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /hotels/$hotelId/reviews');
    }
    return ReviewsPage.fromJson(data);
  }
}
