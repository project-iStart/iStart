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
      'idea': ideaId,
      'category': category,
      'comment': comment,
      'rating': rating,
    });
    return res.data;
  }

  Future<List<dynamic>> getFeedbackForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/feedback/$ideaId');
    return res.data as List<dynamic>;
  }
}