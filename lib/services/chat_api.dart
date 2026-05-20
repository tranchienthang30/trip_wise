import 'package:dio/dio.dart';

import 'api_client.dart';

class ChatApiException implements Exception {
  ChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatReply {
  ChatReply({required this.reply, required this.intent, required this.source});

  final String reply;
  final String intent;
  final String source;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      reply: json['reply'] as String? ?? '',
      intent: json['intent'] as String? ?? 'unknown',
      source: json['source'] as String? ?? 'rule',
    );
  }
}

class ChatApi {
  Future<ChatReply> sendMessage(String message) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/chat',
        data: {'message': message},
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /chat');
      }
      return ChatReply.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  ChatApiException _toException(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return ChatApiException(data['message'] as String);
    }
    return ChatApiException(
      error.message ?? 'Could not contact TripWise Assistant.',
    );
  }
}
