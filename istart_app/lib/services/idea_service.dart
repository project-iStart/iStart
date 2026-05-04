import 'api_client.dart';
import '../models/startup_idea.dart';

class IdeaService {
  Future<List<StartupIdea>> getIdeas({String? category, String? stage, String? search}) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/ideas', queryParameters: {
      if (category != null) 'category': category,
      if (stage != null) 'stage': stage,
      if (search != null) 'search': search,
    });
    return (res.data as List).map((e) => StartupIdea.fromJson(e)).toList();
  }

  Future<StartupIdea> getIdeaById(String id) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/ideas/$id');
    return StartupIdea.fromJson(res.data);
  }

  Future<StartupIdea> createIdea({
    required String title,
    required String description,
    String? problemStatement,
    String? category,
    String? stage,
    String? pitchDeckUrl,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas', data: {
      'title': title,
      'description': description,
      if (problemStatement != null) 'problemStatement': problemStatement,
      if (category != null) 'category': category,
      if (stage != null) 'stage': stage,
      if (pitchDeckUrl != null) 'pitchDeckUrl': pitchDeckUrl,
    });
    return StartupIdea.fromJson(res.data);
  }

  Future<void> deleteIdea(String id) async {
    final dio = await ApiClient.getClient();
    await dio.delete('/ideas/$id');
  }

  Future<void> toggleBookmark(String ideaId) async {
    final dio = await ApiClient.getClient();
    await dio.post('/ideas/$ideaId/bookmark');
  }

  /// POST /votes — backend checks if vote exists:
  /// - If no vote → creates it + fires notification to founder (first time only)
  /// - If vote exists → removes it (no notification on re-vote)
  Future<void> toggleVote(String ideaId) async {
    final dio = await ApiClient.getClient();
    await dio.post('/votes', data: {'ideaId': ideaId});
  }
}