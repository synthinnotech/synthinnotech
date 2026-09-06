import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  static const _uuid = Uuid();

  static Future<List<ProjectTask>> getTasksForProject(String projectId) async {
    if (!Db.enabled) return const [];
    return Db.guard(() async {
      // `where` only — sort locally so a not-yet-deployed composite index
      // cannot make tasks silently vanish.
      final snap =
          await Db.tasks.where('project_id', isEqualTo: projectId).get();
      final list =
          snap.docs.map((d) => ProjectTask.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) => a.startDate.compareTo(b.startDate));
      return list;
    });
  }

  static Stream<List<ProjectTask>> watchTasksForProject(String projectId) {
    if (!Db.enabled) return Stream.value(const []);
    return Db.guardStream(
      Db.tasks.where('project_id', isEqualTo: projectId).snapshots().map((s) {
        final list =
            s.docs.map((d) => ProjectTask.fromJson(d.data(), d.id)).toList();
        list.sort((a, b) => a.startDate.compareTo(b.startDate));
        return list;
      }),
    );
  }

  /// Tasks assigned to a specific person, across every project.
  static Future<List<ProjectTask>> getTasksForAssignee(String uid) async {
    if (!Db.enabled) return const [];
    return Db.guard(() async {
      final snap = await Db.tasks.where('assignee_id', isEqualTo: uid).get();
      final list =
          snap.docs.map((d) => ProjectTask.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) => a.endDate.compareTo(b.endDate));
      return list;
    });
  }

  static Future<ProjectTask> addTask(ProjectTask task) async {
    final id = task.id.isEmpty ? _uuid.v4() : task.id;
    if (!Db.enabled) return ProjectTask.fromJson(task.toJson(), id);
    return Db.guard(() async {
      await Db.tasks.doc(id).set({...task.toJson(), 'created_at': Db.now});
      final saved = await Db.tasks.doc(id).get();
      return ProjectTask.fromJson(saved.data() ?? task.toJson(), id);
    });
  }

  static Future<void> updateTask(ProjectTask task) async {
    if (!Db.enabled) return;
    return Db.guard(() async {
      await Db.tasks.doc(task.id).set(
            {...task.toJson(), 'updated_at': Db.now},
            SetOptions(merge: true),
          );
    });
  }

  static Future<void> deleteTask(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.tasks.doc(id).delete());
  }
}
