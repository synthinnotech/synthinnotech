import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/model/home/project.dart';
import 'package:synthinnotech/view/add_project_screen.dart';
import 'package:synthinnotech/view/project_detail_screen.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';
import 'package:synthinnotech/widget/common/app_empty_state.dart';
import 'package:synthinnotech/widget/common/app_loading.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Active', 'Available', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Projects',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Get.to(() => const AddProjectScreen(), transition: Transition.downToUp),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: AppLoadingList(count: 4),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _ProjectList(projects: state.projects),
                _ProjectList(projects: state.inProgress),
                _ProjectList(projects: state.available),
                _ProjectList(projects: state.done),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65),
        child: FloatingActionButton.extended(
          onPressed: () =>
              Get.to(() => const AddProjectScreen(), transition: Transition.downToUp),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text('New Project', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _ProjectList extends StatelessWidget {
  final List<Project> projects;
  const _ProjectList({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const AppEmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No Projects',
        subtitle: 'No projects in this category yet',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: projects.length,
      itemBuilder: (ctx, i) => FadeInUp(
        delay: Duration(milliseconds: i * 60),
        duration: const Duration(milliseconds: 350),
        child: _ProjectCard(project: projects[i]),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = project.status.color;

    return GestureDetector(
      onTap: () => Get.to(
        () => ProjectDetailScreen(project: project),
        transition: Transition.rightToLeft,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.status.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      project.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withAlpha(140),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                      const Spacer(),
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
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor:
                          colorScheme.onSurface.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 7,
                    ),
                  ),
                  if (project.budget > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _BudgetChip(
                            icon: Icons.account_balance_wallet_outlined,
                            label:
                                'Budget: ₹${_fmt(project.budget)}',
                            color: const Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        _BudgetChip(
                            icon: Icons.receipt_outlined,
                            label: 'Spent: ₹${_fmt(project.spent)}',
                            color: const Color(0xFFF44336)),
                      ],
                    ),
                  ],
                  if (project.deadline != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: project.deadline!.isBefore(DateTime.now()) &&
                                  project.status != ProjectStatus.done
                              ? const Color(0xFFF44336)
                              : colorScheme.onSurface.withAlpha(120),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${_date(project.deadline!)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: project.deadline!.isBefore(DateTime.now()) &&
                                    project.status != ProjectStatus.done
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
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _date(DateTime d) {
    final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _BudgetChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _BudgetChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
