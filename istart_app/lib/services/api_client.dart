import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static Future<Dio> getClient({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final authToken = token ?? storedToken;

    return Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    ));
  }

  Future<Response> get(String path, {String? token}) async {
    final client = await ApiClient.getClient(token: token);
    return client.get(path);
  }

  Future<Response> patch(String path, dynamic data, {String? token}) async {
    final client = await ApiClient.getClient(token: token);
    return client.patch(path, data: data);
  }
}