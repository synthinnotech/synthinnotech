import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/model/home/task_model.dart';
import 'package:synthinnotech/view/edit_project_screen.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';
import 'package:synthinnotech/view_model/task_view_model.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsViewModelProvider).projects;
    final current = projects.isEmpty
        ? project
        : projects.firstWhere((p) => p.id == project.id,
            orElse: () => project);

    final tasksState = ref.watch(tasksProvider(current.id));
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = current.status.color;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: statusColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [statusColor, statusColor.withAlpha(180)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(current.status.label,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text(current.name,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    if (current.clientName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(current.clientName,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white70)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'edit') {
                    Get.to(() => EditProjectScreen(project: current));
                  } else if (v == 'delete') {
                    _confirmDelete(context, ref, current);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18),
                      const SizedBox(width: 8),
                      Text('Edit', style: GoogleFonts.inter()),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Delete',
                          style: GoogleFonts.inter(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Description ──────────────────────────────────────────
                if (current.description.isNotEmpty) ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Description'),
                          const SizedBox(height: 8),
                          Text(current.description,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.5,
                                  color:
                                      colorScheme.onSurface.withAlpha(160))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Progress (interactive slider) ─────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 350),
                  child: _ProgressSliderCard(
                    project: current,
                    onUpdate: (val) {
                      ref
                          .read(projectsViewModelProvider.notifier)
                          .updateProject(current.copyWith(progress: val));
                    },
                    onStatusChange: (s) {
                      ref
                          .read(projectsViewModelProvider.notifier)
                          .updateProject(current.copyWith(status: s));
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Budget (with Log Expense) ─────────────────────────────
                if (current.budget > 0) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 160),
                    duration: const Duration(milliseconds: 350),
                    child: _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Budget'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _BudgetTile(
                                  label: 'Budget',
                                  value: '₹${_fmt(current.budget)}',
                                  color: const Color(0xFF2196F3),
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              Expanded(
                                child: _BudgetTile(
                                  label: 'Spent',
                                  value: '₹${_fmt(current.spent)}',
                                  color: const Color(0xFFF44336),
                                  icon: Icons.receipt_outlined,
                                ),
                              ),
                              Expanded(
                                child: _BudgetTile(
                                  label: 'Remaining',
                                  value:
                                      '₹${_fmt(current.budget - current.spent)}',
                                  color: const Color(0xFF4CAF50),
                                  icon: Icons.savings_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (current.spent / current.budget)
                                  .clamp(0.0, 1.0),
                              backgroundColor:
                                  colorScheme.onSurface.withAlpha(20),
                              valueColor: AlwaysStoppedAnimation(
                                current.spent > current.budget
                                    ? Colors.red
                                    : const Color(0xFFF44336),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showLogExpenseDialog(context, ref, current),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('Log Expense',
                                  style: GoogleFonts.inter(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFF44336),
                                side: const BorderSide(
                                    color: Color(0xFFF44336), width: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Tasks & Timeline ──────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 350),
                  child: _TasksTimelineCard(
                    project: current,
                    tasksState: tasksState,
                    onAddTask: () => _showAddTaskSheet(context, ref, current),
                    onToggleStatus: (task) {
                      ref
                          .read(tasksProvider(current.id).notifier)
                          .updateTask(task.copyWith(status: task.status.next));
                    },
                    onDeleteTask: (task) {
                      ref
                          .read(tasksProvider(current.id).notifier)
                          .deleteTask(task.id);
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  void _showLogExpenseDialog(
      BuildContext context, WidgetRef ref, Project current) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Expense',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Amount (₹)',
            labelStyle: GoogleFonts.inter(fontSize: 14),
            prefixIcon: const Icon(Icons.currency_rupee, size: 18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text.trim());
              if (amount != null && amount > 0) {
                // Pop the dialog first so it's out of the tree
                // before the provider rebuild happens.
                Navigator.pop(ctx);
                ref
                    .read(projectsViewModelProvider.notifier)
                    .updateProject(
                        current.copyWith(spent: current.spent + amount));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336)),
            child: Text('Add',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(
      BuildContext context, WidgetRef ref, Project current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(
        projectId: current.id,
        projectStart: current.startDate,
        projectDeadline: current.deadline,
        onSave: (task) async {
          await ref.read(tasksProvider(current.id).notifier).addTask(task);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Project current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Project',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Delete "${current.name}"? This cannot be undone.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(projectsViewModelProvider.notifier)
                  .deleteProject(current.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Slider Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressSliderCard extends StatefulWidget {
  final Project project;
  final ValueChanged<double> onUpdate;
  final ValueChanged<ProjectStatus> onStatusChange;

  const _ProgressSliderCard({
    required this.project,
    required this.onUpdate,
    required this.onStatusChange,
  });

  @override
  State<_ProgressSliderCard> createState() => _ProgressSliderCardState();
}

class _ProgressSliderCardState extends State<_ProgressSliderCard> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.project.progress;
  }

  @override
  void didUpdateWidget(_ProgressSliderCard old) {
    super.didUpdateWidget(old);
    if (old.project.progress != widget.project.progress) {
      _value = widget.project.progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = widget.project.status.color;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('Progress'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Completion',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: colorScheme.onSurface.withAlpha(140))),
              Text(
                '${(_value * 100).toInt()}%',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: statusColor,
              inactiveTrackColor: colorScheme.onSurface.withAlpha(20),
              thumbColor: statusColor,
              overlayColor: statusColor.withAlpha(30),
              trackHeight: 8,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: (v) => setState(() => _value = v),
              onChangeEnd: widget.onUpdate,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(100))),
              Text('100%',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(100))),
            ],
          ),
          const SizedBox(height: 14),
          _StatusRow(
            project: widget.project,
            onStatusChange: widget.onStatusChange,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tasks & Timeline Card
// ─────────────────────────────────────────────────────────────────────────────

class _TasksTimelineCard extends StatelessWidget {
  final Project project;
  final TasksState tasksState;
  final VoidCallback onAddTask;
  final ValueChanged<ProjectTask> onToggleStatus;
  final ValueChanged<ProjectTask> onDeleteTask;

  const _TasksTimelineCard({
    required this.project,
    required this.tasksState,
    required this.onAddTask,
    required this.onToggleStatus,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasks = tasksState.tasks;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String fmtDate(DateTime d) =>
        '${months[d.month - 1]} ${d.day}, ${d.year}';

    // Derive range for Gantt
    DateTime? rangeStart = project.startDate;
    DateTime? rangeEnd = project.deadline;

    if (tasks.isNotEmpty) {
      final minTask =
          tasks.map((t) => t.startDate).reduce((a, b) => a.isBefore(b) ? a : b);
      final maxTask =
          tasks.map((t) => t.endDate).reduce((a, b) => a.isAfter(b) ? a : b);
      rangeStart ??= minTask;
      rangeEnd ??= maxTask;
    }

    final canShowGantt = rangeStart != null &&
        rangeEnd != null &&
        rangeEnd.isAfter(rangeStart);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label('Tasks & Timeline'),
              GestureDetector(
                onTap: onAddTask,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Add Task',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start / Deadline info rows
          _InfoRow(
            icon: Icons.play_circle_outline,
            label: 'Start Date',
            value: project.startDate != null
                ? fmtDate(project.startDate!)
                : 'Not set',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Deadline',
            value: project.deadline != null
                ? fmtDate(project.deadline!)
                : 'No deadline',
            color: project.deadline != null &&
                    project.deadline!.isBefore(DateTime.now()) &&
                    project.status != ProjectStatus.done
                ? Colors.red
                : colorScheme.onSurface.withAlpha(160),
          ),

          if (project.teamMemberIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Team',
              value: '${project.teamMemberIds.length} members',
              color: const Color(0xFF9C27B0),
            ),
          ],

          // Loading indicator
          if (tasksState.isLoading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ] else if (tasks.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.task_alt,
                      size: 36,
                      color: colorScheme.onSurface.withAlpha(60)),
                  const SizedBox(height: 8),
                  Text('No tasks yet',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurface.withAlpha(100))),
                  const SizedBox(height: 4),
                  Text('Tap "+ Add Task" to create the first task',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: colorScheme.onSurface.withAlpha(70))),
                ],
              ),
            ),
          ] else ...[
            // Gantt chart
            if (canShowGantt) ...[
              const SizedBox(height: 20),
              _GanttChart(
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                tasks: tasks,
              ),
            ],

            // Task list
            const SizedBox(height: 16),
            Divider(color: colorScheme.onSurface.withAlpha(20)),
            const SizedBox(height: 8),
            ...tasks.map((task) => _TaskTile(
                  task: task,
                  onToggle: () => onToggleStatus(task),
                  onDelete: () => onDeleteTask(task),
                )),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gantt Chart
// ─────────────────────────────────────────────────────────────────────────────

class _GanttChart extends StatelessWidget {
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<ProjectTask> tasks;

  const _GanttChart({
    required this.rangeStart,
    required this.rangeEnd,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalDays =
        rangeEnd.difference(rangeStart).inDays.clamp(1, 3650).toDouble();
    final today = DateTime.now();
    const rowH = 30.0;
    const labelW = 88.0;
    const gap = 8.0;

    return LayoutBuilder(builder: (context, constraints) {
      final barAreaW = constraints.maxWidth - labelW - gap;

      // Today marker X position (null if outside range)
      double? todayX;
      if (today.isAfter(rangeStart) && today.isBefore(rangeEnd)) {
        todayX = labelW +
            gap +
            (today.difference(rangeStart).inDays / totalDays) * barAreaW;
      }

      final taskRows = tasks.map((task) {
        final ts = task.startDate.isBefore(rangeStart)
            ? rangeStart
            : task.startDate;
        final te =
            task.endDate.isAfter(rangeEnd) ? rangeEnd : task.endDate;
        final safeTe = te.isAfter(ts) ? te : ts.add(const Duration(days: 1));

        final leftFrac =
            (ts.difference(rangeStart).inDays / totalDays).clamp(0.0, 1.0);
        final widFrac =
            (safeTe.difference(ts).inDays / totalDays).clamp(0.01, 1.0);
        final barLeft = leftFrac * barAreaW;
        final barWidth =
            max(widFrac * barAreaW, 16.0).clamp(0.0, barAreaW - barLeft);

        return SizedBox(
          height: rowH,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: labelW,
                child: Text(
                  task.name,
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: SizedBox(
                  height: 16,
                  child: Stack(
                    children: [
                      // Track
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Task bar
                      Positioned(
                        left: barLeft,
                        width: barWidth,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: task.status.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();

      final fmt = DateFormat('MMM d');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Row(
            children: [
              const SizedBox(width: labelW + gap),
              Text(fmt.format(rangeStart),
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: colorScheme.onSurface.withAlpha(120))),
              const Spacer(),
              if (todayX != null)
                Text('Today',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(fmt.format(rangeEnd),
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: colorScheme.onSurface.withAlpha(120))),
            ],
          ),
          const SizedBox(height: 6),
          // Rows + today marker overlay
          Stack(
            children: [
              Column(children: taskRows),
              if (todayX != null)
                Positioned(
                  left: todayX - 1,
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: TaskStatus.values.map((s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: s.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(s.label,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: colorScheme.onSurface.withAlpha(140))),
                ],
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Tile
// ─────────────────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final ProjectTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Status tap area
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.status.color.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: task.status.color.withAlpha(80), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: task.status.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(task.status.label,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: task.status.color)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  '${fmt.format(task.startDate)} → ${fmt.format(task.endDate)}',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(100)),
                ),
              ],
            ),
          ),
          // Delete
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: colorScheme.onSurface.withAlpha(80)),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Task Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final String projectId;
  final DateTime? projectStart;
  final DateTime? projectDeadline;
  final Future<void> Function(ProjectTask) onSave;

  const _AddTaskSheet({
    required this.projectId,
    required this.onSave,
    this.projectStart,
    this.projectDeadline,
  });

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late DateTime _start;
  late DateTime _end;
  TaskStatus _status = TaskStatus.todo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _start = widget.projectStart ?? DateTime.now();
    _end = widget.projectDeadline ??
        DateTime.now().add(const Duration(days: 7));
    if (!_end.isAfter(_start)) {
      _end = _start.add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(days: 1));
        }
      } else {
        if (picked.isAfter(_start)) {
          _end = picked;
        }
      }
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final task = ProjectTask(
      id: '',
      projectId: widget.projectId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      startDate: _start,
      endDate: _end,
      status: _status,
    );
    await widget.onSave(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('New Task',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Name
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Task Name *',
              labelStyle: GoogleFonts.inter(fontSize: 14),
              prefixIcon:
                  const Icon(Icons.task_outlined, size: 18),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: GoogleFonts.inter(fontSize: 14),
              prefixIcon:
                  const Icon(Icons.notes_outlined, size: 18),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Date row
          Row(
            children: [
              Expanded(
                child: _DatePicker(
                  label: 'Start',
                  value: _start,
                  icon: Icons.play_circle_outline,
                  color: const Color(0xFF4CAF50),
                  display: fmt.format(_start),
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DatePicker(
                  label: 'End',
                  value: _end,
                  icon: Icons.stop_circle_outlined,
                  color: const Color(0xFFF44336),
                  display: fmt.format(_end),
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status chips
          Wrap(
            spacing: 8,
            children: TaskStatus.values.map((s) {
              final sel = _status == s;
              return GestureDetector(
                onTap: () => setState(() => _status = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? s.color : s.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s.label,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : s.color)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : Text('Save Task',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final Color color;
  final String display;
  final VoidCallback onTap;

  const _DatePicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.display,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface.withAlpha(30)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: colorScheme.onSurface.withAlpha(100))),
                  Text(display,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: colorScheme.onSurface.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
            letterSpacing: 0.4));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(110))),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _BudgetTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(120))),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final Project project;
  final ValueChanged<ProjectStatus> onStatusChange;

  const _StatusRow(
      {required this.project, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    const statuses = [
      ProjectStatus.available,
      ProjectStatus.inProgress,
      ProjectStatus.review,
      ProjectStatus.done,
    ];
    return Wrap(
      spacing: 8,
      children: statuses.map((s) {
        final isSelected = project.status == s;
        return GestureDetector(
          onTap: () => onStatusChange(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? s.color : s.color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(s.label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : s.color)),
          ),
        );
      }).toList(),
    );
  }
}
