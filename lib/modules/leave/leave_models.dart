import 'package:flutter/material.dart';
import 'package:synthinnotech/core/data/db.dart';

enum LeaveType { casual, sick, earned, unpaid }

extension LeaveTypeX on LeaveType {
  String get label => switch (this) {
        LeaveType.casual => 'Casual',
        LeaveType.sick => 'Sick',
        LeaveType.earned => 'Earned',
        LeaveType.unpaid => 'Unpaid',
      };
  IconData get icon => switch (this) {
        LeaveType.casual => Icons.beach_access_outlined,
        LeaveType.sick => Icons.healing_outlined,
        LeaveType.earned => Icons.star_border,
        LeaveType.unpaid => Icons.money_off_outlined,
      };
  static LeaveType fromWire(String? s) => LeaveType.values.firstWhere(
        (t) => t.name == s,
        orElse: () => LeaveType.casual,
      );
}

enum LeaveStatus { pending, approved, rejected, cancelled }

extension LeaveStatusX on LeaveStatus {
  String get label => switch (this) {
        LeaveStatus.pending => 'Pending',
        LeaveStatus.approved => 'Approved',
        LeaveStatus.rejected => 'Rejected',
        LeaveStatus.cancelled => 'Cancelled',
      };
  Color get color => switch (this) {
        LeaveStatus.pending => const Color(0xFFFF9800),
        LeaveStatus.approved => const Color(0xFF4CAF50),
        LeaveStatus.rejected => const Color(0xFFF44336),
        LeaveStatus.cancelled => const Color(0xFF9E9E9E),
      };
  static LeaveStatus fromWire(String? s) => LeaveStatus.values.firstWhere(
        (t) => t.name == s,
        orElse: () => LeaveStatus.pending,
      );
}

class LeaveRequest {
  final String id;
  final String userId;
  final String userName;
  final LeaveType type;
  final DateTime from;
  final DateTime to;
  final String reason;
  final LeaveStatus status;
  final String? reviewerId;
  final String? reviewerName;
  final String? reviewNote;
  final DateTime? createdAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.from,
    required this.to,
    this.reason = '',
    this.status = LeaveStatus.pending,
    this.reviewerId,
    this.reviewerName,
    this.reviewNote,
    this.createdAt,
  });

  int get days => to.difference(from).inDays + 1;

  factory LeaveRequest.fromJson(Map<String, dynamic> json, String id) =>
      LeaveRequest(
        id: id,
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        type: LeaveTypeX.fromWire(json['type']),
        from: Db.readDate(json['from']) ?? DateTime.now(),
        to: Db.readDate(json['to']) ?? DateTime.now(),
        reason: json['reason'] ?? '',
        status: LeaveStatusX.fromWire(json['status']),
        reviewerId: json['reviewer_id'],
        reviewerName: json['reviewer_name'],
        reviewNote: json['review_note'],
        createdAt: Db.readDate(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'type': type.name,
        'from': Db.writeDate(from),
        'to': Db.writeDate(to),
        'reason': reason,
        'status': status.name,
        if (reviewerId != null) 'reviewer_id': reviewerId,
        if (reviewerName != null) 'reviewer_name': reviewerName,
        if (reviewNote != null) 'review_note': reviewNote,
      };
}
