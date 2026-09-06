import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/modules/attendance/attendance_models.dart';

class AttendanceService {
  /// Deterministic doc id — one record per user per day.
  static String _docId(String uid, String day) => '${uid}_$day';

  static Stream<AttendanceRecord?> watchToday(String uid) {
    if (!Db.enabled) return Stream.value(null);
    final day = AttendanceRecord.dayKey(DateTime.now());
    return Db.guardStream(
      Db.attendance.doc(_docId(uid, day)).snapshots().map(
            (d) => d.exists ? AttendanceRecord.fromJson(d.data()!, d.id) : null,
          ),
    );
  }

  /// My last [limit] days, newest first.
  static Future<List<AttendanceRecord>> myHistory(String uid,
      {int limit = 30}) async {
    if (!Db.enabled) return const [];
    return Db.guard(() async {
      final snap = await Db.attendance.where('user_id', isEqualTo: uid).get();
      final list = snap.docs
          .map((d) => AttendanceRecord.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.day.compareTo(a.day));
      return list.take(limit).toList();
    });
  }

  /// Everyone's records for a given day (managers/admins only).
  static Future<List<AttendanceRecord>> teamForDay(DateTime day) async {
    if (!Db.enabled) return const [];
    final key = AttendanceRecord.dayKey(day);
    return Db.guard(() async {
      final snap = await Db.attendance.where('day', isEqualTo: key).get();
      final list = snap.docs
          .map((d) => AttendanceRecord.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) => a.userName.compareTo(b.userName));
      return list;
    });
  }

  static Future<void> checkIn({
    required String uid,
    required String name,
    String? note,
  }) async {
    if (!Db.enabled) {
      throw const AppException('Firebase is not configured.',
          code: 'unavailable');
    }
    final day = AttendanceRecord.dayKey(DateTime.now());
    return Db.guard(() async {
      final ref = Db.attendance.doc(_docId(uid, day));
      final existing = await ref.get();
      if (existing.exists && existing.data()?['check_in'] != null) {
        throw const AppException('You have already checked in today.',
            code: 'already-exists');
      }
      await ref.set({
        'user_id': uid,
        'user_name': name,
        'day': day,
        'check_in': Db.now,
        if (note != null && note.isNotEmpty) 'note': note,
        'created_at': Db.now,
      }, SetOptions(merge: true));
    });
  }

  static Future<void> checkOut({required String uid}) async {
    if (!Db.enabled) {
      throw const AppException('Firebase is not configured.',
          code: 'unavailable');
    }
    final day = AttendanceRecord.dayKey(DateTime.now());
    return Db.guard(() async {
      final ref = Db.attendance.doc(_docId(uid, day));
      final existing = await ref.get();
      if (!existing.exists || existing.data()?['check_in'] == null) {
        throw const AppException('Check in first.', code: 'failed-precondition');
      }
      await ref.set({'check_out': Db.now}, SetOptions(merge: true));
    });
  }
}
