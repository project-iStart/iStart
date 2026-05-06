// lib/models/doc_request.dart

class DocRequest {
  final String id;
  final String investorId;
  final String ideaId;
  final String requestMessage;
  final String? responseMessage;
  final String? fileUrl;
  final String status; // 'pending' | 'responded'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>?
  investor; // Investor details (name, email, profileImage)

  DocRequest({
    required this.id,
    required this.investorId,
    required this.ideaId,
    required this.requestMessage,
    this.responseMessage,
    this.fileUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.investor,
  });

  factory DocRequest.fromJson(Map<String, dynamic> json) => DocRequest(
    id: json['_id'] ?? '',
    investorId: json['investor'] is Map
        ? json['investor']['_id'] ?? ''
        : json['investor'] ?? '',
    ideaId: json['startupIdea'] ?? json['idea'] ?? '',
    requestMessage: json['requestMessage'] ?? '',
    responseMessage: json['responseMessage'],
    fileUrl: json['fileUrl'],
    status: json['status'] ?? 'pending',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null,
    investor: json['investor'] is Map ? json['investor'] : null,
  );

  DocRequest copyWith({
    String? responseMessage,
    String? fileUrl,
    String? status,
  }) => DocRequest(
    id: id,
    investorId: investorId,
    ideaId: ideaId,
    requestMessage: requestMessage,
    responseMessage: responseMessage ?? this.responseMessage,
    fileUrl: fileUrl ?? this.fileUrl,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    investor: investor,
  );
}
