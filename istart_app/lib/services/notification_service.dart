// lib/services/notification_service.dart

import '../models/app_notification.dart';
import 'api_client.dart';

class NotificationService {
  Future<List<AppNotification>> getNotifications() async {
    final dio = await ApiClient.getClient();
    final res = await dio.get('/notifications');
    return (res.data as List<dynamic>)
        .map((e) => AppNotification.fromJson(e))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final dio = await ApiClient.getClient();
    await dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    final dio = await ApiClient.getClient();
    await dio.patch('/notifications/read-all');
  }
}