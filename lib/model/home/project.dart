import 'package:flutter/material.dart';

enum ProjectStatus {
  available,
  inProgress,
  done,
  review,
  cancelled,
  onTrack,
  delayed,
  completed,
  pending
}

extension ProjectStatusExt on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.available:
        return 'Available';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.done:
        return 'Done';
      case ProjectStatus.review:
        return 'Review';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.onTrack:
        return 'On Track';
      case ProjectStatus.delayed:
        return 'Delayed';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.available:
        return const Color(0xFF2196F3);
      case ProjectStatus.inProgress:
        return const Color(0xFF9C27B0);
      case ProjectStatus.done:
        return const Color(0xFF4CAF50);
      case ProjectStatus.review:
        return const Color(0xFFFF9800);
      case ProjectStatus.cancelled:
        return const Color(0xFFF44336);
      case ProjectStatus.onTrack:
        return const Color(0xFF4CAF50);
      case ProjectStatus.delayed:
        return const Color(0xFFF44336);
      case ProjectStatus.completed:
        return const Color(0xFF4CAF50);
      case ProjectStatus.pending:
        return const Color(0xFFFF9800);
    }
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final String clientName;
  final ProjectStatus status;
  final double progress;
  final double budget;
  final double spent;
  final DateTime? startDate;
  final DateTime? deadline;
  final List<String> teamMemberIds;
  final String? createdBy;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    this.clientName = '',
    this.status = ProjectStatus.available,
    this.progress = 0,
    this.budget = 0,
    this.spent = 0,
    this.startDate,
    this.deadline,
    this.teamMemberIds = const [],
    this.createdBy,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json, String id) => Project(
        id: id,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        clientName: json['client_name'] ?? '',
        status: _parseStatus(json['status']),
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        budget: (json['budget'] as num?)?.toDouble() ?? 0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'].toString())
            : null,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        teamMemberIds: List<String>.from(json['team_member_ids'] ?? []),
        createdBy: json['created_by'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'client_name': clientName,
        'status': status.name,
        'progress': progress,
        'budget': budget,
        'spent': spent,
        'start_date': startDate?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'team_member_ids': teamMemberIds,
        'created_by': createdBy,
        'created_at': createdAt?.toIso8601String(),
      };

  Project copyWith({
    String? name,
    String? description,
    String? clientName,
    ProjectStatus? status,
    double? progress,
    double? budget,
    double? spent,
    DateTime? deadline,
    List<String>? teamMemberIds,
  }) =>
      Project(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        clientName: clientName ?? this.clientName,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        budget: budget ?? this.budget,
        spent: spent ?? this.spent,
        startDate: startDate,
        deadline: deadline ?? this.deadline,
        teamMemberIds: teamMemberIds ?? this.teamMemberIds,
        createdBy: createdBy,
        createdAt: createdAt,
      );

  static ProjectStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return ProjectStatus.inProgress;
      case 'done':
        return ProjectStatus.done;
      case 'review':
        return ProjectStatus.review;
      case 'cancelled':
        return ProjectStatus.cancelled;
      case 'onTrack':
        return ProjectStatus.onTrack;
      case 'delayed':
        return ProjectStatus.delayed;
      case 'completed':
        return ProjectStatus.completed;
      case 'pending':
        return ProjectStatus.pending;
      default:
        return ProjectStatus.available;
    }
  }
}
