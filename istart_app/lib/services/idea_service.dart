import 'api_client.dart';
import '../models/startup_idea.dart';

class IdeaService {
  Future<List<StartupIdea>> getIdeas({
    String? category,
    String? stage,
    String? search,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get(
      '/ideas',
      queryParameters: {
        if (category != null) 'category': category,
        if (stage != null) 'stage': stage,
        if (search != null) 'search': search,
      },
    );
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
    final res = await dio.post(
      '/ideas',
      data: {
        'title': title,
        'description': description,
        if (problemStatement != null) 'problemStatement': problemStatement,
        if (category != null) 'category': category,
        if (stage != null) 'stage': stage,
        if (pitchDeckUrl != null) 'pitchDeckUrl': pitchDeckUrl,
      },
    );
    return StartupIdea.fromJson(res.data);
  }

  Future<void> deleteIdea(String id) async {
    final dio = await ApiClient.getClient();
    await dio.delete('/ideas/$id');
  }

  Future<Map<String, dynamic>> toggleBookmark(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas/$ideaId/bookmark');
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// POST /votes — backend checks if vote exists:
  /// - If no vote → creates it + fires notification to founder (first time only)
  /// - If vote exists → removes it (no notification on re-vote)
  Future<Map<String, dynamic>> toggleVote(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/votes', data: {'ideaId': ideaId});
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Express funding interest in an idea (investors only)
  Future<Map<String, dynamic>> fundInterest(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas/$ideaId/fund-interest');
    return res.data as Map<String, dynamic>;
  }

  /// Follow or unfollow an idea (investors tracking ideas)
  Future<Map<String, dynamic>> toggleFollow(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/ideas/$ideaId/follow');
    return res.data as Map<String, dynamic>;
  }

  /// Get follower count for an idea
  Future<int> getFollowerCount(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/ideas/$ideaId/followers/count');
    return res.data['count'] as int? ?? 0;
  }
}
