import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/modules/leave/leave_models.dart';
import 'package:uuid/uuid.dart';

class LeaveService {
  static const _uuid = Uuid();

  static Stream<List<LeaveRequest>> watchMine(String uid) {
    if (!Db.enabled) return Stream.value(const []);
    return Db.guardStream(
      Db.leaveRequests.where('user_id', isEqualTo: uid).snapshots().map((s) {
        final list = s.docs
            .map((d) => LeaveRequest.fromJson(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.from.compareTo(a.from));
        return list;
      }),
    );
  }

  static Stream<List<LeaveRequest>> watchPending() {
    if (!Db.enabled) return Stream.value(const []);
    return Db.guardStream(
      Db.leaveRequests
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((s) {
        final list = s.docs
            .map((d) => LeaveRequest.fromJson(d.data(), d.id))
            .toList()
          ..sort((a, b) => a.from.compareTo(b.from));
        return list;
      }),
    );
  }

  static Future<void> submit(LeaveRequest req) async {
    if (!Db.enabled) {
      throw const AppException('Firebase is not configured.',
          code: 'unavailable');
    }
    return Db.guard(() => Db.leaveRequests.doc(_uuid.v4()).set({
          ...req.toJson(),
          'status': 'pending',
          'created_at': Db.now,
        }));
  }

  static Future<void> cancel(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.leaveRequests
        .doc(id)
        .set({'status': 'cancelled'}, SetOptions(merge: true)));
  }

  static Future<void> review({
    required String id,
    required bool approve,
    required String reviewerId,
    required String reviewerName,
    String? note,
  }) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.leaveRequests.doc(id).set({
          'status': approve ? 'approved' : 'rejected',
          'reviewer_id': reviewerId,
          'reviewer_name': reviewerName,
          if (note != null && note.isNotEmpty) 'review_note': note,
          'reviewed_at': Db.now,
        }, SetOptions(merge: true)));
  }
}
