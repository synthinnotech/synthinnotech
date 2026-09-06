import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/service/task_service.dart';

class MyTasksState {
  final bool loading;
  final List<ProjectTask> tasks;
  final String? error;
  const MyTasksState({this.loading = true, this.tasks = const [], this.error});

  List<ProjectTask> get overdue =>
      tasks.where((t) => t.isOverdue).toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
  List<ProjectTask> get today {
    final now = DateTime.now();
    bool sameDay(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    return tasks
        .where((t) =>
            !t.isOverdue &&
            t.status != TaskStatus.done &&
            t.status != TaskStatus.cancelled &&
            (sameDay(t.endDate) ||
                (t.startDate.isBefore(now) && t.endDate.isAfter(now))))
        .toList();
  }

  List<ProjectTask> get upcoming {
    final now = DateTime.now();
    final todaySet = today.map((t) => t.id).toSet();
    return tasks
        .where((t) =>
            t.status != TaskStatus.done &&
            t.status != TaskStatus.cancelled &&
            !t.isOverdue &&
            !todaySet.contains(t.id) &&
            t.endDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
  }

  List<ProjectTask> get done =>
      tasks.where((t) => t.status == TaskStatus.done).toList();
}

class MyTasksViewModel extends StateNotifier<MyTasksState> {
  MyTasksViewModel(this._uid) : super(const MyTasksState()) {
    load();
  }
  final String? _uid;

  Future<void> load() async {
    if (_uid == null) {
      state = const MyTasksState(loading: false);
      return;
    }
    state = MyTasksState(loading: true, tasks: state.tasks);
    try {
      final tasks = await TaskService.getTasksForAssignee(_uid);
      state = MyTasksState(loading: false, tasks: tasks);
    } on AppException catch (e) {
      state = MyTasksState(loading: false, error: e.message);
    }
  }

  Future<void> advance(ProjectTask task) async {
    final next = task.copyWith(status: task.status.next);
    state = MyTasksState(
      loading: false,
      tasks: state.tasks.map((t) => t.id == task.id ? next : t).toList(),
    );
    try {
      await TaskService.updateTask(next);
    } on AppException catch (e) {
      Snack.error(e);
      load();
    }
  }
}

final myTasksProvider =
    StateNotifierProvider.autoDispose<MyTasksViewModel, MyTasksState>((ref) {
  final u = ref.watch(currentUserProvider);
  return MyTasksViewModel(u?.uid);
});
