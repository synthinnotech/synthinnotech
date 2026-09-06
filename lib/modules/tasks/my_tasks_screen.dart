import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:synthinnotech/modules/tasks/my_tasks_view_model.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myTasksProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(myTasksProvider.notifier).load(),
              child: (state.tasks.isEmpty)
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.task_alt,
                            size: 60,
                            color: cs.onSurface.withValues(alpha: 0.25)),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            state.error ??
                                'No tasks assigned to you yet.\n'
                                    'A manager can assign you tasks from a project.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      children: [
                        _group('Overdue', state.overdue, ref,
                            color: const Color(0xFFF44336)),
                        _group('Today', state.today, ref,
                            color: const Color(0xFF2196F3)),
                        _group('Upcoming', state.upcoming, ref,
                            color: const Color(0xFFFF9800)),
                        _group('Completed', state.done, ref,
                            color: const Color(0xFF4CAF50), dim: true),
                      ],
                    ),
            ),
    );
  }

  Widget _group(String title, List<ProjectTask> tasks, WidgetRef ref,
      {required Color color, bool dim = false}) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('$title · ${tasks.length}',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
        ...tasks.map((t) => _TaskRow(task: t, dim: dim, ref: ref)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.dim, required this.ref});
  final ProjectTask task;
  final bool dim;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: dim ? 0.6 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => ref.read(myTasksProvider.notifier).advance(task),
              child: Icon(
                task.status == TaskStatus.done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.status.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null)),
                  Text(
                    '${task.projectName ?? 'Project'} · due ${DateFormat('MMM d').format(task.endDate)}',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: task.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(task.status.label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: task.status.color)),
            ),
          ],
        ),
      ),
    );
  }
}
