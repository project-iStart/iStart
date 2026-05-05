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
      final fetched = await _service.getIdeaById(id);
      _selectedIdea = fetched;

      final idx = _ideas.indexWhere((idea) => idea.id == id);
      if (idx != -1) {
        _ideas[idx] = fetched;
      }
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
      final result = await _service.toggleBookmark(id);
      final isBookmarked = result['bookmarked'] == true;
      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isBookmarked: isBookmarked);
      }

      if (_selectedIdea?.id == id) {
        _selectedIdea = _selectedIdea!.copyWith(isBookmarked: isBookmarked);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVote(String id, [String? currentUserId]) async {
    try {
      final result = await _service.toggleVote(id);
      final isVoted = result['isVoted'] == true;
      final voteCount = result['voteCount'] is int
          ? result['voteCount'] as int
          : int.tryParse('${result['voteCount']}') ?? 0;

      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(
          isVoted: isVoted,
          voteCount: voteCount,
        );
      }

      if (_selectedIdea?.id == id) {
        _selectedIdea = _selectedIdea!.copyWith(
          isVoted: isVoted,
          voteCount: voteCount,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fundInterest(String ideaId) async {
    // optimistic update
    final idx = _ideas.indexWhere((i) => i.id == ideaId);
    if (idx == -1) return;

    final old = _ideas[idx];
    _ideas[idx] = old.copyWith(
      hasFundingInterest: true,
      fundingInterestCount: old.fundingInterestCount + 1,
    );
    notifyListeners();

    try {
      await _service.fundInterest(ideaId);
    } catch (e) {
      // rollback
      _ideas[idx] = old;
      notifyListeners();
      rethrow;
    }
  }
}
