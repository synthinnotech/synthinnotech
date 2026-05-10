class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        data: data,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json, String id) =>
      AppNotification(
        id: id,
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'] ?? 'general',
        isRead: json['is_read'] ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        data: json['data'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        'data': data,
      };
}
