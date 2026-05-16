class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) =>
      ChatMessage(
        id: id,
        senderId: json['sender_id'] ?? '',
        senderName: json['sender_name'] ?? '',
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'sender_name': senderName,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };
}
