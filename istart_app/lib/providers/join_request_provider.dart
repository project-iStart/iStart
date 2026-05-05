import 'package:flutter/material.dart';
import '../services/join_request_service.dart';

class JoinRequestProvider extends ChangeNotifier {
  final JoinRequestService _service = JoinRequestService();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> sendJoinRequest({
    required String ideaId,
    required String message,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.sendRequest(ideaId: ideaId, message: message);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
