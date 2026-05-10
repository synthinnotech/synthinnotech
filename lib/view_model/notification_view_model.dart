import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/notification/app_notification.dart';

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
  NotificationsViewModel()
      : super(const NotificationsState(isLoading: true)) {
    _load();
  }

  void _load() {
    state = state.copyWith(
      isLoading: false,
      notifications: _mockNotifications(),
    );
  }

  void markAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
  }

  void markAllRead() {
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void delete(String id) {
    state = state.copyWith(
      notifications:
          state.notifications.where((n) => n.id != id).toList(),
    );
  }

  void addNotification(AppNotification notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

  List<AppNotification> _mockNotifications() => [
        AppNotification(
          id: 'n1',
          title: 'Project Update',
          body: 'Mobile App Redesign progress updated to 75%',
          type: 'project',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        AppNotification(
          id: 'n2',
          title: 'Payment Received',
          body: 'Client payment of ₹25,000 received from TechCorp',
          type: 'finance',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'n3',
          title: 'New Employee',
          body: 'Kavya Reddy has joined as Backend Intern',
          type: 'employee',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AppNotification(
          id: 'n4',
          title: 'Deadline Alert',
          body: 'E-commerce Platform deadline was 2 days ago',
          type: 'project',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        AppNotification(
          id: 'n5',
          title: 'Monthly Report',
          body: 'December financial report is ready for review',
          type: 'finance',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
}

final notificationsViewModelProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>(
  (ref) => NotificationsViewModel(),
);
