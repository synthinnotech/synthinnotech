import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/notes/note.dart';
import 'package:synthinnotech/modules/notes/notes_view_model.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.note});
  final Note? note;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late int _color;
  late bool _pinned;
  late bool _shared;

  bool get _isNew => widget.note == null;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _title = TextEditingController(text: n?.title ?? '');
    _body = TextEditingController(text: n?.body ?? '');
    _color = n?.colorValue ?? Note.palette.first;
    _pinned = n?.pinned ?? false;
    _shared = n?.shared ?? false;
  }

  @override
  void dispose() {
    _save(); // autosave on leave
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool _saved = false;
  void _save() {
    if (_saved) return;
    _saved = true;
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) return;
    try {
      ref.read(notesViewModelProvider.notifier).saveNote(
            existing: widget.note,
            title: title,
            body: body,
            color: _color,
            shared: _shared,
            pinned: _pinned,
          );
    } catch (_) {
      // Provider already gone (fast back-navigation) — nothing to do.
    }
  }

  bool get _readOnly {
    final me = ref.read(currentUserProvider)?.uid;
    return widget.note != null && widget.note!.ownerId != me;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(_color);
    final readOnly = _readOnly;
    if (readOnly) _saved = true; // don't autosave someone else's note

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (!readOnly && !_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _saved = true;
                ref
                    .read(notesViewModelProvider.notifier)
                    .delete(widget.note!);
                Get.back();
              },
            ),
          if (!readOnly)
            IconButton(
              icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => setState(() => _pinned = !_pinned),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                TextField(
                  controller: _title,
                  readOnly: readOnly,
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _body,
                  readOnly: readOnly,
                  maxLines: null,
                  style: GoogleFonts.inter(fontSize: 15, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Start writing…',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (!readOnly)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ...Note.palette.map((c) => GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == c
                                    ? Colors.black87
                                    : Colors.black26,
                                width: _color == c ? 2 : 1,
                              ),
                            ),
                          ),
                        )),
                    const Spacer(),
                    IconButton(
                      tooltip: _shared
                          ? 'Shared with the team'
                          : 'Private to you',
                      icon: Icon(_shared
                          ? Icons.groups
                          : Icons.lock_outline),
                      onPressed: () => setState(() => _shared = !_shared),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
