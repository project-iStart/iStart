// lib/services/discussion_service.dart

import 'api_client.dart';

class DiscussionService {
  Future<Map<String, dynamic>> createThread({
    required String ideaId,
    required String title,
    List<String>? participants,
  }) async {
    final dio = await ApiClient.getClient();
    final data = {'startupIdeaId': ideaId, 'title': title};
    if (participants != null && participants.isNotEmpty) {
      data['participants'] = participants as String;
    }
    final res = await dio.post('/discussion', data: data);
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
    List<Map<String, dynamic>>? attachments,
  }) async {
    final dio = await ApiClient.getClient();
    final data = {'content': content};
    if (attachments != null && attachments.isNotEmpty) {
      data['attachments'] = attachments as String;
    }
    final res = await dio.post('/discussion/$threadId/messages', data: data);
    return res.data;
  }

  Future<List<dynamic>> getMessages(String threadId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/discussion/$threadId/messages');
    return res.data as List<dynamic>;
  }
}
