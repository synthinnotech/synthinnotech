import 'package:synthinnotech/core/data/db.dart';

class Announcement {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final bool pinned;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.pinned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Announcement.fromJson(Map<String, dynamic> json, String id) =>
      Announcement(
        id: id,
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        authorId: json['author_id'] ?? '',
        authorName: json['author_name'] ?? 'Admin',
        pinned: json['pinned'] ?? false,
        createdAt: Db.readDate(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'author_id': authorId,
        'author_name': authorName,
        'pinned': pinned,
      };
}
