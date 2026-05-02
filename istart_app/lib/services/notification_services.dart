import 'api_client.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getNotifications(String token) async {
    final res = await _client.get('/notifications', token: token);
    return res.data is List ? res.data : [];
  }

  Future<void> markAsRead(String id, String token) async {
    await _client.patch('/notifications/$id/read', {}, token: token);
  }

  Future<void> markAllAsRead(String token) async {
    await _client.patch('/notifications/read-all', {}, token: token);
  }
}