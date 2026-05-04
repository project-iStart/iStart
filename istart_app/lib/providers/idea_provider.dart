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
      _ideas.where((i) => i.isBookmarked).toList();
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
          title: data['title'], description: data['description']);
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

  /// Optimistic toggle — flips locally first, calls API, reverts on failure.
  Future<void> toggleVote(String ideaId, String currentUserId) async {
    final idx = _ideas.indexWhere((i) => i.id == ideaId);
    if (idx == -1) return;

    final idea = _ideas[idx];

    // Founder cannot vote on their own idea
    final founderId = idea.founder['_id']?.toString() ?? '';
    if (founderId == currentUserId) return;

    final wasVoted = idea.isVoted;
    final newVoted = !wasVoted;
    final newCount = newVoted ? idea.voteCount + 1 : idea.voteCount - 1;

    // Optimistic update
    _ideas[idx] = idea.copyWith(isVoted: newVoted, voteCount: newCount);
    notifyListeners();

    try {
      await _service.toggleVote(ideaId);
      // Notification is only sent server-side on first upvote (not on re-vote).
      // Backend handles this logic — no extra call needed here.
    } catch (e) {
      // Revert on failure
      _ideas[idx] = idea;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Optimistic toggle — flips locally first, calls API, reverts on failure.
  Future<void> toggleBookmark(String ideaId) async {
    final idx = _ideas.indexWhere((i) => i.id == ideaId);
    if (idx == -1) return;

    final idea = _ideas[idx];
    final newBookmarked = !idea.isBookmarked;

    // Optimistic update
    _ideas[idx] = idea.copyWith(isBookmarked: newBookmarked);
    notifyListeners();

    try {
      await _service.toggleBookmark(ideaId);
    } catch (e) {
      // Revert on failure
      _ideas[idx] = idea;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}