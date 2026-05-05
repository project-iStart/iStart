// lib/models/join_request.dart

class JoinRequest {
  final String id;
  final String ideaId;
  final String collaboratorId;
  final String collaboratorName;
  final String collaboratorEmail;
  final String message;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? respondedAt;

  JoinRequest({
    required this.id,
    required this.ideaId,
    required this.collaboratorId,
    required this.collaboratorName,
    required this.collaboratorEmail,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
    id: json['_id'] ?? '',
    ideaId: json['idea'] ?? '',
    collaboratorId: json['collaborator']?['_id'] ?? json['collaborator'] ?? '',
    collaboratorName: json['collaborator']?['name'] ?? 'Unknown',
    collaboratorEmail: json['collaborator']?['email'] ?? '',
    message: json['message'] ?? '',
    status: json['status'] ?? 'pending',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    respondedAt: json['respondedAt'] != null
        ? DateTime.tryParse(json['respondedAt'])
        : null,
  );
}
