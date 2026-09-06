import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/announcements/announcement.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/service/notification_center.dart';
import 'package:uuid/uuid.dart';

class AnnouncementsState {
  final bool loading;
  final List<Announcement> items;
  final String? error;
  const AnnouncementsState(
      {this.loading = true, this.items = const [], this.error});
}

class AnnouncementsViewModel extends StateNotifier<AnnouncementsState> {
  AnnouncementsViewModel(this._authorId, this._authorName)
      : super(const AnnouncementsState()) {
    if (!Db.enabled) {
      state = const AnnouncementsState(loading: false);
      return;
    }
    _sub = Db.guardStream(Db.announcements.snapshots().map((s) {
      final list = s.docs
          .map((d) => Announcement.fromJson(d.data(), d.id))
          .toList()
        ..sort((a, b) {
          if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
      return list;
    })).listen(
      (list) => state = AnnouncementsState(loading: false, items: list),
      onError: (e) => state = AnnouncementsState(
          loading: false,
          error: e is AppException ? e.message : e.toString()),
    );
  }

  final String _authorId;
  final String _authorName;
  StreamSubscription? _sub;
  static const _uuid = Uuid();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<bool> post(
      {required String title, required String body, bool pinned = false}) async {
    if (title.trim().isEmpty) return false;
    try {
      final a = Announcement(
        id: '',
        title: title.trim(),
        body: body.trim(),
        authorId: _authorId,
        authorName: _authorName,
        pinned: pinned,
      );
      await Db.guard(() => Db.announcements
          .doc(_uuid.v4())
          .set({...a.toJson(), 'created_at': Db.now}));
      NotificationCenter.broadcast(
        title: 'Announcement: ${a.title}',
        body: a.body.isEmpty ? 'Tap to read' : a.body,
        type: 'general',
        excludeUid: _authorId,
      );
      Snack.success('Announcement posted');
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<void> togglePin(Announcement a) async {
    try {
      await Db.guard(() => Db.announcements
          .doc(a.id)
          .set({'pinned': !a.pinned}, SetOptions(merge: true)));
    } on AppException catch (e) {
      Snack.error(e);
    }
  }

  Future<void> delete(Announcement a) async {
    try {
      await Db.guard(() => Db.announcements.doc(a.id).delete());
      Snack.success('Deleted');
    } on AppException catch (e) {
      Snack.error(e);
    }
  }
}

final announcementsViewModelProvider = StateNotifierProvider.autoDispose<
    AnnouncementsViewModel, AnnouncementsState>((ref) {
  final u = ref.watch(currentUserProvider);
  return AnnouncementsViewModel(u?.uid ?? '', u?.name ?? 'Admin');
});
