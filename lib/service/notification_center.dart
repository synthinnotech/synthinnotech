import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/model/notification/app_notification.dart';
import 'package:synthinnotech/service/notification_service.dart';
import 'package:uuid/uuid.dart';

/// One entry point for "something happened" events.
///
///  * shows an on-device notification (via [NotificationService]), and
///  * persists a record to the `notifications` collection so it shows up in
///    the in-app Notifications screen and survives a restart.
///
/// Writes are best-effort: a notification failing to persist must never break
/// the action that triggered it.
class NotificationCenter {
  static const _uuid = Uuid();

  static String _channelFor(String type) {
    switch (type) {
      case 'project':
        return 'project_channel';
      case 'finance':
        return 'finance_channel';
      case 'chat':
        return 'chat_channel';
      default:
        return 'general_channel';
    }
  }

  /// Log + notify the current user.
  static Future<void> push({
    required String title,
    required String body,
    String type = 'general',
    Map<String, String>? data,
    bool showLocal = true,
  }) async {
    if (showLocal) {
      await NotificationService.showNotification(
        title: title,
        body: body,
        channelKey: _channelFor(type),
        payload: data,
        withActions: false,
      );
    }
    final uid = Db.uid;
    if (!Db.enabled || uid == null) return;
    try {
      await Db.notifications.doc(_uuid.v4()).set({
        'user_id': uid,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'created_at': Db.now,
        'data': data,
      });
    } catch (_) {/* best effort */}
  }

  /// Fan a notification out to every active user (used for admin-level events
  /// like announcements). Kept client-side and simple for small teams; a
  /// Cloud Function handles the heavier cases.
  static Future<void> broadcast({
    required String title,
    required String body,
    String type = 'general',
    String? excludeUid,
  }) async {
    if (!Db.enabled) return;
    try {
      final users = await Db.users.where('is_active', isEqualTo: true).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final u in users.docs) {
        if (u.id == excludeUid) continue;
        batch.set(Db.notifications.doc(_uuid.v4()), {
          'user_id': u.id,
          'title': title,
          'body': body,
          'type': type,
          'is_read': false,
          'created_at': Db.now,
        });
      }
      await batch.commit();
    } catch (_) {/* best effort */}
  }

  /// Stream of the current user's notifications, newest first.
  static Stream<List<AppNotification>> watchMine() {
    final uid = Db.uid;
    if (!Db.enabled || uid == null) return Stream.value(const []);
    return Db.guardStream(
      Db.notifications.where('user_id', isEqualTo: uid).snapshots().map((s) {
        final list = s.docs
            .map((d) => AppNotification.fromJson(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }),
    );
  }

  static Future<void> markRead(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.notifications
        .doc(id)
        .set({'is_read': true, 'read_at': Db.now}, SetOptions(merge: true)));
  }

  static Future<void> markAllRead(List<String> ids) async {
    if (!Db.enabled || ids.isEmpty) return;
    return Db.guard(() async {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in ids) {
        batch.set(Db.notifications.doc(id),
            {'is_read': true, 'read_at': Db.now}, SetOptions(merge: true));
      }
      await batch.commit();
    });
  }

  static Future<void> delete(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.notifications.doc(id).delete());
  }
}
