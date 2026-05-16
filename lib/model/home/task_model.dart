import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done, cancelled }

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return const Color(0xFF9E9E9E);
      case TaskStatus.inProgress:
        return const Color(0xFF2196F3);
      case TaskStatus.done:
        return const Color(0xFF4CAF50);
      case TaskStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }

  TaskStatus get next {
    switch (this) {
      case TaskStatus.todo:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.done;
      case TaskStatus.done:
        return TaskStatus.todo;
      case TaskStatus.cancelled:
        return TaskStatus.todo;
    }
  }
}

class ProjectTask {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final TaskStatus status;
  final DateTime? createdAt;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.status = TaskStatus.todo,
    this.createdAt,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json, String id) =>
      ProjectTask(
        id: id,
        projectId: json['project_id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
            DateTime.now(),
        endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ??
            DateTime.now().add(const Duration(days: 7)),
        status: _parseStatus(json['status']),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'name': name,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status.name,
        'created_at': createdAt?.toIso8601String(),
      };

  ProjectTask copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
  }) =>
      ProjectTask(
        id: id,
        projectId: projectId,
        name: name ?? this.name,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  static TaskStatus _parseStatus(String? s) {
    switch (s) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
  }
}
