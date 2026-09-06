import 'package:flutter/material.dart';
import 'package:synthinnotech/core/data/db.dart';

/// One person's attendance for one calendar day.
class AttendanceRecord {
  final String id;
  final String userId;
  final String userName;
  final String day; // yyyy-MM-dd (local)
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.day,
    this.checkIn,
    this.checkOut,
    this.note,
  });

  bool get isCheckedIn => checkIn != null && checkOut == null;
  bool get isComplete => checkIn != null && checkOut != null;

  Duration? get worked {
    if (checkIn == null) return null;
    return (checkOut ?? DateTime.now()).difference(checkIn!);
  }

  String get workedLabel {
    final d = worked;
    if (d == null) return '—';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  AttendanceStatus get status {
    if (checkIn == null) return AttendanceStatus.absent;
    if (checkOut == null) return AttendanceStatus.working;
    return AttendanceStatus.done;
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json, String id) =>
      AttendanceRecord(
        id: id,
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        day: json['day'] ?? '',
        checkIn: Db.readDate(json['check_in']),
        checkOut: Db.readDate(json['check_out']),
        note: json['note'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'day': day,
        if (checkIn != null) 'check_in': Db.writeDate(checkIn),
        if (checkOut != null) 'check_out': Db.writeDate(checkOut),
        if (note != null) 'note': note,
      };

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

enum AttendanceStatus { absent, working, done }

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.absent => 'Not in',
        AttendanceStatus.working => 'Working',
        AttendanceStatus.done => 'Done',
      };

  Color get color => switch (this) {
        AttendanceStatus.absent => const Color(0xFF9E9E9E),
        AttendanceStatus.working => const Color(0xFF2196F3),
        AttendanceStatus.done => const Color(0xFF4CAF50),
      };
}
