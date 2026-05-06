// lib/services/doc_request_service.dart

import 'api_client.dart';

class DocRequestService {
  Future<Map<String, dynamic>> sendDocRequest({
    required String ideaId,
    required String requestMessage,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post(
      '/doc-requests',
      data: {'startupIdeaId': ideaId, 'requestMessage': requestMessage},
    );
    return res.data;
  }

  Future<List<dynamic>> getDocRequestsForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/doc-requests/$ideaId');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> replyToDocRequest({
    required String requestId,
    required String replyMessage,
    String? fileUrl,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.put(
      '/doc-requests/$requestId',
      data: {'responseMessage': replyMessage, 'fileUrl': fileUrl},
    );
    return res.data;
  }
}
