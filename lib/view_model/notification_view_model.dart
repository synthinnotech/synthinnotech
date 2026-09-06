import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/model/notification/app_notification.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/service/notification_center.dart';

class NotificationsState {
  final bool isLoading;
  final List<AppNotification> notifications;

  const NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
  }) =>
      NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        notifications: notifications ?? this.notifications,
      );

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsViewModel extends StateNotifier<NotificationsState> {
  StreamSubscription<List<AppNotification>>? _sub;

  NotificationsViewModel() : super(const NotificationsState(isLoading: true)) {
    if (Db.enabled) {
      _sub = NotificationCenter.watchMine().listen(
        (list) =>
            state = NotificationsState(isLoading: false, notifications: list),
        onError: (_) => state = state.copyWith(isLoading: false),
      );
    } else {
      state = const NotificationsState(isLoading: false, notifications: []);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void markAsRead(String id) {
    // Optimistic; Firestore stream will reconcile.
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
    if (Db.enabled) NotificationCenter.markRead(id);
  }

  void markAllRead() {
    final unreadIds =
        state.notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    if (Db.enabled) NotificationCenter.markAllRead(unreadIds);
  }

  void delete(String id) {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
    if (Db.enabled) NotificationCenter.delete(id);
  }

  void addNotification(AppNotification notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

}

final notificationsViewModelProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>((ref) {
  // Rebuild (and re-subscribe) whenever the signed-in user changes so the
  // feed is always scoped to the current account.
  ref.watch(currentUserProvider.select((u) => u?.uid));
  return NotificationsViewModel();
});
