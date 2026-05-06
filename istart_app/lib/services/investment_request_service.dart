// lib/services/investment_request_service.dart

import 'api_client.dart';

class InvestmentRequestService {
  Future<Map<String, dynamic>> sendRequest({
    required String ideaId,
    required double? fundingAmount,
    required String message,
  }) async {
    final dio = await ApiClient.getClient();
    final data = <String, dynamic>{'startupIdeaId': ideaId, 'message': message};
    if (fundingAmount != null) {
      data['fundingAmount'] = fundingAmount;
    }
    final res = await dio.post('/investment-requests', data: data);
    return res.data;
  }

  Future<List<dynamic>> getRequestsForIdea(String ideaId) async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/investment-requests/$ideaId');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateStatus(
    String requestId,
    String status,
  ) async {
    final dio = await ApiClient.getClient();
    final res = await dio.put(
      '/investment-requests/$requestId',
      data: {'status': status},
    );
    return res.data;
  }

  Future<List<dynamic>> getMyRequests() async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/investment-requests/investor/my-requests');
    return res.data as List<dynamic>;
  }
}
