import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/service/notification_service.dart';
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
    String? error,
  }) =>
      ProjectsState(
        isLoading: isLoading ?? this.isLoading,
        projects: projects ?? this.projects,
        error: error,
      );

  List<Project> get available =>
      projects.where((p) => p.status == ProjectStatus.available).toList();
  List<Project> get inProgress =>
      projects.where((p) => p.status == ProjectStatus.inProgress || p.status == ProjectStatus.onTrack).toList();
  List<Project> get done =>
      projects.where((p) => p.status == ProjectStatus.done || p.status == ProjectStatus.completed).toList();
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addProject(Project project) async {
    final created = await ProjectService.addProject(project);
    state = state.copyWith(projects: [created, ...state.projects]);
    NotificationService.showNotification(
      title: 'Project Created',
      body: '"${project.name}" has been added',
      channelKey: 'project_channel',
      withActions: false,
    );
  }

  Future<void> updateProject(Project project) async {
    final old = state.projects.firstWhere((p) => p.id == project.id,
        orElse: () => project);
    await ProjectService.updateProject(project);
    final updated =
        state.projects.map((p) => p.id == project.id ? project : p).toList();
    state = state.copyWith(projects: updated);
    if (old.status != project.status) {
      final isDone = project.status == ProjectStatus.done ||
          project.status == ProjectStatus.completed;
      NotificationService.showNotification(
        title: isDone ? 'Project Completed!' : 'Project Status Updated',
        body: isDone
            ? '"${project.name}" has been completed'
            : '"${project.name}" is now ${project.status.label}',
        channelKey: 'project_channel',
        withActions: false,
      );
    }
  }

  Future<void> deleteProject(String id) async {
    await ProjectService.deleteProject(id);
    state = state.copyWith(
        projects: state.projects.where((p) => p.id != id).toList());
  }
}

final projectsViewModelProvider =
    StateNotifierProvider<ProjectsViewModel, ProjectsState>(
  (ref) => ProjectsViewModel(),
);
