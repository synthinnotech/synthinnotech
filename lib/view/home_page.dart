import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synthinnotech/view_model/expense_view_model.dart';
import 'package:synthinnotech/view_model/home_view_model.dart';
import 'package:synthinnotech/view_model/project_view_model.dart';
import 'package:synthinnotech/widget/home/active_project_widget.dart';
import 'package:synthinnotech/widget/home/dashboard_stats_widget.dart';
import 'package:synthinnotech/widget/home/quick_actions_widget.dart';
import 'package:synthinnotech/widget/home/recent_activity_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStats = ref.watch(homeViewModelProvider);
    final projects = ref.watch(projectsViewModelProvider);
    final recentExpenses = ref.watch(expensesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: Icon(Icons.person_outline_outlined),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Text(
              'John Doe',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(homeViewModelProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardStatsWidget(statsAsync: dashboardStats),
              const SizedBox(height: 24),
              QuickActionsWidget(),
              const SizedBox(height: 24),
              ActiveProjectWidget(projects: projects),
              const SizedBox(height: 24),
              RecentActivityWidget(expenses: recentExpenses),
            ],
          ),
        ),
      ),
    );
  }
}
