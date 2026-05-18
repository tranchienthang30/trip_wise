import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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

  String _inferMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
