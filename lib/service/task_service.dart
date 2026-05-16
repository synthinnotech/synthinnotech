import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _col = 'project_tasks';

  static Future<List<ProjectTask>> getTasksForProject(String projectId) async {
    if (_ready) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(_col)
            .where('project_id', isEqualTo: projectId)
            .orderBy('start_date')
            .get();
        return snap.docs
            .map((d) => ProjectTask.fromJson(d.data(), d.id))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  static Future<ProjectTask> addTask(ProjectTask task) async {
    final id = task.id.isEmpty ? const Uuid().v4() : task.id;
    final data = {
      ...task.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    };
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).set(data);
      } catch (_) {}
    }
    return ProjectTask.fromJson(data, id);
  }

  static Future<void> updateTask(ProjectTask task) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance
            .collection(_col)
            .doc(task.id)
            .update(task.toJson());
      } catch (_) {}
    }
  }

  static Future<void> deleteTask(String id) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      } catch (_) {}
    }
  }
}
