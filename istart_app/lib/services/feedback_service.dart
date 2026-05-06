// lib/services/feedback_service.dart

import 'api_client.dart';

class FeedbackService {
  Future<Map<String, dynamic>> submitFeedback({
    required String ideaId,
    required String category,
    required String comment,
    required int rating,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/feedback', data: {
      'startupIdea': ideaId,
      'category': category,
      'rating': rating,
      if (comment.isNotEmpty) 'comment': comment,
    });
    return res.data;
  }

  Future<List<dynamic>> getFeedbackForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/feedback/$ideaId');
    return res.data as List<dynamic>;
  }
}
