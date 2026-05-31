import '../models/hotel_detail.dart';
import 'api_client.dart';

class HotelsApi {
  static final Map<String, HotelDetail> _memoryCache = {};
  static final Map<String, Future<HotelDetail>> _pending = {};

  Future<HotelDetail> fetchHotelDetail(
    int id, {
    bool includeExistingBooking = false,
    bool forceRefresh = false,
  }) async {
    final key = '$id:${includeExistingBooking ? 'manage' : 'book'}';
    if (!forceRefresh) {
      final cached = _memoryCache[key];
      if (cached != null) return cached;
      final pending = _pending[key];
      if (pending != null) return pending;
    }

    final future = _fetchHotelDetail(
      id,
      includeExistingBooking: includeExistingBooking,
    );
    _pending[key] = future;

    try {
      final detail = await future;
      _memoryCache[key] = detail;
      return detail;
    } finally {
      _pending.remove(key);
    }
  }

  void prefetchHotelDetail(int id, {bool includeExistingBooking = false}) {
    if (id <= 0) return;
    () async {
      try {
        await fetchHotelDetail(
          id,
          includeExistingBooking: includeExistingBooking,
        );
      } catch (_) {
        // Best-effort warm cache; the destination screen handles errors.
      }
    }();
  }

  Future<HotelDetail> _fetchHotelDetail(
    int id, {
    required bool includeExistingBooking,
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/hotels/$id',
      queryParameters: {
        if (includeExistingBooking) 'includeExistingBooking': 'true',
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /hotels/$id');
    }
    return HotelDetail.fromJson(data);
  }
}
