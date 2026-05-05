import 'package:flutter/material.dart';
import '../services/discussion_service.dart';

class DiscussionProvider extends ChangeNotifier {
  final DiscussionService _service = DiscussionService();

  List<dynamic> _threads = [];
  bool _loading = false;
  String? _error;

  List<dynamic> get threads => _threads;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchThreadsForIdea(String ideaId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getThreadsForIdea(ideaId);
      _threads = response;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createThread({
    required String ideaId,
    required String title,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createThread(ideaId: ideaId, title: title);
      await fetchThreadsForIdea(ideaId);
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
