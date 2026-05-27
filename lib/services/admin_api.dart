import 'package:dio/dio.dart';

import '../models/admin_cancellation.dart';
import '../models/admin_provider_payout.dart';
import '../models/admin_listing.dart';
import '../models/provider_application.dart';
import 'api_client.dart';

class AdminApiException implements Exception {
  const AdminApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AdminApi {
  Future<AdminListingsResponse> fetchListings({
    required AdminListingStatus status,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/admin/listings',
        queryParameters: {'status': adminListingStatusToApiValue(status)},
      );
      final data = response.data;
      if (data == null) {
        throw const AdminApiException('Empty response from /admin/listings');
      }
      return AdminListingsResponse.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<AdminListing> reviewListing({
    required int listingId,
    required AdminListingStatus decision,
    String? reason,
  }) async {
    try {
      final response = await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/admin/listings/$listingId/review',
        data: {
          'decision': adminListingStatusToApiValue(decision),
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      final data = response.data;
      if (data == null) {
        throw AdminApiException(
          'Empty response from /admin/listings/$listingId/review',
        );
      }
      return AdminListing.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<ProviderApplicationsResponse> fetchProviderApplications({
    required ProviderApplicationStatus status,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/admin/provider-applications',
        queryParameters: {
          'status': providerApplicationStatusToApiValue(status),
        },
      );
      final data = response.data;
      if (data == null) {
        throw const AdminApiException(
          'Empty response from /admin/provider-applications',
        );
      }
      return ProviderApplicationsResponse.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<ProviderApplication> reviewProviderApplication({
    required String userId,
    required ProviderApplicationStatus decision,
    String? reason,
  }) async {
    try {
      final response = await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/admin/provider-applications/$userId/review',
        data: {
          'decision': providerApplicationStatusToApiValue(decision),
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      final data = response.data;
      if (data == null) {
        throw AdminApiException(
          'Empty response from /admin/provider-applications/$userId/review',
        );
      }
      return ProviderApplication.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<AdminProviderPayoutsResponse> fetchProviderPayouts() async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/admin/provider-payouts',
      );
      final data = response.data;
      if (data == null) {
        throw const AdminApiException(
          'Empty response from /admin/provider-payouts',
        );
      }
      return AdminProviderPayoutsResponse.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<void> payProvider({required String providerId}) async {
    try {
      await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/admin/provider-payouts/$providerId/pay',
      );
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<AdminCancellationRequestsResponse> fetchCancellationRequests() async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/admin/cancellations',
      );
      final data = response.data;
      if (data == null) {
        throw const AdminApiException(
          'Empty response from /admin/cancellations',
        );
      }
      return AdminCancellationRequestsResponse.fromJson(data);
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  Future<void> reviewCancellation({
    required String bookingItemId,
    required bool approve,
  }) async {
    try {
      await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/admin/cancellations/$bookingItemId/review',
        data: {'decision': approve ? 'APPROVED' : 'REJECTED'},
      );
    } on DioException catch (error) {
      throw AdminApiException(_messageFromDio(error));
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return error.message ?? 'Request failed';
  }
}
