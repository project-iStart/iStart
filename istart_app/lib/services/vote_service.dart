// lib/services/vote_service.dart

import 'api_client.dart';

class VoteService {
  Future<Map<String, dynamic>> castVote(String ideaId, String type) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post('/votes', data: {'idea': ideaId, 'type': type});
    return res.data;
  }

  Future<void> removeVote(String ideaId) async {
    final dio = await ApiClient.getClient();
    await dio.delete('/votes/$ideaId');
  }
}