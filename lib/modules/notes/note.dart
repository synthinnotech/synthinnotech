import 'package:synthinnotech/core/data/db.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final String ownerId;
  final String ownerName;
  final bool shared;
  final bool pinned;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.ownerId,
    this.ownerName = '',
    this.shared = false,
    this.pinned = false,
    this.colorValue = 0xFFFFF8E1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  factory Note.fromJson(Map<String, dynamic> json, String id) => Note(
        id: id,
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        ownerId: json['owner_id'] ?? '',
        ownerName: json['owner_name'] ?? '',
        shared: json['shared'] ?? false,
        pinned: json['pinned'] ?? false,
        colorValue: (json['color'] as num?)?.toInt() ?? 0xFFFFF8E1,
        createdAt: Db.readDate(json['created_at']),
        updatedAt: Db.readDate(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'owner_id': ownerId,
        'owner_name': ownerName,
        'shared': shared,
        'pinned': pinned,
        'color': colorValue,
      };

  Note copyWith({
    String? title,
    String? body,
    bool? shared,
    bool? pinned,
    int? colorValue,
  }) =>
      Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        ownerId: ownerId,
        ownerName: ownerName,
        shared: shared ?? this.shared,
        pinned: pinned ?? this.pinned,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  static const palette = <int>[
    0xFFFFF8E1, // amber
    0xFFE3F2FD, // blue
    0xFFE8F5E9, // green
    0xFFFCE4EC, // pink
    0xFFF3E5F5, // purple
    0xFFFFFFFF, // white
  ];
}
