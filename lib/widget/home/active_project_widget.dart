import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/view/project_detail_screen.dart';
import 'package:synthinnotech/view/projects_screen.dart' show ProjectsScreen;

class ActiveProjectWidget extends StatelessWidget {
  const ActiveProjectWidget({super.key, required this.projects});
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeProjects = projects
        .where((p) =>
            p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.onTrack ||
            p.status == ProjectStatus.review)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Projects',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const ProjectsScreen(),
                  transition: Transition.rightToLeft),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No active projects',
                style: GoogleFonts.inter(color: colorScheme.onSurface.withAlpha(120)),
              ),
            ),
          )
        else
          ...activeProjects.asMap().entries.map(
                (entry) => FadeInLeft(
                  delay: Duration(milliseconds: entry.key * 100),
                  duration: const Duration(milliseconds: 400),
                  child: _ProjectCard(project: entry.value),
                ),
              ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = project.status.color;

    return GestureDetector(
      onTap: () => Get.to(
        () => ProjectDetailScreen(project: project),
        transition: Transition.rightToLeft,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.status.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            if (project.clientName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                project.clientName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor:
                          colorScheme.onSurface.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (project.deadline != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${_formatDate(project.deadline!)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: project.deadline!.isBefore(DateTime.now())
                          ? const Color(0xFFF44336)
                          : colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
