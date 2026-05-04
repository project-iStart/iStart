import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? bio,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'bio': ?bio,
      },
    );
    await _saveToken(res.data['token']);
    return res.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dio = await ApiClient.getClient();
    final res = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _saveToken(res.data['token']);
    return res.data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final dio = await ApiClient.getClient();
    final response = await dio.get('/auth/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final dio = await ApiClient.getClient();
    final response = await dio.put('/auth/profile', data: data);
    return response.data;
  }
}
