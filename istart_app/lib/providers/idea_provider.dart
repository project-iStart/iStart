// lib/providers/idea_provider.dart

import 'package:flutter/material.dart';
import '../models/startup_idea.dart';
import '../services/idea_service.dart';

class IdeaProvider extends ChangeNotifier {
  final IdeaService _service = IdeaService();

  List<StartupIdea> _ideas = [];
  StartupIdea? _selectedIdea;
  bool _loading = false;
  String? _error;

  List<StartupIdea> get ideas => _ideas;
  List<StartupIdea> get bookmarkedIdeas =>
      _ideas.where((idea) => idea.isBookmarked).toList();
  StartupIdea? get selectedIdea => _selectedIdea;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  Future<void> fetchIdeas() async {
    _setLoading(true);
    _error = null;
    try {
      _ideas = await _service.getIdeas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchIdeaById(String id) async {
    _setLoading(true);
    _error = null;
    try {
      _selectedIdea = await _service.getIdeaById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createIdea(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _service.createIdea(
        title: data['title'],
        description: data['description'],
      );
      await fetchIdeas();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteIdea(String id) async {
    try {
      await _service.deleteIdea(id);
      _ideas.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBookmark(String id) async {
    try {
      await _service.toggleBookmark(id);
      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isBookmarked: !current.isBookmarked);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVote(String id, [String? currentUserId]) async {
    try {
      await _service.toggleVote(id);
      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        final isVoted = !current.isVoted;
        _ideas[idx] = current.copyWith(
          isVoted: isVoted,
          voteCount: isVoted ? current.voteCount + 1 : current.voteCount - 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
