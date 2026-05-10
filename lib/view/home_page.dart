import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/notifications_screen.dart';
import 'package:synthinnotech/view_model/expense_view_model.dart';
import 'package:synthinnotech/view_model/home_view_model.dart';
import 'package:synthinnotech/view_model/login_view_model.dart';
import 'package:synthinnotech/view_model/notification_view_model.dart';
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
    final projectsState = ref.watch(projectsViewModelProvider);
    final recentExpenses = ref.watch(expensesViewModelProvider);
    final user = ref.watch(loginViewModelProvider).user;
    final unread =
        ref.watch(notificationsViewModelProvider).unreadCount;
    final isDark = ref.watch(ThemeService.isDarkTheme);
    final colorScheme = Theme.of(context).colorScheme;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(homeViewModelProvider.notifier).refresh();
          await ref.read(projectsViewModelProvider.notifier).load();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              snap: true,
              backgroundColor: isDark ? const Color(0xFF1A1A2E) : colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                          : [colorScheme.primary, colorScheme.primary.withAlpha(180)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                  child: Row(
                    children: [
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withAlpha(30),
                          child: Text(
                            (user?.name.isNotEmpty == true)
                                ? user!.name[0].toUpperCase()
                                : 'S',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting! 👋',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            Text(
                              user?.name ?? 'Welcome',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () => Get.to(
                                    () => const NotificationsScreen(),
                                    transition: Transition.rightToLeft,
                                  ),
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              DateFormat('MMM dd').format(DateTime.now()),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardStatsWidget(statsAsync: dashboardStats),
                  const SizedBox(height: 24),
                  const QuickActionsWidget(),
                  const SizedBox(height: 24),
                  ActiveProjectWidget(projects: projectsState.projects),
                  const SizedBox(height: 24),
                  RecentActivityWidget(expenses: recentExpenses),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
