// lib/models/doc_request.dart

class DocRequest {
  final String id;
  final String investorId;
  final String ideaId;
  final String requestMessage;
  final String? replyMessage;
  final String? fileUrl;
  final String status; // 'pending' | 'responded'
  final DateTime createdAt;

  DocRequest({
    required this.id,
    required this.investorId,
    required this.ideaId,
    required this.requestMessage,
    this.replyMessage,
    this.fileUrl,
    required this.status,
    required this.createdAt,
  });

  factory DocRequest.fromJson(Map<String, dynamic> json) => DocRequest(
        id: json['_id'] ?? '',
        investorId: json['investor'] ?? '',
        ideaId: json['idea'] ?? '',
        requestMessage: json['requestMessage'] ?? '',
        replyMessage: json['replyMessage'],
        fileUrl: json['fileUrl'],
        status: json['status'] ?? 'pending',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}