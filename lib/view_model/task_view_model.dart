import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    String? error,
  }) =>
      TasksState(
        isLoading: isLoading ?? this.isLoading,
        tasks: tasks ?? this.tasks,
        error: error,
      );
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTask(ProjectTask task) async {
    final created = await TaskService.addTask(task);
    final updated = [...state.tasks, created]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    state = state.copyWith(tasks: updated);
  }

  Future<void> updateTask(ProjectTask task) async {
    await TaskService.updateTask(task);
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == task.id ? task : t).toList(),
    );
  }

  Future<void> deleteTask(String id) async {
    await TaskService.deleteTask(id);
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
  }
}

final tasksProvider =
    StateNotifierProvider.family<TasksViewModel, TasksState, String>(
  (ref, projectId) => TasksViewModel(projectId),
);
