import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/modules/notes/note.dart';
import 'package:uuid/uuid.dart';

class NotesService {
  static const _uuid = Uuid();

  /// My notes + notes others have marked as shared. Merged and de-duplicated
  /// client-side so we avoid an `OR` query / composite index.
  static Stream<List<Note>> watch(String uid) {
    if (!Db.enabled) return Stream.value(const []);
    final mine = Db.notes.where('owner_id', isEqualTo: uid).snapshots();
    final shared = Db.notes.where('shared', isEqualTo: true).snapshots();

    return Db.guardStream(
      mine.map((s) => s.docs).asyncMap((mineDocs) async {
        final sharedSnap = await shared.first;
        final byId = <String, Note>{};
        for (final d in [...mineDocs, ...sharedSnap.docs]) {
          byId[d.id] = Note.fromJson(d.data(), d.id);
        }
        final list = byId.values.toList()
          ..sort((a, b) {
            if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });
        return list;
      }),
    );
  }

  static Future<List<Note>> getMine(String uid) async {
    if (!Db.enabled) return const [];
    return Db.guard(() async {
      final snap = await Db.notes.where('owner_id', isEqualTo: uid).get();
      final list = snap.docs.map((d) => Note.fromJson(d.data(), d.id)).toList();
      list.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return list;
    });
  }

  static Future<Note> save(Note note) async {
    final id = note.id.isEmpty ? _uuid.v4() : note.id;
    if (!Db.enabled) return Note.fromJson(note.toJson(), id);
    return Db.guard(() async {
      final isNew = note.id.isEmpty;
      await Db.notes.doc(id).set({
        ...note.toJson(),
        'updated_at': Db.now,
        if (isNew) 'created_at': Db.now,
      }, SetOptions(merge: true));
      final saved = await Db.notes.doc(id).get();
      return Note.fromJson(saved.data() ?? note.toJson(), id);
    });
  }

  static Future<void> delete(String id) async {
    if (!Db.enabled) return;
    return Db.guard(() => Db.notes.doc(id).delete());
  }
}
