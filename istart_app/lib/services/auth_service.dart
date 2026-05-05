import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? bio,
  }) async {
    try {
      final dio = await ApiClient.getClient();
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'role': role,
<<<<<<< Updated upstream
        if (bio != null) 'bio': bio,
      },
    );
    await _saveToken(res.data['token']);
    return res.data;
=======
      };
      if (bio != null && bio.isNotEmpty) {
        data['bio'] = bio;
      }

      final res = await dio.post('/auth/register', data: data);
      await _saveToken(res.data['token']);
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw AuthException(_mapAuthError(e));
    } catch (_) {
      throw AuthException('Registration failed. Please try again.');
    }
>>>>>>> Stashed changes
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dio = await ApiClient.getClient();
      final res = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _saveToken(res.data['token']);
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw AuthException(_mapAuthError(e, defaultMessage: 'Invalid email or password.'));
    } catch (_) {
      throw AuthException('Login failed. Please try again.');
    }
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
    try {
      final dio = await ApiClient.getClient();
      final response = await dio.get('/auth/profile');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AuthException(_mapAuthError(e, defaultMessage: 'Failed to load profile.'));
    } catch (_) {
      throw AuthException('Failed to load profile.');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final dio = await ApiClient.getClient();
      final response = await dio.put('/auth/profile', data: data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw AuthException(_mapAuthError(e, defaultMessage: 'Failed to update profile.'));
    } catch (_) {
      throw AuthException('Failed to update profile.');
    }
  }

  String _mapAuthError(
    DioException e, {
    String defaultMessage = 'Something went wrong. Please try again.',
  }) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect. Please check your internet connection.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['msg'] ?? data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return defaultMessage;
  }
}
