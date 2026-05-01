import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  final AuthService _authService = AuthService();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _user = UserModel.fromJson(data['user']);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.login(email: email, password: password);
      _user = UserModel.fromJson(data['user']);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // clear the saved token — use whichever you have:
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      // OR if using flutter_secure_storage:
      // await const FlutterSecureStorage().delete(key: 'token');
    } catch (e) {
      _error = e.toString();
    } finally {
      _user = null;
      _loading = false;
      notifyListeners();
    }
  }

  // Fetch fresh profile from backend
  Future<void> fetchProfile() async {
    try {
      final data = await _authService.getProfile();
      _user = UserModel.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  // Update profile fields
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final updated = await _authService.updateProfile(data);
      _user = UserModel.fromJson(updated);
      notifyListeners();
      return true;
    } catch (e) {
      print('updateProfile error: $e');
      _error = e.toString();
      return false;
    }
  }
}
