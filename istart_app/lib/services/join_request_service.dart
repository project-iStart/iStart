// lib/services/join_request_service.dart

import 'api_client.dart';

class JoinRequestService {
  Future<Map<String, dynamic>> sendRequest({
    required String ideaId,
    required String message,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post(
      '/join-requests',
      data: {'startupIdeaId': ideaId, 'message': message},
    );
    return res.data;
  }

  Future<List<dynamic>> getRequestsForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/join-requests/$ideaId');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateStatus(
    String requestId,
    String status,
  ) async {
    final dio = await ApiClient.getClient();
    final res = await dio.put(
      '/join-requests/$requestId',
      data: {'status': status},
    );
    return res.data;
  }
}
