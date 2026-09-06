import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/attendance/attendance_models.dart';
import 'package:synthinnotech/modules/attendance/attendance_service.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

class AttendanceState {
  final bool loading;
  final bool busy;
  final AttendanceRecord? today;
  final List<AttendanceRecord> history;
  final String? error;

  const AttendanceState({
    this.loading = true,
    this.busy = false,
    this.today,
    this.history = const [],
    this.error,
  });

  AttendanceState copyWith({
    bool? loading,
    bool? busy,
    Object? today = _s,
    List<AttendanceRecord>? history,
    Object? error = _s,
  }) =>
      AttendanceState(
        loading: loading ?? this.loading,
        busy: busy ?? this.busy,
        today: identical(today, _s) ? this.today : today as AttendanceRecord?,
        history: history ?? this.history,
        error: identical(error, _s) ? this.error : error as String?,
      );
  static const _s = Object();

  int get presentDays => history.where((r) => r.checkIn != null).length;
  Duration get monthWorked => history
      .where((r) => r.worked != null)
      .fold(Duration.zero, (t, r) => t + r.worked!);
}

class AttendanceViewModel extends StateNotifier<AttendanceState> {
  AttendanceViewModel(this._uid, this._name) : super(const AttendanceState()) {
    _bind();
    refreshHistory();
  }

  final String? _uid;
  final String _name;
  StreamSubscription<AttendanceRecord?>? _sub;

  void _bind() {
    if (_uid == null) {
      state = state.copyWith(loading: false);
      return;
    }
    _sub = AttendanceService.watchToday(_uid).listen(
      (rec) => state = state.copyWith(loading: false, today: rec),
      onError: (e) => state = state.copyWith(
          loading: false,
          error: e is AppException ? e.message : e.toString()),
    );
  }

  Future<void> refreshHistory() async {
    if (_uid == null) return;
    try {
      final h = await AttendanceService.myHistory(_uid);
      state = state.copyWith(history: h);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> checkIn({String? note}) async {
    if (_uid == null) return;
    state = state.copyWith(busy: true);
    try {
      await AttendanceService.checkIn(uid: _uid, name: _name, note: note);
      Snack.success('Checked in — have a great day!');
      await refreshHistory();
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> checkOut() async {
    if (_uid == null) return;
    state = state.copyWith(busy: true);
    try {
      await AttendanceService.checkOut(uid: _uid);
      Snack.success('Checked out. See you tomorrow!');
      await refreshHistory();
    } on AppException catch (e) {
      Snack.error(e);
    } finally {
      state = state.copyWith(busy: false);
    }
  }
}

final attendanceViewModelProvider = StateNotifierProvider.autoDispose<
    AttendanceViewModel, AttendanceState>((ref) {
  final u = ref.watch(currentUserProvider);
  return AttendanceViewModel(u?.uid, u?.name ?? 'Me');
});

/// Team attendance for a chosen day (managers/admins).
final teamAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, DateTime>((ref, day) {
  return AttendanceService.teamForDay(day);
});
