// lib/providers/investment_request_provider.dart

import 'package:flutter/material.dart';
import '../models/investment_request.dart';
import '../services/investment_request_service.dart';

class InvestmentRequestProvider extends ChangeNotifier {
  final InvestmentRequestService _service = InvestmentRequestService();

  List<InvestmentRequest> _investmentRequests = [];
  List<InvestmentRequest> _myRequests = [];
  bool _loading = false;
  String? _error;

  List<InvestmentRequest> get investmentRequests => _investmentRequests;
  List<InvestmentRequest> get pendingRequests =>
      _investmentRequests.where((r) => r.status == 'pending').toList();
  List<InvestmentRequest> get approvedRequests =>
      _investmentRequests.where((r) => r.status == 'approved').toList();
  List<InvestmentRequest> get myRequests => _myRequests;
  List<InvestmentRequest> get myPendingRequests =>
      _myRequests.where((r) => r.status == 'pending').toList();
  List<InvestmentRequest> get myApprovedRequests =>
      _myRequests.where((r) => r.status == 'approved').toList();
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  /// Send funding request to an idea
  Future<bool> sendFundingRequest({
    required String ideaId,
    required double? fundingAmount,
    required String message,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.sendRequest(
        ideaId: ideaId,
        fundingAmount: fundingAmount,
        message: message,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch investment requests for an idea (for founders)
  Future<void> fetchRequestsForIdea(String ideaId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _service.getRequestsForIdea(ideaId);
      _investmentRequests = (data)
          .map((e) => InvestmentRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch investor's own requests
  Future<void> fetchMyRequests() async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _service.getMyRequests();
      _myRequests = (data)
          .map((e) => InvestmentRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Approve an investment request
  Future<bool> approveRequest(String requestId) async {
    try {
      await _service.updateStatus(requestId, 'approved');
      final idx = _investmentRequests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        final updated = _investmentRequests[idx];
        _investmentRequests[idx] = InvestmentRequest(
          id: updated.id,
          ideaId: updated.ideaId,
          investorId: updated.investorId,
          investorName: updated.investorName,
          investorEmail: updated.investorEmail,
          fundingAmount: updated.fundingAmount,
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

  /// Reject an investment request
  Future<bool> rejectRequest(String requestId) async {
    try {
      await _service.updateStatus(requestId, 'rejected');
      final idx = _investmentRequests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        final updated = _investmentRequests[idx];
        _investmentRequests[idx] = InvestmentRequest(
          id: updated.id,
          ideaId: updated.ideaId,
          investorId: updated.investorId,
          investorName: updated.investorName,
          investorEmail: updated.investorEmail,
          fundingAmount: updated.fundingAmount,
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
