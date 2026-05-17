import 'package:dio/dio.dart';

import '../models/provider_listing.dart';
import 'api_client.dart';

class ProviderListingsApiException implements Exception {
  ProviderListingsApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProviderListingsApi {
  Future<ProviderListingsResponse> fetchListings({
    String query = '',
    String status = 'all',
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/listings',
      queryParameters: {if (query.isNotEmpty) 'query': query, 'status': status},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/listings');
    }
    return ProviderListingsResponse.fromJson(data);
  }

  Future<ProviderListingDetail> fetchDetail(int id) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/listings/$id',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/listings/$id');
    }
    return ProviderListingDetail.fromJson(data);
  }

  Future<ProviderListingDetail> createListing({
    required String title,
    required String category,
    required String location,
    required String description,
    required int roomsCount,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    required double pricePerNight,
    required List<String> amenities,
  }) async {
    return _mutate(
      method: 'POST',
      path: '/provider/listings',
      data: {
        'title': title,
        'category': category,
        'location': location,
        'description': description,
        'roomsCount': roomsCount,
        'maxGuests': maxGuests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'pricePerNight': pricePerNight,
        'amenities': amenities,
      },
    );
  }

  Future<ProviderListingDetail> updateListing({
    required int id,
    String? title,
    String? category,
    String? location,
    String? description,
    String? status,
    int? maxGuests,
    int? bedrooms,
    int? bathrooms,
    double? pricePerNight,
    String? roomType,
    List<String>? amenities,
  }) async {
    final data = <String, dynamic>{
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (maxGuests != null) 'maxGuests': maxGuests,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (bathrooms != null) 'bathrooms': bathrooms,
      if (pricePerNight != null) 'pricePerNight': pricePerNight,
      if (roomType != null) 'roomType': roomType,
      if (amenities != null) 'amenities': amenities,
    };

    return _mutate(method: 'PATCH', path: '/provider/listings/$id', data: data);
  }

  Future<void> deleteListing(int id) async {
    try {
      await ApiClient.instance.dio.delete<Map<String, dynamic>>(
        '/provider/listings/$id',
      );
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw ProviderListingsApiException(response['message'] as String);
      }
      throw ProviderListingsApiException('Could not delete listing.');
    }
  }

  Future<ProviderListingAnalytics> fetchAnalytics({
    required int id,
    String period = '30d',
  }) async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/provider/listings/$id/analytics',
      queryParameters: {'period': period},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from /provider/listings/$id/analytics');
    }
    return ProviderListingAnalytics.fromJson(data);
  }

  Future<ProviderListingDetail> _mutate({
    required String method,
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiClient.instance.dio
          .request<Map<String, dynamic>>(
            path,
            options: Options(method: method),
            data: data,
          );
      final body = response.data;
      if (body == null) {
        throw StateError('Empty response from $path');
      }
      return ProviderListingDetail.fromJson(body);
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw ProviderListingsApiException(response['message'] as String);
      }
      throw ProviderListingsApiException(
        'Something went wrong. Please try again.',
      );
    }
  }
}
