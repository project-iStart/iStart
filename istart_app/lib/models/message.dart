// lib/models/message.dart

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['_id'] ?? '',
    threadId: json['thread'] ?? '',
    senderId: json['sender']?['_id'] ?? json['sender'] ?? '',
    senderName: json['sender']?['name'] ?? 'Unknown',
    senderEmail: json['sender']?['email'] ?? '',
    content: json['content'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
