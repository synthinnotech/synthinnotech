import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/demo/demo_data.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:uuid/uuid.dart';

class ProjectService {
  static const _uuid = Uuid();

  static Future<List<Project>> getProjects() async {
    if (!Db.enabled) return DemoData.projects();
    return Db.guard(() async {
      // Fetch unordered and sort client-side so a missing / mixed-type
      // `created_at` can never make the whole list disappear.
      final snap = await Db.projects.get();
      final list =
          snap.docs.map((d) => Project.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  static Stream<List<Project>> watchProjects() {
    if (!Db.enabled) return Stream.value(DemoData.projects());
    return Db.guardStream(
      Db.projects.snapshots().map((s) {
        final list =
            s.docs.map((d) => Project.fromJson(d.data(), d.id)).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }),
    );
  }

  static Future<Project> addProject(Project project) async {
    final id = project.id.isEmpty ? _uuid.v4() : project.id;
    if (!Db.enabled) return Project.fromJson(project.toJson(), id);
    return Db.guard(() async {
      await Db.projects.doc(id).set({
        ...project.toJson(),
        'created_at': Db.now,
        'created_by': Db.uid,
      });
      final saved = await Db.projects.doc(id).get();
      return Project.fromJson(saved.data() ?? project.toJson(), id);
    });
  }

  static Future<void> updateProject(Project project) async {
    if (!Db.enabled) return;
    return Db.guard(() async {
      await Db.projects.doc(project.id).set(
            {...project.toJson(), 'updated_at': Db.now},
            SetOptions(merge: true),
          );
    });
  }

  static Future<void> deleteProject(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.projects.doc(id).delete());
  }
}
