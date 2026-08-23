class Note {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorValue;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.colorValue,
  });

  factory Note.fromJson(Map<String, dynamic> json, String id) => Note(
        id: id,
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        createdBy: json['created_by'] ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
            DateTime.now(),
        colorValue: json['color'] is int ? json['color'] as int : 0xFFFFF59D,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'color': colorValue,
      };

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    int? colorValue,
  }) =>
      Note(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        colorValue: colorValue ?? this.colorValue,
      );
}
