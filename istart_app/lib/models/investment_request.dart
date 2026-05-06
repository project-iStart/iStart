// lib/models/investment_request.dart

class InvestmentRequest {
  final String id;
  final String ideaId;
  final String investorId;
  final String investorName;
  final String investorEmail;
  final double? fundingAmount;
  final String message;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? respondedAt;

  InvestmentRequest({
    required this.id,
    required this.ideaId,
    required this.investorId,
    required this.investorName,
    required this.investorEmail,
    this.fundingAmount,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory InvestmentRequest.fromJson(Map<String, dynamic> json) =>
      InvestmentRequest(
        id: json['_id'] ?? '',
        ideaId: json['startupIdea']?['_id'] ?? json['startupIdea'] ?? '',
        investorId: json['investor']?['_id'] ?? json['investor'] ?? '',
        investorName: json['investor']?['name'] ?? 'Unknown Investor',
        investorEmail: json['investor']?['email'] ?? '',
        fundingAmount: json['fundingAmount']?.toDouble(),
        message: json['message'] ?? '',
        status: json['status'] ?? 'pending',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        respondedAt: json['respondedAt'] != null
            ? DateTime.tryParse(json['respondedAt'])
            : null,
      );
}
