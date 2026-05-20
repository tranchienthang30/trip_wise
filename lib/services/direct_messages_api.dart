import 'package:dio/dio.dart';

import '../models/direct_message.dart';
import 'api_client.dart';

class DirectMessagesApiException implements Exception {
  DirectMessagesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DirectMessagesApi {
  Future<DirectConversationPage> fetchConversations() async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/messages/conversations',
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /messages/conversations');
      }
      return DirectConversationPage.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  Future<DirectConversationDetail> fetchConversation(String id) async {
    try {
      final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/messages/conversations/$id',
      );
      final data = response.data;
      if (data == null) {
        throw StateError('Empty response from /messages/conversations/$id');
      }
      return DirectConversationDetail.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  Future<DirectConversationDetail> openOrderConversation(String orderId) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/messages/conversations/from-order',
        data: {'orderId': orderId},
      );
      final data = response.data;
      if (data == null) {
        throw StateError(
          'Empty response from /messages/conversations/from-order',
        );
      }
      return DirectConversationDetail.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  Future<DirectMessage> sendMessage(String conversationId, String body) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/messages/conversations/$conversationId/messages',
        data: {'body': body},
      );
      final data = response.data;
      if (data == null) {
        throw StateError(
          'Empty response from /messages/conversations/$conversationId/messages',
        );
      }
      return DirectMessage.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  Future<DirectConversation> markRead(String conversationId) async {
    try {
      final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
        '/messages/conversations/$conversationId/read',
      );
      final data = response.data;
      if (data == null) {
        throw StateError(
          'Empty response from /messages/conversations/$conversationId/read',
        );
      }
      return DirectConversation.fromJson(data);
    } on DioException catch (error) {
      throw _toException(error);
    }
  }

  DirectMessagesApiException _toException(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return DirectMessagesApiException(data['message'] as String);
    }
    return DirectMessagesApiException(
      error.message ?? 'Could not load messages. Please try again.',
    );
  }
}
