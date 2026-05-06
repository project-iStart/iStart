import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  final Map<String, List<FeedbackModel>> _feedbackByIdea = {};
  bool _submitting = false;

  bool get submitting => _submitting;

  List<FeedbackModel> feedbackFor(String ideaId) =>
      _feedbackByIdea[ideaId] ?? [];

  Future<void> loadFeedback(String ideaId) async {
    final response = await _service.getFeedbackForIdea(ideaId);
    final list = response
        .whereType<Map>()
        .map((json) => FeedbackModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    _feedbackByIdea[ideaId] = list;
    notifyListeners();
  }

  Future<bool> submitFeedback({
    required String ideaId,
    required String category,
    required int rating,
    String? comment,
  }) async {
    _submitting = true;
    notifyListeners();

    try {
      await _service.submitFeedback(
        ideaId: ideaId,
        category: category,
        rating: rating,
        comment: comment ?? '',
      );

      await loadFeedback(ideaId);
      return true;
    } catch (_) {
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
