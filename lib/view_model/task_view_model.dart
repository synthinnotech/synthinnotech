import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:synthinnotech/service/task_service.dart';

class TasksState {
  final bool isLoading;
  final List<ProjectTask> tasks;
  final String? error;

  const TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.error,
  });

  TasksState copyWith({
    bool? isLoading,
    List<ProjectTask>? tasks,
    Object? error = _sentinel,
  }) =>
      TasksState(
        isLoading: isLoading ?? this.isLoading,
        tasks: tasks ?? this.tasks,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );

  static const _sentinel = Object();

  int get openCount =>
      tasks.where((t) => t.status != TaskStatus.done && t.status != TaskStatus.cancelled).length;
  double get completion => tasks.isEmpty
      ? 0
      : tasks.where((t) => t.status == TaskStatus.done).length / tasks.length;
}

class TasksViewModel extends StateNotifier<TasksState> {
  final String projectId;

  TasksViewModel(this.projectId) : super(const TasksState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await TaskService.getTasksForProject(projectId);
      state = state.copyWith(isLoading: false, tasks: tasks);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addTask(ProjectTask task) async {
    try {
      final created = await TaskService.addTask(task);
      final updated = [...state.tasks, created]
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      state = state.copyWith(tasks: updated);
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> updateTask(ProjectTask task) async {
    final previous = state.tasks;
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == task.id ? task : t).toList(),
    );
    try {
      await TaskService.updateTask(task);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(tasks: previous);
      Snack.error(e);
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    final previous = state.tasks;
    state = state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList());
    try {
      await TaskService.deleteTask(id);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(tasks: previous);
      Snack.error(e);
      return false;
    }
  }
}

final tasksProvider =
    StateNotifierProvider.family<TasksViewModel, TasksState, String>(
  (ref, projectId) => TasksViewModel(projectId),
);
