import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = project.status.color;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

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
                      child: Text(project.status.label,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text(project.name,
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    if (project.clientName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(project.clientName,
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
                  if (v == 'delete') _confirmDelete(context, ref);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('Delete',
                            style: GoogleFonts.inter(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (project.description.isNotEmpty) ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Description'),
                          const SizedBox(height: 8),
                          Text(project.description,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: colorScheme.onSurface.withAlpha(160))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 350),
                  child: _Card(
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
                              '${(project.progress * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: project.progress,
                            backgroundColor:
                                colorScheme.onSurface.withAlpha(20),
                            valueColor: AlwaysStoppedAnimation(statusColor),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatusRow(
                          project: project,
                          onStatusChange: (s) {
                            ref
                                .read(projectsViewModelProvider.notifier)
                                .updateProject(project.copyWith(status: s));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (project.budget > 0) ...[
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
                                  value: '₹${_fmt(project.budget)}',
                                  color: const Color(0xFF2196F3),
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              Expanded(
                                child: _BudgetTile(
                                  label: 'Spent',
                                  value: '₹${_fmt(project.spent)}',
                                  color: const Color(0xFFF44336),
                                  icon: Icons.receipt_outlined,
                                ),
                              ),
                              Expanded(
                                child: _BudgetTile(
                                  label: 'Remaining',
                                  value: '₹${_fmt(project.budget - project.spent)}',
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
                              value: project.budget > 0
                                  ? (project.spent / project.budget)
                                      .clamp(0.0, 1.0)
                                  : 0,
                              backgroundColor:
                                  colorScheme.onSurface.withAlpha(20),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFF44336)),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 350),
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Timeline'),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.play_circle_outline,
                          label: 'Start Date',
                          value: project.startDate != null
                              ? '${months[project.startDate!.month - 1]} ${project.startDate!.day}, ${project.startDate!.year}'
                              : 'Not set',
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Deadline',
                          value: project.deadline != null
                              ? '${months[project.deadline!.month - 1]} ${project.deadline!.day}, ${project.deadline!.year}'
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
                      ],
                    ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Project',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Delete "${project.name}"? This cannot be undone.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(projectsViewModelProvider.notifier)
                  .deleteProject(project.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final Project project;
  final ValueChanged<ProjectStatus> onStatusChange;

  const _StatusRow({required this.project, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final statuses = [
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
            child: Text(
              s.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : s.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
