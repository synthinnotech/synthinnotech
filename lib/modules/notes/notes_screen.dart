import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/notes/note.dart';
import 'package:synthinnotech/modules/notes/note_editor_screen.dart';
import 'package:synthinnotech/modules/notes/notes_view_model.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesViewModelProvider);
    final me = ref.watch(currentUserProvider)?.uid;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NoteEditorScreen()),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 60,
                          color: cs.onSurface.withValues(alpha: 0.25)),
                      const SizedBox(height: 12),
                      Text('No notes yet',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: cs.onSurface.withValues(alpha: 0.5))),
                      const SizedBox(height: 4),
                      Text('Tap + to capture an idea',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.4))),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.notes.length,
                  itemBuilder: (_, i) {
                    final note = state.notes[i];
                    return _NoteCard(
                      note: note,
                      readOnly: note.ownerId != me,
                      onTap: () => Get.to(
                          () => NoteEditorScreen(note: note)),
                    );
                  },
                ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(
      {required this.note, required this.onTap, required this.readOnly});
  final Note note;
  final VoidCallback onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final bg = Color(note.colorValue);
    final onBg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.pinned)
                  Icon(Icons.push_pin, size: 14, color: onBg.withValues(alpha: 0.6)),
                if (note.shared)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.groups_outlined,
                        size: 14, color: onBg.withValues(alpha: 0.6)),
                  ),
                const Spacer(),
                if (readOnly)
                  Text(note.ownerName,
                      style: GoogleFonts.inter(
                          fontSize: 9, color: onBg.withValues(alpha: 0.5))),
              ],
            ),
            if (note.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: onBg)),
            ],
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.body,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: onBg.withValues(alpha: 0.85)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
