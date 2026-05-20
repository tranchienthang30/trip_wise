import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_data.dart';
import 'api_client.dart';

enum ProfileVerificationDocumentType { passport, address }

extension ProfileVerificationDocumentTypeMeta
    on ProfileVerificationDocumentType {
  String get pathSegment {
    switch (this) {
      case ProfileVerificationDocumentType.passport:
        return 'passport';
      case ProfileVerificationDocumentType.address:
        return 'address';
    }
  }

  String get label {
    switch (this) {
      case ProfileVerificationDocumentType.passport:
        return 'Passport or ID';
      case ProfileVerificationDocumentType.address:
        return 'Proof of Address';
    }
  }
}

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

  Future<String> uploadAvatar(XFile file) async {
    final bytes = await file.readAsBytes();
    final mimeType = _inferMimeType(file.name);
    try {
      final response = await ApiClient.instance.dio.patch<Map<String, dynamic>>(
        '/profile/avatar',
        data: {
          'fileName': file.name,
          'mimeType': mimeType,
          'dataBase64': base64Encode(bytes),
        },
      );
      final data = response.data;
      if (data == null || data['imageUrl'] is! String) {
        throw StateError('Empty response from /profile/avatar');
      }
      return data['imageUrl'] as String;
    } on DioException catch (e) {
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not upload avatar. Please try again.');
    }
  }

  Future<ProfileVerification> uploadVerificationDocument({
    required ProfileVerificationDocumentType documentType,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    try {
      final response = await ApiClient.instance.dio
          .patch<Map<String, dynamic>>(
            '/profile/verification/${documentType.pathSegment}',
            data: {
              'fileName': fileName,
              'mimeType': mimeType,
              'dataBase64': base64Encode(bytes),
            },
          );
      final data = response.data;
      final verification = data?['verification'];
      if (verification is! Map<String, dynamic>) {
        throw StateError('Empty response from verification upload');
      }
      return ProfileVerification.fromJson(verification);
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw StateError(
          'Image is too large. Please crop tighter or choose a smaller photo.',
        );
      }
      final response = e.response?.data;
      if (response is Map && response['message'] is String) {
        throw StateError(response['message'] as String);
      }
      throw StateError('Could not upload document. Please try again.');
    }
  }

  String _inferMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
