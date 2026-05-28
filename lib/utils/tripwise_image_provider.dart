import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/api_client.dart';

ImageProvider? tripwiseImageProvider(String? value) {
  final image = value?.trim();
  if (image == null || image.isEmpty) return null;

  if (image.startsWith('data:image/')) {
    final commaIndex = image.indexOf(',');
    if (commaIndex <= 0) return null;
    try {
      final bytes = base64Decode(image.substring(commaIndex + 1));
      if (bytes.isEmpty) return null;
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  if (image.startsWith('http://') || image.startsWith('https://')) {
    return NetworkImage(image);
  }

  // Backend often returns relative paths (e.g. /uploads/listings/..).
  // Resolve them against current API host so NetworkImage can load.
  final baseUrl = ApiClient.instance.dio.options.baseUrl.trim();
  if (baseUrl.isNotEmpty) {
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri != null && baseUri.hasScheme && baseUri.host.isNotEmpty) {
      final root = baseUri.replace(path: '', query: null, fragment: null);
      final resolved = image.startsWith('/')
          ? root.resolve(image).toString()
          : root.resolve('/$image').toString();
      return NetworkImage(resolved);
    }
  }

  return NetworkImage(image);
}
