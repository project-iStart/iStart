// lib/services/idea_service.dart

import '../models/startup_idea.dart';
import 'api_client.dart';

class IdeaService {
  Future<List<StartupIdea>> fetchIdeas({
    String? category,
    String? stage,
    String? search,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get(
      '/ideas',
      queryParameters: {
        'category': ?category,
        'stage': ?stage,
        'search': ?search,
      },
    );
    return (res.data as List).map((e) => StartupIdea.fromJson(e)).toList();
  }

  Future<StartupIdea> getIdeaById(String id) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/ideas/$id');
    return StartupIdea.fromJson(res.data);
  }

  Future<Map<String, dynamic>> toggleVote(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/votes', data: {'ideaId': ideaId});
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> toggleBookmark(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas/$ideaId/bookmark');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> fundInterest(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas/$ideaId/fund-interest');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<StartupIdea> createIdea({
    required String title,
    required String description,
    String? problemStatement,
    String? category,
    String? stage,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas', data: {
      'title': title,
      'description': description,
      if (problemStatement != null) 'problemStatement': problemStatement,
      if (category != null) 'category': category,
      if (stage != null) 'stage': stage,
    });
    return StartupIdea.fromJson(res.data);
  }

  Future<StartupIdea> updateIdea({
    required String ideaId,
    required String title,
    required String description,
    String? problemStatement,
    String? category,
    String? stage,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.put('/ideas/$ideaId', data: {
      'title': title,
      'description': description,
      if (problemStatement != null) 'problemStatement': problemStatement,
      if (category != null) 'category': category,
      if (stage != null) 'stage': stage,
    });
    return StartupIdea.fromJson(res.data);
  }

  Future<void> deleteIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    await dio.delete('/ideas/$ideaId');
  }
}