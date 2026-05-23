import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

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

  return NetworkImage(image);
}
