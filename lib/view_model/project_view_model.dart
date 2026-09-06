import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/service/notification_center.dart';
import 'package:synthinnotech/service/project_service.dart';

class ProjectsState {
  final bool isLoading;
  final List<Project> projects;
  final String? error;

  const ProjectsState({
    this.isLoading = false,
    this.projects = const [],
    this.error,
  });

  ProjectsState copyWith({
    bool? isLoading,
    List<Project>? projects,
    Object? error = _sentinel,
  }) =>
      ProjectsState(
        isLoading: isLoading ?? this.isLoading,
        projects: projects ?? this.projects,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );

  static const _sentinel = Object();

  List<Project> get available =>
      projects.where((p) => p.status == ProjectStatus.available).toList();
  List<Project> get inProgress => projects
      .where((p) =>
          p.status == ProjectStatus.inProgress ||
          p.status == ProjectStatus.onTrack)
      .toList();
  List<Project> get done => projects
      .where((p) =>
          p.status == ProjectStatus.done ||
          p.status == ProjectStatus.completed)
      .toList();
  List<Project> get delayed =>
      projects.where((p) => p.status == ProjectStatus.delayed).toList();
}

class ProjectsViewModel extends StateNotifier<ProjectsState> {
  ProjectsViewModel() : super(const ProjectsState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await ProjectService.getProjects();
      state = state.copyWith(isLoading: false, projects: projects);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addProject(Project project) async {
    try {
      final created = await ProjectService.addProject(project);
      state = state.copyWith(projects: [created, ...state.projects]);
      Snack.success('Project "${created.name}" created');
      NotificationCenter.push(
        title: 'Project Created',
        body: '"${project.name}" has been added',
        type: 'project',
      );
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    final old = state.projects.firstWhere((p) => p.id == project.id,
        orElse: () => project);
    try {
      await ProjectService.updateProject(project);
      state = state.copyWith(
        projects:
            state.projects.map((p) => p.id == project.id ? project : p).toList(),
      );
      if (old.status != project.status) {
        final isDone = project.status == ProjectStatus.done ||
            project.status == ProjectStatus.completed;
        NotificationCenter.push(
          title: isDone ? 'Project Completed!' : 'Project Status Updated',
          body: isDone
              ? '"${project.name}" has been completed'
              : '"${project.name}" is now ${project.status.label}',
          type: 'project',
        );
      }
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      await ProjectService.deleteProject(id);
      state = state.copyWith(
          projects: state.projects.where((p) => p.id != id).toList());
      Snack.success('Project deleted');
      return true;
    } on AppException catch (e) {
      Snack.error(e);
      return false;
    }
  }
}

final projectsViewModelProvider =
    StateNotifierProvider<ProjectsViewModel, ProjectsState>(
  (ref) => ProjectsViewModel(),
);
