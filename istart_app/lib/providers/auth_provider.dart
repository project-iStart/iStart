import 'package:flutter/material.dart';
import '../models/user.dart';
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
        name: name, email: email, password: password, role: role,
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
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}