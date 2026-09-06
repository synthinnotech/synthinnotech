import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/core/ui/snack.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/notes/note.dart';
import 'package:synthinnotech/modules/notes/notes_service.dart';

class NotesState {
  final bool isLoading;
  final List<Note> notes;
  final String? error;

  const NotesState({this.isLoading = true, this.notes = const [], this.error});

  NotesState copyWith({bool? isLoading, List<Note>? notes, Object? error = _s}) =>
      NotesState(
        isLoading: isLoading ?? this.isLoading,
        notes: notes ?? this.notes,
        error: identical(error, _s) ? this.error : error as String?,
      );
  static const _s = Object();
}

class NotesViewModel extends StateNotifier<NotesState> {
  NotesViewModel(this._uid, this._name) : super(const NotesState()) {
    _bind();
  }

  final String? _uid;
  final String _name;
  StreamSubscription<List<Note>>? _sub;

  void _bind() {
    if (!Db.enabled || _uid == null) {
      state = const NotesState(isLoading: false, notes: []);
      return;
    }
    _sub = NotesService.watch(_uid).listen(
      (list) => state = NotesState(isLoading: false, notes: list),
      onError: (e) => state = state.copyWith(
          isLoading: false,
          error: e is AppException ? e.message : e.toString()),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> saveNote({
    Note? existing,
    required String title,
    required String body,
    required int color,
    required bool shared,
    required bool pinned,
  }) async {
    if (title.trim().isEmpty && body.trim().isEmpty) return;
    try {
      final note = (existing ??
              Note(id: '', title: '', body: '', ownerId: _uid ?? 'local', ownerName: _name))
          .copyWith(
        title: title.trim(),
        body: body.trim(),
        colorValue: color,
        shared: shared,
        pinned: pinned,
      );
      final saved = await NotesService.save(note);
      if (!Db.enabled) {
        // Local mode: keep it in memory.
        final others = state.notes.where((n) => n.id != saved.id).toList();
        state = state.copyWith(notes: [saved, ...others], isLoading: false);
      }
    } on AppException catch (e) {
      Snack.error(e);
    }
  }

  Future<void> delete(Note note) async {
    final prev = state.notes;
    state = state.copyWith(notes: prev.where((n) => n.id != note.id).toList());
    try {
      await NotesService.delete(note.id);
    } on AppException catch (e) {
      state = state.copyWith(notes: prev);
      Snack.error(e);
    }
  }

  Future<void> togglePin(Note note) => saveNote(
        existing: note,
        title: note.title,
        body: note.body,
        color: note.colorValue,
        shared: note.shared,
        pinned: !note.pinned,
      );
}

final notesViewModelProvider =
    StateNotifierProvider.autoDispose<NotesViewModel, NotesState>((ref) {
  final user = ref.watch(currentUserProvider);
  return NotesViewModel(user?.uid, user?.name ?? 'Me');
});
