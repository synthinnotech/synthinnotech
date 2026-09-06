import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/leave/leave_models.dart';
import 'package:synthinnotech/modules/leave/leave_service.dart';
import 'package:synthinnotech/service/notification_center.dart';

class LeaveListState {
  final bool loading;
  final List<LeaveRequest> items;
  final String? error;
  const LeaveListState({this.loading = true, this.items = const [], this.error});
}

class MyLeaveViewModel extends StateNotifier<LeaveListState> {
  MyLeaveViewModel(this._uid, this._name) : super(const LeaveListState()) {
    _bind();
  }
  final String? _uid;
  final String _name;
  StreamSubscription? _sub;

  void _bind() {
    if (_uid == null) {
      state = const LeaveListState(loading: false);
      return;
    }
    _sub = LeaveService.watchMine(_uid).listen(
      (list) => state = LeaveListState(loading: false, items: list),
      onError: (e) => state = LeaveListState(
          loading: false,
          error: e is AppException ? e.message : e.toString()),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<bool> submit({
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required String reason,
  }) async {
    if (_uid == null) return false;
    try {
      await LeaveService.submit(LeaveRequest(
        id: '',
        userId: _uid,
        userName: _name,
        type: type,
        from: from,
        to: to,
        reason: reason.trim(),
      ));
      NotificationCenter.push(
        title: 'Leave request submitted',
        body: '${type.label} leave · ${to.difference(from).inDays + 1} day(s)',
        type: 'general',
      );
      Snack.success('Leave request submitted for approval');
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<void> cancel(LeaveRequest r) async {
    try {
      await LeaveService.cancel(r.id);
      Snack.success('Request cancelled');
    } on AppException catch (e) {
      Snack.error(e);
    }
  }
}

final myLeaveProvider =
    StateNotifierProvider.autoDispose<MyLeaveViewModel, LeaveListState>((ref) {
  final u = ref.watch(currentUserProvider);
  return MyLeaveViewModel(u?.uid, u?.name ?? 'Me');
});

// ── Approvals (managers/admins) ────────────────────────────────────────────

class PendingLeaveViewModel extends StateNotifier<LeaveListState> {
  PendingLeaveViewModel(this._reviewerId, this._reviewerName)
      : super(const LeaveListState()) {
    _sub = LeaveService.watchPending().listen(
      (list) => state = LeaveListState(loading: false, items: list),
      onError: (e) => state = LeaveListState(
          loading: false,
          error: e is AppException ? e.message : e.toString()),
    );
  }
  final String _reviewerId;
  final String _reviewerName;
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> decide(LeaveRequest r, bool approve, {String? note}) async {
    try {
      await LeaveService.review(
        id: r.id,
        approve: approve,
        reviewerId: _reviewerId,
        reviewerName: _reviewerName,
        note: note,
      );
      NotificationCenter.pushTo(
        uid: r.userId,
        title: approve ? 'Leave approved' : 'Leave rejected',
        body: 'Your ${r.type.label} leave '
            '(${r.days} day${r.days == 1 ? '' : 's'}) was '
            '${approve ? 'approved' : 'rejected'} by $_reviewerName.',
        type: 'general',
      );
      Snack.success(approve ? 'Approved' : 'Rejected');
    } on AppException catch (e) {
      Snack.error(e);
    }
  }
}

final pendingLeaveProvider = StateNotifierProvider.autoDispose<
    PendingLeaveViewModel, LeaveListState>((ref) {
  final u = ref.watch(currentUserProvider);
  return PendingLeaveViewModel(u?.uid ?? '', u?.name ?? 'Reviewer');
});
