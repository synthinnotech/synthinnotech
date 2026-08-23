import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/model/home/note.dart';
import 'package:uuid/uuid.dart';

class NoteService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _col = 'notes';

  static Future<List<Note>> getNotes(String uid) async {
    if (_ready && uid.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(_col)
            .where('created_by', isEqualTo: uid)
            .orderBy('updated_at', descending: true)
            .get();
        return snap.docs.map((d) => Note.fromJson(d.data(), d.id)).toList();
      } catch (_) {}
    }
    return [];
  }

  static Future<Note> addNote(Note note) async {
    final id = note.id.isEmpty ? const Uuid().v4() : note.id;
    final data = note.toJson();
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).set(data);
      } catch (_) {}
    }
    return Note.fromJson(data, id);
  }

  static Future<void> updateNote(Note note) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance
            .collection(_col)
            .doc(note.id)
            .update(note.toJson());
      } catch (_) {}
    }
  }

  static Future<void> deleteNote(String id) async {
    if (_ready) {
      try {
        await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      } catch (_) {}
    }
  }
}
