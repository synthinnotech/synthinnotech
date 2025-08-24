import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/project.dart';

class ProjectsViewModel extends StateNotifier<List<Project>> {
  ProjectsViewModel() : super([]) {
    _loadProjects();
  }

  void _loadProjects() {
    state = [
      Project(
        id: '1',
        name: 'Mobile App Redesign',
        clientName: 'TechCorp Inc',
        progress: 0.75,
        status: ProjectStatus.onTrack,
        deadline: DateTime.now().add(const Duration(days: 15)),
      ),
      Project(
        id: '2',
        name: 'E-commerce Platform',
        clientName: 'RetailMax',
        progress: 0.45,
        status: ProjectStatus.delayed,
        deadline: DateTime.now().add(const Duration(days: -2)),
      ),
      Project(
        id: '3',
        name: 'Brand Identity',
        clientName: 'StartupXYZ',
        progress: 0.90,
        status: ProjectStatus.onTrack,
        deadline: DateTime.now().add(const Duration(days: 8)),
      ),
    ];
  }
}

final projectsViewModelProvider =
    StateNotifierProvider<ProjectsViewModel, List<Project>>(
  (ref) => ProjectsViewModel(),
);
