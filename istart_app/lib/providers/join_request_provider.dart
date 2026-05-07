// lib/providers/join_request_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../models/join_request.dart';
import '../services/join_request_service.dart';

class JoinRequestProvider extends ChangeNotifier {
  final JoinRequestService _service = JoinRequestService();

  List<JoinRequest> _joinRequests = [];
  bool _loading = false;
  String? _error;

  List<JoinRequest> get joinRequests => _joinRequests;

  List<JoinRequest> get pendingRequests =>
      _joinRequests.where((r) => r.status == 'pending').toList();

  List<JoinRequest> get approvedRequests =>
      _joinRequests.where((r) => r.status == 'approved').toList();

  bool get loading => _loading;

  String? get error => _error;

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  /// Send join request to an idea
  Future<bool> sendJoinRequest({
    required String ideaId,
    required String message,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _service.sendRequest(
        ideaId: ideaId,
        message: message,
      );

      return true;
    } catch (e) {
      // Extract backend message from Dio error
      if (e is DioException &&
          e.response?.data is Map) {
        _error =
            e.response?.data['msg'] ??
                'Failed to send request';
      } else {
        _error = 'Failed to send request';
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch join requests for an idea (for founders)
  Future<void> fetchRequestsForIdea(
    String ideaId,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final data =
          await _service.getRequestsForIdea(
        ideaId,
      );

      _joinRequests = (data)
          .map(
            (e) => JoinRequest.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Approve a join request
  Future<bool> approveRequest(
    String requestId,
  ) async {
    try {
      await _service.updateStatus(
        requestId,
        'approved',
      );

      final idx = _joinRequests.indexWhere(
        (r) => r.id == requestId,
      );

      if (idx != -1) {
        final updated = _joinRequests[idx];

        _joinRequests[idx] = JoinRequest(
          id: updated.id,
          ideaId: updated.ideaId,
          collaboratorId:
              updated.collaboratorId,
          collaboratorName:
              updated.collaboratorName,
          collaboratorEmail:
              updated.collaboratorEmail,
          message: updated.message,
          status: 'approved',
          createdAt: updated.createdAt,
          respondedAt: DateTime.now(),
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reject a join request
  Future<bool> rejectRequest(
    String requestId,
  ) async {
    try {
      await _service.updateStatus(
        requestId,
        'rejected',
      );

      final idx = _joinRequests.indexWhere(
        (r) => r.id == requestId,
      );

      if (idx != -1) {
        final updated = _joinRequests[idx];

        _joinRequests[idx] = JoinRequest(
          id: updated.id,
          ideaId: updated.ideaId,
          collaboratorId:
              updated.collaboratorId,
          collaboratorName:
              updated.collaboratorName,
          collaboratorEmail:
              updated.collaboratorEmail,
          message: updated.message,
          status: 'rejected',
          createdAt: updated.createdAt,
          respondedAt: DateTime.now(),
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}