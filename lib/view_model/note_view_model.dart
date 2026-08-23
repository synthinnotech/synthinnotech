import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/model/home/note.dart';
import 'package:synthinnotech/service/note_service.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';

const notePalette = [
  0xFFFFF59D,
  0xFFB2DFDB,
  0xFFFFCCBC,
  0xFFC5CAE9,
  0xFFF8BBD0,
  0xFFC8E6C9,
];

class NotesViewModel extends StateNotifier<List<Note>> {
  final String uid;

  NotesViewModel(this.uid) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final notes = await NoteService.getNotes(uid);
      state = notes;
    } catch (_) {}
  }

  Future<void> refresh() => _load();

  Future<void> addNote({required String title, required String content}) async {
    final now = DateTime.now();
    final note = Note(
      id: '',
      title: title,
      content: content,
      createdBy: uid,
      createdAt: now,
      updatedAt: now,
      colorValue: notePalette[state.length % notePalette.length],
    );
    final saved = await NoteService.addNote(note);
    state = [saved, ...state];
  }

  Future<void> editNote(Note note, {required String title, required String content}) async {
    final updated = note.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    await NoteService.updateNote(updated);
    state = [for (final n in state) if (n.id == note.id) updated else n];
  }

  Future<void> deleteNote(String id) async {
    await NoteService.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notesViewModelProvider =
    StateNotifierProvider.autoDispose<NotesViewModel, List<Note>>((ref) {
  final uid = ref.watch(loginViewModelProvider).user?.uid ?? '';
  return NotesViewModel(uid);
});
