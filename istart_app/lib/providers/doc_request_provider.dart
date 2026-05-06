// lib/providers/doc_request_provider.dart

import 'package:flutter/material.dart';
import '../models/doc_request.dart';
import '../services/doc_request_service.dart';

class DocRequestProvider extends ChangeNotifier {
  final DocRequestService _service = DocRequestService();

  List<DocRequest> _requests = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<DocRequest> get requests => _requests;
  bool get loading => _loading;
  String? get error => _error;

  /// Fetch all document requests for a specific idea (founder view)
  Future<void> fetchRequestsForIdea(String ideaId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getDocRequestsForIdea(ideaId);
      _requests = data
          .map((item) => DocRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch document requests: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Send a document request (investor action)
  Future<bool> sendDocRequest({
    required String ideaId,
    required String requestMessage,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.sendDocRequest(
        ideaId: ideaId,
        requestMessage: requestMessage,
      );
      // Add the new request to the list if fetched for this idea
      _requests.add(DocRequest.fromJson(data));
      return true;
    } catch (e) {
      _error = 'Failed to send document request: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Reply to a document request with message and optional file (founder action)
  Future<bool> replyToDocRequest({
    required String requestId,
    required String replyMessage,
    String? fileUrl,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.replyToDocRequest(
        requestId: requestId,
        replyMessage: replyMessage,
        fileUrl: fileUrl,
      );

      // Update the request in the list
      final updatedRequest = DocRequest.fromJson(data);
      final index = _requests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _requests[index] = updatedRequest;
      }
      return true;
    } catch (e) {
      _error = 'Failed to reply to document request: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get a single request by ID
  DocRequest? getRequestById(String requestId) {
    try {
      return _requests.firstWhere((req) => req.id == requestId);
    } catch (_) {
      return null;
    }
  }

  /// Clear requests
  void clearRequests() {
    _requests = [];
    _error = null;
    notifyListeners();
  }
}
