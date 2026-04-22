// lib/services/discussion_service.dart

import 'api_client.dart';

class DiscussionService {
  Future<Map<String, dynamic>> createThread({
    required String ideaId,
    required String title,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/discussion', data: {
      'idea': ideaId,
      'title': title,
    });
    return res.data;
  }

  Future<List<dynamic>> getThreadsForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/discussion/$ideaId');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> postMessage({
    required String threadId,
    required String content,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/discussion/$threadId/messages', data: {
      'content': content,
    });
    return res.data;
  }

  Future<List<dynamic>> getMessages(String threadId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/discussion/$threadId/messages');
    return res.data as List<dynamic>;
  }
}