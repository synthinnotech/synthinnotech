import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:uuid/uuid.dart';

class ProjectService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _col = 'projects';

  static Future<List<Project>> getProjects() async {
    if (_ready) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(_col)
            .orderBy('created_at', descending: true)
            .get();
        return snap.docs
            .map((d) => Project.fromJson(d.data(), d.id))
            .toList();
      } catch (_) {}
    }
    return _mockProjects();
  }

  static Future<Project> addProject(Project project) async {
    final id = project.id.isEmpty ? const Uuid().v4() : project.id;
    final data = {...project.toJson(), 'created_at': DateTime.now().toIso8601String()};
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).set(data);
      } catch (_) {}
    }
    return Project.fromJson(data, id);
  }

  static Future<void> updateProject(Project project) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance
            .collection(_col)
            .doc(project.id)
            .update(project.toJson());
      } catch (_) {}
    }
  }

  static Future<void> deleteProject(String id) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      } catch (_) {}
    }
  }

  static List<Project> _mockProjects() => [
        Project(
          id: '1',
          name: 'Mobile App Redesign',
          description: 'Complete redesign with new UI/UX patterns.',
          clientName: 'TechCorp Inc',
          status: ProjectStatus.inProgress,
          progress: 0.75,
          budget: 50000,
          spent: 35000,
          deadline: DateTime.now().add(const Duration(days: 15)),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Project(
          id: '2',
          name: 'E-commerce Platform',
          description: 'Build a scalable e-commerce solution.',
          clientName: 'RetailMax',
          status: ProjectStatus.delayed,
          progress: 0.45,
          budget: 80000,
          spent: 42000,
          deadline: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Project(
          id: '3',
          name: 'Brand Identity Design',
          description: 'Complete brand redesign including logo and guidelines.',
          clientName: 'StartupXYZ',
          status: ProjectStatus.review,
          progress: 0.90,
          budget: 15000,
          spent: 12000,
          deadline: DateTime.now().add(const Duration(days: 8)),
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Project(
          id: '4',
          name: 'API Integration Suite',
          description: 'Third-party API integration and data sync.',
          clientName: 'DataFlow Ltd',
          status: ProjectStatus.done,
          progress: 1.0,
          budget: 25000,
          spent: 22000,
          deadline: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
        Project(
          id: '5',
          name: 'Analytics Dashboard',
          description: 'Real-time analytics with data visualization.',
          clientName: 'InsightCo',
          status: ProjectStatus.available,
          progress: 0.0,
          budget: 35000,
          spent: 0,
          deadline: DateTime.now().add(const Duration(days: 45)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Project(
          id: '6',
          name: 'Cloud Migration',
          description: 'Migrate legacy infrastructure to cloud.',
          clientName: 'Enterprise Corp',
          status: ProjectStatus.inProgress,
          progress: 0.30,
          budget: 120000,
          spent: 38000,
          deadline: DateTime.now().add(const Duration(days: 60)),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
}
