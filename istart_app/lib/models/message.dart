// lib/models/message.dart

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['_id'] ?? '',
        threadId: json['thread'] ?? '',
        senderId: json['sender'] ?? '',
        content: json['content'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}