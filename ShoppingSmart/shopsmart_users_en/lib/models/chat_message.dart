/// Loại tin nhắn trong chat
enum MessageType { user, staff, system, ai }

/// Lớp đại diện cho một tin nhắn chat
class ChatMessage {
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? mentionedProducts;

  ChatMessage({
    required this.content,
    required this.type,
    required this.timestamp,
    this.mentionedProducts,
  });

  /// Chuyển đổi tin nhắn thành JSON để lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Tạo tin nhắn từ JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType messageType;
    if (json['type'] == 'user') {
      messageType = MessageType.user;
    } else if (json['type'] == 'staff') {
      messageType = MessageType.staff;
    } else {
      messageType = MessageType.system;
    }

    return ChatMessage(
      content: json['content'],
      type: messageType,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
